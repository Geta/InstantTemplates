--beginvalidatingquery
	if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_DatabaseVersion]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
    begin
            declare @ver int
            exec @ver=sp_DatabaseVersion
            if (@ver >= 7048)
				select 0, 'Already correct database version'
            else if (@ver = 7047)
                 select 1, 'Upgrading database'
            else
                 select -1, 'Invalid database version detected'
    end
    else
            select -1, 'Not an EPiServer database'
--endvalidatingquery
GO


PRINT N'Dropping [dbo].[netNotificationSubscriptionFindSubscribers]...';


GO
DROP PROCEDURE [dbo].[netNotificationSubscriptionFindSubscribers];


GO
PRINT N'Dropping [dbo].[netNotificationSubscriptionListSubscriptions]...';


GO
DROP PROCEDURE [dbo].[netNotificationSubscriptionListSubscriptions];


GO
PRINT N'Altering [dbo].[netNotificationMessageInsert]...';


GO

ALTER PROCEDURE [dbo].[netNotificationMessageInsert]
	@Recipient NVARCHAR(255),
	@Sender NVARCHAR(255),
	@Channel NVARCHAR(50) = NULL,
	@Type NVARCHAR(50) = NULL,
	@Subject NVARCHAR(255) = NULL,
	@Content NVARCHAR(MAX) = NULL,
	@Saved DATETIME2,
	@Sent DATETIME2 = NULL,
	@SendAt DATETIME2 = NULL,
	@Category NVARCHAR(255) = NULL
AS
BEGIN
	INSERT INTO tblNotificationMessage(Recipient, Sender, Channel, Type, Subject, Content, SendAt, Saved, Sent ,Category)
	VALUES(@Recipient, @Sender, @Channel, @Type, @Subject, @Content, @SendAt, @Saved, @Sent, @Category)
	SELECT SCOPE_IDENTITY()
END

GO
PRINT N'Altering [dbo].[netNotificationSubscriptionClearSubscription]...';


GO
ALTER PROCEDURE [dbo].[netNotificationSubscriptionClearSubscription]
	@SubscriptionKey [nvarchar](255)
AS
BEGIN
	DECLARE @key [nvarchar](256) = @SubscriptionKey + CASE SUBSTRING(@SubscriptionKey, LEN(@SubscriptionKey), 1) WHEN N'/' THEN N'' ELSE N'/' END

	DELETE FROM [dbo].[tblNotificationSubscription] WHERE SubscriptionKey LIKE @key + '%'
END

GO
PRINT N'Altering [dbo].[netNotificationSubscriptionSubscribe]...';


GO
ALTER PROCEDURE [dbo].[netNotificationSubscriptionSubscribe]
	@UserName [nvarchar](255),
	@SubscriptionKey [nvarchar](255)
AS
BEGIN
	DECLARE @key [nvarchar](256) = @SubscriptionKey + CASE SUBSTRING(@SubscriptionKey, LEN(@SubscriptionKey), 1) WHEN N'/' THEN N'' ELSE N'/' END

	DECLARE @SubscriptionCount INT 
	SELECT @SubscriptionCount = COUNT(*) FROM [dbo].[tblNotificationSubscription] WHERE UserName = @UserName AND SubscriptionKey = @key AND Active = 1
	IF (@SubscriptionCount > 0)
	BEGIN
		SELECT 0
		RETURN
	END
	SELECT @SubscriptionCount = COUNT(*) FROM [dbo].[tblNotificationSubscription] WHERE UserName = @UserName AND SubscriptionKey = @key AND Active = 0
	IF (@SubscriptionCount > 0)
		UPDATE [dbo].[tblNotificationSubscription] SET Active = 1 WHERE UserName = @UserName AND SubscriptionKey = @key
	ELSE 
		INSERT INTO [dbo].[tblNotificationSubscription](UserName, SubscriptionKey) VALUES (@UserName, @key)	
	SELECT 1
END

GO
PRINT N'Altering [dbo].[netNotificationSubscriptionUnsubscribe]...';


GO
ALTER PROCEDURE [dbo].[netNotificationSubscriptionUnsubscribe]
	@UserName [nvarchar](255),
	@SubscriptionKey [nvarchar](255)
AS
BEGIN
	DECLARE @key [nvarchar](256) = @SubscriptionKey + CASE SUBSTRING(@SubscriptionKey, LEN(@SubscriptionKey), 1) WHEN N'/' THEN N'' ELSE N'/' END

	DECLARE @SubscriptionCount INT = (SELECT COUNT(*) FROM [dbo].[tblNotificationSubscription] WHERE UserName = @UserName AND SubscriptionKey = @key AND Active = 1)
	DECLARE @Result INT = CASE @SubscriptionCount WHEN 0 THEN 0 ELSE 1 END
	IF (@SubscriptionCount > 0)
		UPDATE [dbo].[tblNotificationSubscription] SET Active = 0 WHERE UserName = @UserName AND SubscriptionKey = @key
	SELECT @Result
END

GO
PRINT N'Altering [dbo].[netNotificationSubscriptionClearUser]...';


GO
ALTER PROCEDURE [dbo].[netNotificationSubscriptionClearUser]
	@UserName [nvarchar](255)
AS
BEGIN
	DELETE FROM [dbo].[tblNotificationSubscription] WHERE UserName = @UserName
END


GO
PRINT N'Creating [dbo].[netNotificationSubscriptionListByKey]...';


GO
CREATE PROCEDURE [dbo].[netNotificationSubscriptionListByKey]
	@SubscriptionKey [nvarchar](255),
	@SubscriptionKeyMatchMode INT = 0		-- Exact = 0, Before = 1, After = 2
AS
BEGIN 
	DECLARE @key [nvarchar](256) = @SubscriptionKey + CASE SUBSTRING(@SubscriptionKey, LEN(@SubscriptionKey), 1) WHEN N'/' THEN N'' ELSE N'/' END

	IF @SubscriptionKeyMatchMode = 1 
		SELECT [pkID], [UserName], [SubscriptionKey] FROM [dbo].[tblNotificationSubscription] WHERE Active = 1 AND (SubscriptionKey = @key OR @key LIKE SubscriptionKey + '%')
	ELSE IF @SubscriptionKeyMatchMode = 2 
		SELECT [pkID], [UserName], [SubscriptionKey] FROM [dbo].[tblNotificationSubscription] WHERE Active = 1 AND (SubscriptionKey = @key OR SubscriptionKey LIKE @key + '%')
	ELSE
		SELECT [pkID], [UserName], [SubscriptionKey] FROM [dbo].[tblNotificationSubscription] WHERE Active = 1 AND SubscriptionKey = @key
END

GO
PRINT N'Creating [dbo].[netNotificationSubscriptionListByUser]...';


GO
CREATE PROCEDURE [dbo].[netNotificationSubscriptionListByUser]
	@UserName [nvarchar](255)
AS
BEGIN 
	SELECT [pkID], [UserName], [SubscriptionKey] FROM [dbo].[tblNotificationSubscription] WHERE Active = 1 AND UserName = @UserName
END



GO
PRINT N'Updating [dbo].[tblNotificationSubscription]...';


GO
UPDATE [dbo].[tblNotificationSubscription] SET SubscriptionKey = SubscriptionKey + N'/' WHERE SUBSTRING(SubscriptionKey, LEN(SubscriptionKey), 1) != N'/'

GO
PRINT N'Dropping [dbo].[netApprovalDefinitionAddVersion]...';


GO
DROP PROCEDURE [dbo].[netApprovalDefinitionAddVersion];


GO
PRINT N'Dropping [dbo].[AddApprovalDefinitionReviewerTable]...';


GO
DROP TYPE [dbo].[AddApprovalDefinitionReviewerTable];


GO
PRINT N'Creating [dbo].[AddApprovalDefinitionReviewerTable]...';


GO
CREATE TYPE [dbo].[AddApprovalDefinitionReviewerTable] AS TABLE (
    [StepIndex]          INT            NOT NULL,
    [Username]           NVARCHAR (255) NOT NULL,
    [fkLanguageBranchID] INT            NOT NULL,
    [ReviewerType]       INT            NOT NULL);


GO
PRINT N'Altering [dbo].[tblApprovalDefinitionReviewer]...';


GO
ALTER TABLE [dbo].[tblApprovalDefinitionReviewer]
    ADD [ReviewerType] INT DEFAULT 0 NOT NULL;


GO
PRINT N'Creating [dbo].[netApprovalDefinitionAddVersion]...';


GO
CREATE PROCEDURE [dbo].[netApprovalDefinitionAddVersion](
	@ApprovalDefinitionKey NVARCHAR (255),
	@SavedBy NVARCHAR (255),
	@Saved DATETIME2,
	@RequireCommentOnApprove BIT,
	@RequireCommentOnReject BIT,
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
	INSERT INTO [dbo].[tblApprovalDefinitionVersion]([fkApprovalDefinitionID], [SavedBy], [Saved], [RequireCommentOnApprove], [RequireCommentOnReject], [IsEnabled]) OUTPUT inserted.pkID INTO @VersionIDTable VALUES (@ApprovalDefinitionID, @SavedBy, @Saved, @RequireCommentOnApprove, @RequireCommentOnReject, @IsEnabled)
	SELECT @ApprovalDefinitionVersionID = ID FROM @VersionIDTable

	-- Update the current version in the definition
	UPDATE [dbo].[tblApprovalDefinition]
	SET [fkCurrentApprovalDefinitionVersionID] = @ApprovalDefinitionVersionID
	WHERE pkID = @ApprovalDefinitionID

	-- Add steps
	DECLARE @StepTable TABLE (ID INT, StepIndex INT)
	INSERT INTO [dbo].[tblApprovalDefinitionStep]([fkApprovalDefinitionVersionID], [StepIndex], [StepName], [ReviewersNeeded])
	OUTPUT inserted.pkID, inserted.StepIndex INTO @StepTable
	SELECT @ApprovalDefinitionVersionID, StepIndex, StepName, ReviewersNeeded FROM @Steps
	
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
			SET @DecisionComparison = '[decision].pkID IS NOT NULL ' + @DecisionComparison 
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
		PRINT @SQL
	END ELSE BEGIN
		EXEC sp_executesql @Sql, 
			N'@Username NVARCHAR(255),@Roles dbo.StringParameterTable READONLY, @StartIndex INT, @MaxCount INT, @StartedBy NVARCHAR(255), @ApprovalKey NVARCHAR(255), @LanguageBranchID INT, @InvariantLanguageBranchID INT, @Status INT, @DefinitionVersionID INT, @DefinitionID INT, @UserDecisionApproved INT', 
			@Username = @Username, @Roles = @Roles, @StartIndex = @StartIndex, @MaxCount = @MaxCount, @StartedBy = @StartedBy, @ApprovalKey = @ApprovalKey, @LanguageBranchID = @LanguageBranchID, @InvariantLanguageBranchID = @InvariantLanguageBranchID, @Status = @Status, @DefinitionVersionID = @DefinitionVersionID, @DefinitionID = @DefinitionID, @UserDecisionApproved = @UserDecisionApproved
	END
END


GO
PRINT N'Altering [dbo].[netNotificationMessageList]...';

GO
ALTER PROCEDURE [dbo].[netNotificationMessageList]
	@Recipient NVARCHAR(255) = NULL,
	@Channel NVARCHAR(50) = NULL,
	@Category NVARCHAR(255) = NULL,
	@Read BIT = NULL,
	@Sent BIT = NULL,
	@StartIndex	INT,
	@MaxCount	INT
AS
BEGIN
	DECLARE @Ids AS TABLE([RowNr] [int] IDENTITY(0,1), [ID] [bigint] NOT NULL)

	INSERT INTO @Ids
	SELECT pkID
	FROM [tblNotificationMessage]
	WHERE
		((@Recipient IS NULL) OR (@Recipient = Recipient))
		AND
		((@Channel IS NULL) OR (@Channel = Channel))
		AND
		((@Category IS NULL) OR (Category LIKE @Category + '%'))
		AND
		(@Read IS NULL OR 
			((@Read = 1 AND [Read] IS NOT NULL) OR
			(@Read = 0 AND [Read] IS NULL)))
		AND
		(@Sent IS NULL OR 
			((@Sent = 1 AND [Sent] IS NOT NULL) OR
			(@Sent = 0 AND [Sent] IS NULL)))
	ORDER BY Saved DESC

	DECLARE @TotalCount INT = (SELECT COUNT(*) FROM @Ids)
 
	SELECT TOP(@MaxCount) pkID AS ID, [Recipient], [Sender], [Channel], [Type], [Subject], [Content], [Sent], [SendAt], [Saved], [Read], [Category], @TotalCount AS 'TotalCount'
	FROM [tblNotificationMessage] nm
	JOIN @Ids ids ON nm.[pkID] = ids.[ID]
	WHERE ids.RowNr >= @StartIndex
	ORDER BY nm.[Saved] DESC, nm.[pkID] DESC
END

GO
PRINT N'Altering [dbo].[sp_DatabaseVersion]...';


GO
ALTER PROCEDURE [dbo].[sp_DatabaseVersion]
AS
	RETURN 7048
GO

PRINT N'Update complete.';
GO
