--beginvalidatingquery
	if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_DatabaseVersion]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
    begin
            declare @ver int
            exec @ver=sp_DatabaseVersion
            if (@ver >= 7057)
				select 0, 'Already correct database version'
            else if (@ver = 7056)
                 select 1, 'Upgrading database'
            else
                 select -1, 'Invalid database version detected'
    end
    else
            select -1, 'Not an EPiServer database'
--endvalidatingquery


GO
PRINT N'Dropping unnamed constraint on [dbo].[tblApprovalDefinitionStep]...';


GO
DECLARE @DefaultConstraintName NVARCHAR(255) = (SELECT [name] FROM sys.default_constraints WHERE OBJECT_NAME(parent_object_id) = 'tblApprovalDefinitionStep')
EXEC('ALTER TABLE tblApprovalDefinitionStep DROP CONSTRAINT ' + @DefaultConstraintName)


GO
PRINT N'Dropping [dbo].[netApprovalDefinitionAddVersion]...';


GO
DROP PROCEDURE [dbo].[netApprovalDefinitionAddVersion];


GO
PRINT N'Dropping [dbo].[AddApprovalDefinitionStepTable]...';


GO
DROP TYPE [dbo].[AddApprovalDefinitionStepTable];


GO
PRINT N'Creating [dbo].[AddApprovalDefinitionStepTable]...';


GO
CREATE TYPE [dbo].[AddApprovalDefinitionStepTable] AS TABLE (
    [StepIndex]      INT            NOT NULL,
    [StepName]       NVARCHAR (255) NULL,
    [ApprovesNeeded] INT            NULL,
    [SelfApprove]    BIT            NULL);


GO
PRINT N'Altering [dbo].[tblApprovalDefinitionStep]...';


GO
ALTER TABLE [dbo].[tblApprovalDefinitionStep] DROP COLUMN [ReviewersNeeded];


GO
ALTER TABLE [dbo].[tblApprovalDefinitionStep]
    ADD [ApprovesNeeded] INT DEFAULT (NULL) NULL,
        [SelfApprove]    BIT DEFAULT (NULL) NULL;


GO
PRINT N'Altering [dbo].[tblApprovalDefinitionVersion]...';


GO
ALTER TABLE [dbo].[tblApprovalDefinitionVersion]
    ADD [ApprovesNeeded] INT DEFAULT (1) NOT NULL,
        [SelfApprove]    BIT DEFAULT (1) NOT NULL;


GO
PRINT N'Creating [dbo].[netApprovalDefinitionAddVersion]...';


GO
CREATE PROCEDURE [dbo].[netApprovalDefinitionAddVersion](
	@ApprovalDefinitionKey NVARCHAR (255),
	@SavedBy NVARCHAR (255),
	@Saved DATETIME2,
	@RequireCommentOnApprove BIT,
	@RequireCommentOnReject BIT,
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
	INSERT INTO [dbo].[tblApprovalDefinitionVersion]([fkApprovalDefinitionID], [SavedBy], [Saved], [RequireCommentOnApprove], [RequireCommentOnReject], [ApprovesNeeded], [SelfApprove], [IsEnabled]) 
	OUTPUT inserted.pkID 
	INTO @VersionIDTable 
	VALUES (@ApprovalDefinitionID, @SavedBy, @Saved, @RequireCommentOnApprove, @RequireCommentOnReject, @ApprovesNeeded, @SelfApprove, @IsEnabled)
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



PRINT N'Altering [dbo].[sp_DatabaseVersion]...';
GO
ALTER PROCEDURE [dbo].[sp_DatabaseVersion]
AS
	RETURN 7057
GO

PRINT N'Update complete.';
GO
