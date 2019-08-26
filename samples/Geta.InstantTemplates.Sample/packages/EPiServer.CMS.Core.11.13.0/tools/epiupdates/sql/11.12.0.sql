--beginvalidatingquery
	if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_DatabaseVersion]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
    begin
            declare @ver int
            exec @ver=sp_DatabaseVersion
            if (@ver >= 7059)
				select 0, 'Already correct database version'
            else if (@ver = 7058)
                 select 1, 'Upgrading database'
            else
                 select -1, 'Invalid database version detected'
    end
    else
            select -1, 'Not an EPiServer database'
--endvalidatingquery

GO


PRINT N'Altering [dbo].[tblApprovalDefinitionVersion]...';
GO

ALTER TABLE [dbo].[tblApprovalDefinitionVersion] ADD [RequireCommentOnStart] BIT NOT NULL DEFAULT 0

GO

PRINT N'Altering [dbo].[tblApproval]...';
GO

ALTER TABLE [dbo].[tblApproval] ADD	[RequireCommentOnStart] BIT NOT NULL CONSTRAINT [DF_tblApproval_RequireCommentOnStart] DEFAULT 0
ALTER TABLE [dbo].[tblApproval] DROP CONSTRAINT [DF_tblApproval_RequireCommentOnStart]  

GO
PRINT N'Altering [dbo].[netApprovalAdd]...';


GO
ALTER PROCEDURE [dbo].[netApprovalAdd](
	@StartedBy NVARCHAR(255),
	@Started DATETIME2,
	@Approvals [dbo].[AddApprovalTable] READONLY)
AS
BEGIN
	DELETE t FROM [dbo].[tblApproval] t
	JOIN @Approvals a ON t.ApprovalKey = a.ApprovalKey

	DECLARE @StepCounts AS TABLE(VersionID INT, StepCount INT, RequireCommentOnApprove BIT, RequireCommentOnReject BIT, RequireCommentOnStart BIT)

	INSERT INTO @StepCounts
	SELECT VersionID, COUNT(*) AS StepCount, RequireCommentOnApprove, RequireCommentOnReject, RequireCommentOnStart FROM (
		SELECT DISTINCT adv.pkID AS VersionID, ads.pkID AS StepID, adv.RequireCommentOnApprove, adv.RequireCommentOnReject, adv.RequireCommentOnStart FROM [dbo].[tblApprovalDefinitionVersion] adv
		JOIN [dbo].[tblApprovalDefinitionStep] ads ON adv.pkID = ads.fkApprovalDefinitionVersionID
		JOIN @Approvals approvals ON approvals.ApprovalDefinitionVersionID = adv.pkID
	) X	GROUP BY VersionID, RequireCommentOnApprove, RequireCommentOnReject, RequireCommentOnStart

	INSERT INTO [dbo].[tblApproval]([fkApprovalDefinitionVersionID], [ApprovalKey], [fkLanguageBranchID], [ActiveStepIndex], [ActiveStepStarted], [StepCount], [StartedBy], [Started], [Completed], [ApprovalStatus], [RequireCommentOnApprove], [RequireCommentOnReject], [RequireCommentOnStart])
	SELECT a.ApprovalDefinitionVersionID, a.ApprovalKey, a.LanguageBranchID, 0, @Started, sc.StepCount, @StartedBy, @Started, NULL, 0, sc.RequireCommentOnApprove, sc.RequireCommentOnReject, sc.RequireCommentOnStart FROM @Approvals a
	JOIN @StepCounts sc ON a.ApprovalDefinitionVersionID = sc.VersionID

	SELECT t.ApprovalKey, t.pkID AS ApprovalID, t.StepCount, t.RequireCommentOnApprove, t.RequireCommentOnReject, t.RequireCommentOnStart FROM [dbo].[tblApproval] t
	JOIN @Approvals a ON t.ApprovalKey = a.ApprovalKey
END
GO
PRINT N'Altering [dbo].[netApprovalDefinitionAddVersion]...';


GO
ALTER PROCEDURE [dbo].[netApprovalDefinitionAddVersion](
	@ApprovalDefinitionKey NVARCHAR (255),
	@SavedBy NVARCHAR (255),
	@Saved DATETIME2,
	@RequireCommentOnApprove BIT,
	@RequireCommentOnReject BIT,
	@RequireCommentOnStart BIT,
	@ApprovesNeeded INT,
	@SelfApprove BIT,
	@IsEnabled BIT,
	@Steps [dbo].[AddApprovalDefinitionStepTable] READONLY,
	@Reviewers [dbo].[AddApprovalDefinitionReviewerTable] READONLY,
	@ApprovalDefinitionID INT OUT,
	@ApprovalDefinitionVersionID INT OUT)
AS
BEGIN
	SELECT @ApprovalDefinitionID = NULL, @ApprovalDefinitionVersionID = NULL

	-- Get or create an ApprovalDefinition for the ApprovalDefinitionKey
	SELECT @ApprovalDefinitionID = pkID FROM [dbo].[tblApprovalDefinition] WHERE ApprovalDefinitionKey = @ApprovalDefinitionKey
	IF (@ApprovalDefinitionID IS NULL)
	BEGIN
		DECLARE @DefinitionIDTable [dbo].[IDTable]
		INSERT INTO [dbo].[tblApprovalDefinition]([ApprovalDefinitionKey]) OUTPUT inserted.pkID INTO @DefinitionIDTable VALUES (@ApprovalDefinitionKey)
		SELECT @ApprovalDefinitionID = ID FROM @DefinitionIDTable
	END

	-- Add a new ApprovalDefinitionVersion to the definition
	DECLARE @VersionIDTable [dbo].[IDTable]
	INSERT INTO [dbo].[tblApprovalDefinitionVersion]([fkApprovalDefinitionID], [SavedBy], [Saved], [RequireCommentOnApprove], [RequireCommentOnReject], [RequireCommentOnStart], [ApprovesNeeded], [SelfApprove], [IsEnabled]) 
	OUTPUT inserted.pkID 
	INTO @VersionIDTable 
	VALUES (@ApprovalDefinitionID, @SavedBy, @Saved, @RequireCommentOnApprove, @RequireCommentOnReject, @RequireCommentOnStart, @ApprovesNeeded, @SelfApprove, @IsEnabled)
	SELECT @ApprovalDefinitionVersionID = ID FROM @VersionIDTable

	-- Update the current version in the definition
	UPDATE [dbo].[tblApprovalDefinition]
	SET [fkCurrentApprovalDefinitionVersionID] = @ApprovalDefinitionVersionID
	WHERE pkID = @ApprovalDefinitionID

	-- Add steps
	DECLARE @StepTable TABLE (ID INT, StepIndex INT)
	INSERT INTO [dbo].[tblApprovalDefinitionStep]([fkApprovalDefinitionVersionID], [StepIndex], [StepName], [ApprovesNeeded], [SelfApprove])
	OUTPUT inserted.pkID, inserted.StepIndex INTO @StepTable
	SELECT @ApprovalDefinitionVersionID, StepIndex, StepName, ApprovesNeeded, SelfApprove FROM @Steps
	
	-- Add reviewers
	INSERT INTO [dbo].[tblApprovalDefinitionReviewer]([fkApprovalDefinitionStepID], [fkApprovalDefinitionVersionID], [Username], [fkLanguageBranchID], [ReviewerType])
	SELECT step.ID, @ApprovalDefinitionVersionID, reviewer.Username, reviewer.fkLanguageBranchID, reviewer.ReviewerType FROM @Reviewers reviewer
	JOIN @StepTable step ON reviewer.StepIndex = step.StepIndex

	-- Cleanup unused versions
	DELETE adv FROM [dbo].[tblApprovalDefinition] ad
	JOIN [dbo].[tblApprovalDefinitionVersion] adv ON ad.pkID = adv.fkApprovalDefinitionID
	LEFT JOIN [dbo].[tblApproval] a ON a.fkApprovalDefinitionVersionID = adv.pkID
	WHERE ad.pkID = @ApprovalDefinitionID AND ad.fkCurrentApprovalDefinitionVersionID != adv.pkID AND a.pkID IS NULL
END
GO
PRINT N'Altering [dbo].[netApprovalListByQuery]...';


GO
ALTER PROCEDURE [dbo].[netApprovalListByQuery](
	@StartIndex INT,
	@MaxCount INT,
	@Username NVARCHAR(255) = NULL,
	@Roles dbo.StringParameterTable READONLY,
	@StartedBy NVARCHAR(255) = NULL,
	@LanguageBranchID INT = NULL,
	@ApprovalKey NVARCHAR(255) = NULL,
	@DefinitionID INT = NULL,
	@DefinitionVersionID INT = NULL,
	@Status INT = NULL,
	@OnlyActiveSteps BIT = 0,
	@UserDecision BIT = NULL,
	@UserDecisionApproved BIT = NULL,
	@PrintQuery BIT = 0)
AS
BEGIN
	DECLARE @JoinApprovalDefinitionVersion BIT = 0
	DECLARE @JoinApprovalDefinitionReviewer BIT = 0
	DECLARE @JoinApprovalStepDecision BIT = 0

	DECLARE @InvariantLanguageBranchID INT = NULL

	DECLARE @Wheres AS TABLE([String] NVARCHAR(MAX))

	IF @LanguageBranchID IS NOT NULL 
	BEGIN
		SELECT @InvariantLanguageBranchID = [pkID] FROM [dbo].[tblLanguageBranch] WHERE LanguageID = ''
		IF @LanguageBranchID = @InvariantLanguageBranchID
			SET @LanguageBranchID = NULL
		ELSE 
			INSERT INTO @Wheres SELECT '[approval].fkLanguageBranchID IN (@LanguageBranchID, @InvariantLanguageBranchID)'	
	END

	IF @Status IS NOT NULL 
		INSERT INTO @Wheres SELECT '[approval].ApprovalStatus = @Status'

	IF @StartedBy IS NOT NULL 
		INSERT INTO @Wheres SELECT '[approval].StartedBy = @StartedBy'

	IF @DefinitionVersionID IS NOT NULL 
		INSERT INTO @Wheres SELECT '[approval].fkApprovalDefinitionVersionID = @DefinitionVersionID'

	IF @ApprovalKey IS NOT NULL 
		INSERT INTO @Wheres SELECT '[approval].ApprovalKey LIKE @ApprovalKey + ''%''' 

	IF @DefinitionID IS NOT NULL 
	BEGIN
		SET @JoinApprovalDefinitionVersion = 1
		INSERT INTO @Wheres SELECT '[version].fkApprovalDefinitionID = @DefinitionID'
	END

	DECLARE @DecisionComparison NVARCHAR(MAX) = ''
	IF @UserDecision IS NULL OR @UserDecision = 1 
	BEGIN
		SET @DecisionComparison
			= CASE WHEN @Username IS NOT NULL THEN 'AND [decision].Username = @Username ' ELSE '' END   
			+ CASE WHEN @OnlyActiveSteps = 1 THEN 'AND [approval].ActiveStepIndex = [decision].StepIndex ' ELSE '' END   
			+ CASE WHEN @UserDecisionApproved IS NOT NULL THEN 'AND [decision].Approve = @UserDecisionApproved ' ELSE '' END   
		IF @DecisionComparison != '' OR @UserDecision = 1 
		BEGIN
			SET @JoinApprovalStepDecision = 1
			SET @DecisionComparison = '[decision].pkID IS NOT NULL AND [decision].DecisionScope != 4 ' + @DecisionComparison 
		END
	END

	DECLARE @DeclarationComparison NVARCHAR(MAX) = ''
	DECLARE @RoleCount INT = (SELECT COUNT(*) FROM @Roles)
	IF (@Username IS NOT NULL OR @RoleCount > 0) AND (@UserDecision IS NULL OR @UserDecision = 0) 
	BEGIN
		SET @JoinApprovalDefinitionVersion = 1
		SET @JoinApprovalDefinitionReviewer = 1
		
		DECLARE @ReviewerConditionUser NVARCHAR(100) = '[reviewer].[ReviewerType] = 0 AND [reviewer].Username = @Username'
		DECLARE @ReviewerConditionRoles NVARCHAR(100) = CASE @RoleCount WHEN 0 THEN '' WHEN 1 THEN '[reviewer].[ReviewerType] = 1 AND [reviewer].Username = @Role' ELSE '[reviewer].[ReviewerType] = 1 AND [reviewer].Username IN (SELECT [String] FROM @Roles)' END
			
		IF @Username IS NULL
			SET @DeclarationComparison = @ReviewerConditionRoles
		ELSE IF @RoleCount = 0 
			SET @DeclarationComparison = @ReviewerConditionUser
		ELSE
			SET @DeclarationComparison = '((' + @ReviewerConditionUser + ') OR (' + @ReviewerConditionRoles + '))'
	
		SET @DeclarationComparison = @DeclarationComparison
			+ CASE WHEN @OnlyActiveSteps = 1 THEN ' AND [approval].ActiveStepIndex = [step].StepIndex' ELSE '' END   
			+ CASE WHEN @LanguageBranchID IS NOT NULL THEN ' AND (([approval].fkLanguageBranchID = @InvariantLanguageBranchID) OR ([reviewer].fkLanguageBranchID IN (@LanguageBranchID, @InvariantLanguageBranchID )))' ELSE '' END   
	END

	IF @DecisionComparison != '' AND @DeclarationComparison != ''
		INSERT INTO @Wheres SELECT '((' + @DecisionComparison + ') OR (' + @DeclarationComparison + '))'
	ELSE IF @DecisionComparison != ''
		INSERT INTO @Wheres SELECT @DecisionComparison
	ELSE IF @DeclarationComparison != ''
		INSERT INTO @Wheres SELECT @DeclarationComparison
	
	DECLARE @WhereSql NVARCHAR(MAX) 
	SELECT @WhereSql = COALESCE(@WhereSql + CHAR(13) + 'AND ', '') + [String] FROM @Wheres

	DECLARE @SelectSql NVARCHAR(MAX) = 'SELECT DISTINCT [approval].pkID, [approval].[Started] FROM [dbo].[tblApproval] [approval]' + CHAR(13)
		+ CASE WHEN @JoinApprovalDefinitionVersion = 1 THEN 'JOIN [dbo].[tblApprovalDefinitionVersion] [version] ON [approval].fkApprovalDefinitionVersionID = [version].pkID' + CHAR(13) ELSE '' END   
		+ CASE WHEN @JoinApprovalDefinitionReviewer = 1 THEN 'JOIN [dbo].[tblApprovalDefinitionStep] [step] ON [step].fkApprovalDefinitionVersionID = [version].pkID' + CHAR(13) ELSE '' END   
		+ CASE WHEN @JoinApprovalDefinitionReviewer = 1 THEN 'JOIN [dbo].[tblApprovalDefinitionReviewer] [reviewer] ON [reviewer].fkApprovalDefinitionStepID = [step].pkID' + CHAR(13) ELSE '' END   
		+ CASE WHEN @JoinApprovalStepDecision = 1 THEN 'LEFT JOIN [dbo].[tblApprovalStepDecision] [decision] ON [approval].pkID = [decision].fkApprovalID' + CHAR(13) ELSE '' END   

	DECLARE @Sql NVARCHAR(MAX) = @SelectSql 
	IF @WhereSql IS NOT NULL
		SET @Sql += 'WHERE ' + @WhereSql + CHAR(13)

	SET @Sql += 'ORDER BY [Started] DESC'

	SET @Sql = '
DECLARE @Ids AS TABLE([RowNr] [INT] IDENTITY(0,1), [ID] [INT] NOT NULL, [Started] DATETIME)

INSERT INTO @Ids
' + @Sql + '

DECLARE @TotalCount INT = (SELECT COUNT(*) FROM @Ids)

SELECT TOP(@MaxCount) [approval].*, @TotalCount AS ''TotalCount''
FROM [dbo].[tblApproval] [approval]
JOIN @Ids ids ON [approval].[pkID] = ids.[ID]
WHERE ids.RowNr >= @StartIndex
ORDER BY [approval].[Started] DESC'

	IF @RoleCount = 1
		SET @Sql = CHAR(13) + 'DECLARE @Role NVARCHAR(255) = (SELECT [String] FROM @Roles)' + @Sql

	IF @PrintQuery = 1 
	BEGIN
		PRINT @Sql
	END ELSE BEGIN
		EXEC sp_executesql @Sql, 
			N'@Username NVARCHAR(255),@Roles dbo.StringParameterTable READONLY, @StartIndex INT, @MaxCount INT, @StartedBy NVARCHAR(255), @ApprovalKey NVARCHAR(255), @LanguageBranchID INT, @InvariantLanguageBranchID INT, @Status INT, @DefinitionVersionID INT, @DefinitionID INT, @UserDecisionApproved INT', 
			@Username = @Username, @Roles = @Roles, @StartIndex = @StartIndex, @MaxCount = @MaxCount, @StartedBy = @StartedBy, @ApprovalKey = @ApprovalKey, @LanguageBranchID = @LanguageBranchID, @InvariantLanguageBranchID = @InvariantLanguageBranchID, @Status = @Status, @DefinitionVersionID = @DefinitionVersionID, @DefinitionID = @DefinitionID, @UserDecisionApproved = @UserDecisionApproved
	END
END

GO
PRINT N'Altering [dbo].[sp_DatabaseVersion]...';

GO
ALTER PROCEDURE [dbo].[sp_DatabaseVersion]
AS
	RETURN 7059
GO
PRINT N'Creating [dbo].[netConvertCategoryPropertyForPageType]...';


GO
PRINT N'Update complete.';


GO
