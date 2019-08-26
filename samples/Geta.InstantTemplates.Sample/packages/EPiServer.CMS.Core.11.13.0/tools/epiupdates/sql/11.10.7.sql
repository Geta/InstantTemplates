--beginvalidatingquery
	if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_DatabaseVersion]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
    begin
            declare @ver int
            exec @ver=sp_DatabaseVersion
            if (@ver >= 7058)
				select 0, 'Already correct database version'
            else if (@ver = 7057)
                 select 1, 'Upgrading database'
            else
                 select -1, 'Invalid database version detected'
    end
    else
            select -1, 'Not an EPiServer database'
--endvalidatingquery


GO
PRINT N'Altering [dbo].[editDeleteProperty]...';


GO
ALTER PROCEDURE dbo.editDeleteProperty
(
	@ContentID			INT,
	@WorkContentID		INT,
	@PropertyDefinitionID	INT,
	@Override		BIT = 0,
	@LanguageBranch		NCHAR(17) = NULL,
	@ScopeName	NVARCHAR(450) = NULL
)
AS
BEGIN
	DECLARE @LangBranchID NCHAR(17);
	SELECT @LangBranchID = pkID FROM tblLanguageBranch WHERE LanguageID = @LanguageBranch
	IF @LangBranchID IS NULL 
	BEGIN 
		if @LanguageBranch IS NOT NULL
			RAISERROR('Language branch %s is not defined',16,1, @LanguageBranch)
		else
			SET @LangBranchID = -1
	END

	DECLARE @IsLanguagePublished BIT;
	IF EXISTS(SELECT fkContentID FROM tblContentLanguage 
		WHERE fkContentID = @ContentID AND fkLanguageBranchID = CAST(@LangBranchID AS INT) AND [Status] = 4)
		SET @IsLanguagePublished = 1
	ELSE
		SET @IsLanguagePublished = 0
	
	SET NOCOUNT ON
	SET XACT_ABORT ON
	
	DECLARE @retval INT
	SET @retval = 0
	
		IF (@WorkContentID IS NOT NULL)
		BEGIN
			/* This only applies to categories, but since PageDefinitionID is unique
				between all properties it is safe to blindly delete like this */
			DELETE FROM
				tblWorkContentCategory
			WHERE
				fkWorkContentID = @WorkContentID
			AND
				CategoryType = @PropertyDefinitionID
			AND
				(@ScopeName IS NULL OR ScopeName = @ScopeName)

			DELETE FROM
				tblWorkContentProperty
			WHERE
				fkWorkContentID = @WorkContentID
			AND
				fkPropertyDefinitionID = @PropertyDefinitionID
			AND 
				((@ScopeName IS NULL AND ScopeName IS NULL) OR (@ScopeName = ScopeName))
		END
		ELSE
		BEGIN

			/* Might be dynamic properties */
			DELETE FROM
				tblContentCategory
			WHERE
				fkContentID = @ContentID
			AND
				CategoryType = @PropertyDefinitionID
			AND
				(@ScopeName IS NULL OR ScopeName = @ScopeName)
			AND
			(
				@LanguageBranch IS NULL
			OR
				@LangBranchID = fkLanguageBranchID
			)


			IF (@Override = 1)
			BEGIN
				DELETE FROM
					tblContentProperty
				WHERE
					fkPropertyDefinitionID = @PropertyDefinitionID
				AND
					fkContentID IN (SELECT fkChildID FROM tblTree WHERE fkParentID = @ContentID)
				AND
				(
					@LanguageBranch IS NULL
				OR
					@LangBranchID = tblContentProperty.fkLanguageBranchID
				)
				AND 
					((@ScopeName IS NULL AND ScopeName IS NULL) OR (@ScopeName = ScopeName))
				SET @retval = 1
			END
		END
		
		/* When no version is published we save value in tblContentProperty as well, so the property also need to be removed from tblContentProperty*/
		IF (@WorkContentID IS NULL OR @IsLanguagePublished = 0)
		BEGIN
			DELETE FROM
				tblContentProperty
			WHERE
				fkContentID = @ContentID
			AND 
				fkPropertyDefinitionID = @PropertyDefinitionID  
			AND
			(
				@LanguageBranch IS NULL
			OR
				@LangBranchID = tblContentProperty.fkLanguageBranchID
			)
			AND
				((@ScopeName IS NULL AND ScopeName IS NULL) OR (@ScopeName = ScopeName))
		END
			
	RETURN @retval
END
GO
PRINT N'Altering [dbo].[editSavePropertyCategory]...';


GO
ALTER PROCEDURE [dbo].[editSavePropertyCategory]
(
	@ContentID				INT,
	@WorkContentID			INT,
	@PropertyDefinitionID	INT,
	@Override			BIT,
	@CategoryString		NVARCHAR(2000),
	@LanguageBranch		NCHAR(17) = NULL,
	@ScopeName			nvarchar(450) = NULL
)
AS
BEGIN

	SET NOCOUNT	ON
	SET XACT_ABORT ON
	DECLARE	@ContentIDString			NVARCHAR(20)
	DECLARE	@PropertyDefinitionIDString	NVARCHAR(20)
	DECLARE @DynProp INT
	DECLARE @retval	INT
	SET @retval = 0

	DECLARE @LangBranchID NCHAR(17);
	IF (@WorkContentID <> 0)
		SELECT @LangBranchID = fkLanguageBranchID FROM tblWorkContent WHERE pkID = @WorkContentID
	ELSE
		SELECT @LangBranchID = pkID FROM tblLanguageBranch WHERE LanguageID = @LanguageBranch

	IF @LangBranchID IS NULL 
	BEGIN 
		if @LanguageBranch IS NOT NULL
			RAISERROR('Language branch %s is not defined',16,1, @LanguageBranch)
		else
			SET @LangBranchID = 1
	END

	DECLARE @IsLanguagePublished BIT;
	IF EXISTS(SELECT fkContentID FROM tblContentLanguage 
		WHERE fkContentID = @ContentID AND fkLanguageBranchID = CAST(@LangBranchID AS INT) AND Status = 4)
		SET @IsLanguagePublished = 1
	ELSE
		SET @IsLanguagePublished = 0

	SELECT @DynProp=pkID FROM tblPropertyDefinition WHERE pkID=@PropertyDefinitionID AND fkContentTypeID IS NULL
	IF (@WorkContentID IS NOT NULL)
	BEGIN
		/* Never store dynamic properties in work table */
		IF (@DynProp IS NOT NULL)
			GOTO cleanup
				
		/* Remove all categories */
		SET @ContentIDString = CONVERT(NVARCHAR(20), @WorkContentID)
		SET @PropertyDefinitionIDString = CONVERT(NVARCHAR(20), @PropertyDefinitionID)
		DELETE FROM tblWorkContentCategory WHERE fkWorkContentID=@WorkContentID AND ScopeName=@ScopeName
		/* Insert new categories */
		IF (LEN(@CategoryString) > 0)
		BEGIN
			EXEC (N'INSERT INTO tblWorkContentCategory (fkWorkContentID, fkCategoryID, CategoryType, ScopeName) SELECT ' + @ContentIDString + N',pkID,' + @PropertyDefinitionIDString + N', ''' + @ScopeName + N''' FROM tblCategory WHERE pkID IN (' + @CategoryString +N')' )
		END
		
		/* Finally update the property table */
		IF (@PropertyDefinitionID <> 0)
		BEGIN
			IF EXISTS(SELECT fkWorkContentID FROM tblWorkContentProperty WHERE fkWorkContentID=@WorkContentID AND fkPropertyDefinitionID=@PropertyDefinitionID AND ScopeName=@ScopeName)
				UPDATE tblWorkContentProperty SET Number=@PropertyDefinitionID WHERE fkWorkContentID=@WorkContentID 
					AND fkPropertyDefinitionID=@PropertyDefinitionID
					AND ((@ScopeName IS NULL AND ScopeName IS NULL) OR (@ScopeName = ScopeName))
			ELSE
				INSERT INTO tblWorkContentProperty (fkWorkContentID, fkPropertyDefinitionID, Number, ScopeName) VALUES (@WorkContentID, @PropertyDefinitionID, @PropertyDefinitionID, @ScopeName)
		END
	END
	
	IF (@WorkContentID IS NULL OR @IsLanguagePublished = 0)
	BEGIN
		/* Insert or update property */
		/* Remove all categories */
		SET @ContentIDString = CONVERT(NVARCHAR(20), @ContentID)
		SET @PropertyDefinitionIDString = CONVERT(NVARCHAR(20), @PropertyDefinitionID)
		DELETE FROM tblContentCategory WHERE fkContentID=@ContentID AND ScopeName=@ScopeName
		AND fkLanguageBranchID=@LangBranchID
		
		/* Insert new categories */
		IF (LEN(@CategoryString) > 0)
		BEGIN
			EXEC (N'INSERT INTO tblContentCategory (fkContentID, fkCategoryID, CategoryType, fkLanguageBranchID, ScopeName) SELECT ' + @ContentIDString + N',pkID,' + @PropertyDefinitionIDString + N', ' + @LangBranchID + N', ''' + @ScopeName + N''' FROM tblCategory WHERE pkID IN (' + @CategoryString +N')' )
		END
		
		/* Finally update the property table */
		IF (@PropertyDefinitionID <> 0)
		BEGIN
			IF EXISTS(SELECT fkContentID FROM tblContentProperty WHERE fkContentID=@ContentID AND fkPropertyDefinitionID=@PropertyDefinitionID 
						AND fkLanguageBranchID=@LangBranchID AND ScopeName=@ScopeName)
				UPDATE tblContentProperty SET Number=@PropertyDefinitionID WHERE fkContentID=@ContentID AND fkPropertyDefinitionID=@PropertyDefinitionID
						AND fkLanguageBranchID=@LangBranchID
						AND ((@ScopeName IS NULL AND ScopeName IS NULL) OR (@ScopeName = ScopeName))
			ELSE
				INSERT INTO tblContentProperty (fkContentID, fkPropertyDefinitionID, Number, fkLanguageBranchID, ScopeName) VALUES (@ContentID, @PropertyDefinitionID, @PropertyDefinitionID, @LangBranchID, @ScopeName)
		END
				
		/* Override dynamic property definitions below the current level */
		IF (@DynProp IS NOT NULL)
		BEGIN
			IF (@Override = 1)
				DELETE FROM tblContentProperty WHERE fkPropertyDefinitionID=@PropertyDefinitionID AND fkContentID IN (SELECT fkChildID FROM tblTree WHERE fkParentID=@ContentID)
			SET @retval = 1
		END
	END
cleanup:		
	
	RETURN @retval
END
GO
PRINT N'Altering [dbo].[netPropertySave]...';


GO
ALTER PROCEDURE [dbo].[netPropertySave]
(
	@ContentId				INT,
	@WorkContentID			INT,
	@PropertyDefinitionID	INT,
	@Override			BIT,
	@LanguageBranch		NCHAR(17) = NULL,
	@ScopeName			NVARCHAR(450) = NULL,
--Per Type:
	@Number				INT = NULL,
	@Boolean			BIT = 0,
	@Date				DATETIME = NULL,
	@FloatNumber		FLOAT = NULL,
	@ContentType			INT = NULL,
	@String				NVARCHAR(450) = NULL,
	@LinkGuid			uniqueidentifier = NULL,
	@ContentLink			INT = NULL,
	@LongString			NVARCHAR(MAX) = NULL


)
AS
BEGIN
	SET NOCOUNT ON
	SET XACT_ABORT ON

	DECLARE @LangBranchID NCHAR(17);
	IF (@WorkContentID <> 0)
		SELECT @LangBranchID = fkLanguageBranchID FROM tblWorkContent WHERE pkID = @WorkContentID
	ELSE
		SELECT @LangBranchID = pkID FROM tblLanguageBranch WHERE LanguageID = @LanguageBranch

	IF @LangBranchID IS NULL 
	BEGIN 
		if @LanguageBranch IS NOT NULL
			RAISERROR('Language branch %s is not defined',16,1, @LanguageBranch)
		else
			SET @LangBranchID = 1
	END

	DECLARE @IsLanguagePublished BIT;
	IF EXISTS(SELECT fkContentID FROM tblContentLanguage 
		WHERE fkContentID = @ContentId AND fkLanguageBranchID = CAST(@LangBranchID AS INT) AND Status = 4)
		SET @IsLanguagePublished = 1
	ELSE
		SET @IsLanguagePublished = 0
	
	DECLARE @DynProp INT
	DECLARE @retval	INT
	SET @retval = 0
	
		SELECT
			@DynProp = pkID
		FROM
			tblPropertyDefinition
		WHERE
			pkID = @PropertyDefinitionID
		AND
			fkContentTypeID IS NULL

		IF (@WorkContentID IS NOT NULL)
		BEGIN
			/* Never store dynamic properties in work table */
			IF (@DynProp IS NOT NULL)
				GOTO cleanup
				
			/* Insert or update property */
			IF EXISTS(SELECT fkWorkContentID FROM tblWorkContentProperty 
				WHERE fkWorkContentID=@WorkContentID AND fkPropertyDefinitionID=@PropertyDefinitionID AND ((@ScopeName IS NULL AND ScopeName IS NULL) OR (@ScopeName = ScopeName)))
				UPDATE
					tblWorkContentProperty
				SET
					ScopeName = @ScopeName,
					Number = @Number,
					Boolean = @Boolean,
					[Date] = @Date,
					FloatNumber = @FloatNumber,
					ContentType = @ContentType,
					String = @String,
					LinkGuid = @LinkGuid,
					ContentLink = @ContentLink,
					LongString = @LongString
				WHERE
					fkWorkContentID = @WorkContentID
				AND
					fkPropertyDefinitionID = @PropertyDefinitionID
				AND 
					((@ScopeName IS NULL AND ScopeName IS NULL) OR (@ScopeName = ScopeName))
			ELSE
				INSERT INTO
					tblWorkContentProperty
					(fkWorkContentID,
					fkPropertyDefinitionID,
					ScopeName,
					Number,
					Boolean,
					[Date],
					FloatNumber,
					ContentType,
					String,
					LinkGuid,
					ContentLink,
					LongString)
				VALUES
					(@WorkContentID,
					@PropertyDefinitionID,
					@ScopeName,
					@Number,
					@Boolean,
					@Date,
					@FloatNumber,
					@ContentType,
					@String,
					@LinkGuid,
					@ContentLink,
					@LongString)
		END
		
		/* For published or languages where no version is published we save value in tblContentProperty as well. Reason for this is that if when page is loaded
		through tblContentProperty (typically netPageListPaged) the page gets populated correctly. */
		IF (@WorkContentID IS NULL OR @IsLanguagePublished = 0)
		BEGIN
			/* Insert or update property */
			IF EXISTS(SELECT fkContentID FROM tblContentProperty 
				WHERE fkContentID = @ContentId AND fkPropertyDefinitionID = @PropertyDefinitionID  AND
					((@ScopeName IS NULL AND ScopeName IS NULL) OR (@ScopeName = ScopeName)) AND @LangBranchID = tblContentProperty.fkLanguageBranchID)
				UPDATE
					tblContentProperty
				SET
					ScopeName = @ScopeName,
					Number = @Number,
					Boolean = @Boolean,
					[Date] = @Date,
					FloatNumber = @FloatNumber,
					ContentType = @ContentType,
					String = @String,
					LinkGuid = @LinkGuid,
					ContentLink = @ContentLink,
					LongString = @LongString,
                    /* LongString is utf-16 - Datalength gives bytes, i e div by 2 gives characters */
		            /* Include length to handle delayed loading of LongString with threshold */
		            LongStringLength = COALESCE(DATALENGTH(@LongString), 0) / 2
				WHERE
					fkContentID = @ContentId
				AND
					fkPropertyDefinitionID = @PropertyDefinitionID
				AND 
					((@ScopeName IS NULL AND ScopeName IS NULL) OR (@ScopeName = ScopeName))
				AND
					@LangBranchID = tblContentProperty.fkLanguageBranchID
			ELSE
				INSERT INTO
					tblContentProperty
					(fkContentID,
					fkPropertyDefinitionID,
					ScopeName,
					Number,
					Boolean,
					[Date],
					FloatNumber,
					ContentType,
					String,
					LinkGuid,
					ContentLink,
					LongString,
                    LongStringLength,
					fkLanguageBranchID)
				VALUES
					(@ContentId,
					@PropertyDefinitionID,
					@ScopeName,
					@Number,
					@Boolean,
					@Date,
					@FloatNumber,
					@ContentType,
					@String,
					@LinkGuid,
					@ContentLink,
					@LongString,
                    COALESCE(DATALENGTH(@LongString), 0) / 2,
					@LangBranchID)
				
			/* Override dynamic property definitions below the current level */
			IF (@DynProp IS NOT NULL)
			BEGIN
				IF (@Override = 1)
					DELETE FROM
						tblContentProperty
					WHERE
						fkPropertyDefinitionID = @PropertyDefinitionID
					AND
					(	
						@LanguageBranch IS NULL
					OR
						@LangBranchID = tblContentProperty.fkLanguageBranchID
					)
					AND
						fkContentID
					IN
						(SELECT fkChildID FROM tblTree WHERE fkParentID = @ContentId)
				SET @retval = 1
			END
		END
cleanup:		
		
	RETURN @retval
END
GO
PRINT N'Altering [dbo].[sp_DatabaseVersion]...';


GO
ALTER PROCEDURE [dbo].[sp_DatabaseVersion]
AS
	RETURN 7058
GO
PRINT N'Update complete.';


GO
