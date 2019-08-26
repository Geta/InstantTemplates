--beginvalidatingquery
	if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_DatabaseVersion]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
    begin
            declare @ver int
            exec @ver=sp_DatabaseVersion
            if (@ver >= 7051)
				select 0, 'Already correct database version'
            else if (@ver = 7050)
                 select 1, 'Upgrading database'
            else
                 select -1, 'Invalid database version detected'
    end
    else
            select -1, 'Not an EPiServer database'
--endvalidatingquery
GO
PRINT N'Dropping [dbo].[netContentTrimVersions]...';


GO
DROP PROCEDURE [dbo].[netContentTrimVersions];


GO
PRINT N'Altering [dbo].[editPublishContentVersion]...';


GO
ALTER PROCEDURE dbo.editPublishContentVersion
(
	@WorkContentID	INT,
	@UserName NVARCHAR(255),
	@TrimVersions INT = 0,
	@ResetCommonDraft BIT = 1,
	@PublishedDate DATETIME = NULL
)
AS
BEGIN
	SET NOCOUNT ON
	SET XACT_ABORT ON
	DECLARE @ContentID INT
	DECLARE @retval INT
	DECLARE @FirstPublish BIT
	DECLARE @ParentID INT
	DECLARE @LangBranchID INT
	DECLARE @IsMasterLang BIT
	
	/* Verify that we have a Content to publish */
	SELECT	@ContentID=fkContentID,
			@LangBranchID=fkLanguageBranchID,
			@IsMasterLang = CASE WHEN tblWorkContent.fkLanguageBranchID=tblContent.fkMasterLanguageBranchID THEN 1 ELSE 0 END
	FROM tblWorkContent WITH (ROWLOCK,XLOCK)
	INNER JOIN tblContent WITH (ROWLOCK,XLOCK) ON tblContent.pkID=tblWorkContent.fkContentID
	WHERE tblWorkContent.pkID=@WorkContentID
	
	IF (@@ROWCOUNT <> 1)
		RETURN 0

	IF @PublishedDate IS NULL
		SET @PublishedDate = GetDate()
					
	/* Move Content information from worktable to published table */
	IF @IsMasterLang=1
	BEGIN
		UPDATE 
			tblContent
		SET
			ArchiveContentGUID	= W.ArchiveContentGUID,
			VisibleInMenu	= W.VisibleInMenu,
			ChildOrderRule	= W.ChildOrderRule,
			PeerOrder		= W.PeerOrder
		FROM 
			tblWorkContent AS W
		WHERE 
			tblContent.pkID=W.fkContentID AND 
			W.pkID=@WorkContentID
	END
	
	UPDATE 
			tblContentLanguage WITH (ROWLOCK,XLOCK)
		SET
			ChangedByName	= W.ChangedByName,
			ContentLinkGUID	= W.ContentLinkGUID,
			fkFrameID		= W.fkFrameID,
			Name			= W.Name,
			URLSegment		= W.URLSegment,
			LinkURL			= W.LinkURL,
			BlobUri			= W.BlobUri,
			ThumbnailUri	= W.ThumbnailUri,
			ExternalURL		= Lower(W.ExternalURL),
			AutomaticLink	= CASE WHEN W.LinkType = 2 OR W.LinkType = 3 THEN 0 ELSE 1 END,
			FetchData		= CASE WHEN W.LinkType = 4 THEN 1 ELSE 0 END,
			Created			= W.Created,
			Changed			= CASE WHEN W.ChangedOnPublish=0 AND tblContentLanguage.Status = 4 THEN Changed ELSE @PublishedDate END,
			Saved			= @PublishedDate,
			StartPublish	= COALESCE(W.StartPublish, @PublishedDate),
			StopPublish		= W.StopPublish,
			Status			= 4,
			Version			= @WorkContentID,
			DelayPublishUntil = NULL
		FROM 
			tblWorkContent AS W
		WHERE 
			tblContentLanguage.fkContentID=W.fkContentID AND
			W.fkLanguageBranchID=tblContentLanguage.fkLanguageBranchID AND
			W.pkID=@WorkContentID

	IF @@ROWCOUNT!=1
		RAISERROR (N'editPublishContentVersion: Cannot find correct version in tblContentLanguage for version %d', 16, 1, @WorkContentID)

	/*Set current published version on this language to HasBeenPublished*/
	UPDATE
		tblWorkContent
	SET
		Status = 5
	WHERE
		fkContentID = @ContentID AND
		fkLanguageBranchID = @LangBranchID AND 
		Status = 4 AND
		pkID<>@WorkContentID

	/* Remember that this version has been published, and clear the delay publish date if used */
	UPDATE
		tblWorkContent
	SET
		Status = 4,
		ChangedOnPublish = 0,
		Saved=@PublishedDate,
		NewStatusByName=@UserName,
		fkMasterVersionID = NULL,
		DelayPublishUntil = NULL,
		StartPublish = COALESCE(StartPublish, @PublishedDate)
	WHERE
		pkID=@WorkContentID
		
	/* Remove all properties defined for this Content except dynamic properties */
	DELETE FROM 
		tblContentProperty
	FROM 
		tblContentProperty
	INNER JOIN
		tblPropertyDefinition ON fkPropertyDefinitionID=tblPropertyDefinition.pkID
	WHERE 
		fkContentID=@ContentID AND
		fkContentTypeID IS NOT NULL AND
		fkLanguageBranchID=@LangBranchID
		
	/* Move properties from worktable to published table */
	INSERT INTO tblContentProperty 
		(fkPropertyDefinitionID,
		fkContentID,
		fkLanguageBranchID,
		ScopeName,
		[guid],
		Boolean,
		Number,
		FloatNumber,
		ContentType,
		ContentLink,
		Date,
		String,
		LongString,
		LongStringLength,
        LinkGuid)
	SELECT
		fkPropertyDefinitionID,
		@ContentID,
		@LangBranchID,
		ScopeName,
		[guid],
		Boolean,
		Number,
		FloatNumber,
		ContentType,
		ContentLink,
		Date,
		String,
		LongString,
		/* LongString is utf-16 - Datalength gives bytes, i e div by 2 gives characters */
		/* Include length to handle delayed loading of LongString with threshold */
		COALESCE(DATALENGTH(LongString), 0) / 2,
        LinkGuid
	FROM
		tblWorkContentProperty
	WHERE
		fkWorkContentID=@WorkContentID
	
	/* Move categories to published tables */
	DELETE 	tblContentCategory
	FROM tblContentCategory
	LEFT JOIN tblPropertyDefinition ON tblPropertyDefinition.pkID=tblContentCategory.CategoryType 
	WHERE 	tblContentCategory.fkContentID=@ContentID
			AND (NOT fkContentTypeID IS NULL OR CategoryType=0)
			AND (tblPropertyDefinition.LanguageSpecific>2 OR @IsMasterLang=1)--Only lang specific on non-master
			AND tblContentCategory.fkLanguageBranchID=@LangBranchID
			
	INSERT INTO tblContentCategory
		(fkContentID,
		fkCategoryID,
		CategoryType,
		fkLanguageBranchID,
		ScopeName)
	SELECT
		@ContentID,
		fkCategoryID,
		CategoryType,
		@LangBranchID,
		ScopeName
	FROM
		tblWorkContentCategory
	WHERE
		fkWorkContentID=@WorkContentID
	
	IF @ResetCommonDraft = 1
		EXEC editSetCommonDraftVersion @WorkContentID = @WorkContentID, @Force = 1				

	IF (@TrimVersions = 1)
        DELETE FROM tblWorkContent WHERE fkContentID = @ContentID AND fkLanguageBranchID = @LangBranchID AND Status = 5

END
GO
PRINT N'Altering [dbo].[sp_DatabaseVersion]...';


GO
ALTER PROCEDURE [dbo].[sp_DatabaseVersion]
AS
	RETURN 7051
GO
PRINT N'Creating [dbo].[netVersionObsoleteList]...';


GO
CREATE PROCEDURE [dbo].[netVersionObsoleteList]
(
	@MaxVersions int,
    @MaxCount int = 100
)
AS
    DECLARE @PreviouslyPublished TABLE
    (
        ContentID int, 
        LanguageBranchID int,
        PreviouslyPublishedCount int,
		RowNumber int
    )

	DECLARE @ObsoletedVersions TABLE
    (
	    WorkID int,
        ContentID int,
        Name NVARCHAR(255),
        VersionStatus int,
        ItemCreated DATETIME,
        SavedBy NVARCHAR(255),
        StatusChangedBy NVARCHAR(255),
        MasterVersion int,
        LanguageBranchID int,
        IsMasterLanguageBranch bit,
        CommonDraft bit,
        DelayPublishUntil DATETIME
    )

    INSERT INTO @PreviouslyPublished SELECT fkContentID, fkLanguageBranchID, COUNT(pkID),
		ROW_NUMBER() OVER(ORDER BY fkContentID DESC) AS ROW
        FROM tblWorkContent WHERE Status = 5
        GROUP BY fkContentID, fkLanguageBranchID 
        HAVING COUNT(pkID) > @MaxVersions

	DECLARE @COUNTER INT = (SELECT MAX(RowNumber) FROM @PreviouslyPublished);
	DECLARE @CURRENTVERSIONS INT;
    DECLARE @CURRENTCONTENT INT;
    DECLARE @CURRENTLANGUAGE INT;

	WHILE (@COUNTER != 0 AND (SELECT COUNT(*) FROM @ObsoletedVersions) < @MaxCount)
	BEGIN
		SELECT @CURRENTVERSIONS = PreviouslyPublishedCount,
            @CURRENTCONTENT = ContentID,
            @CURRENTLANGUAGE = LanguageBranchID
        FROM @PreviouslyPublished WHERE RowNumber = @COUNTER

		INSERT INTO @ObsoletedVersions
		SELECT TOP(@CURRENTVERSIONS - @MaxVersions) 
            W.pkID AS WorkID, 
            W.fkContentID AS ContentID, 
            W.Name,
            W.Status, 
            W.Saved AS ItemCreated, 
            W.ChangedByName AS SavedBy, 
            W.NewStatusByName AS StatusChangedBy,
            W.fkMasterVersionID AS MasterVersion, 
            W.fkLanguageBranchID AS LanguageBranchID, 
            CASE WHEN C.fkMasterLanguageBranchID=W.fkLanguageBranchID THEN 1 ELSE 0 END AS IsMasterLanguageBranch,
            W.CommonDraft,
            W.DelayPublishUntil
		FROM tblWorkContent AS W
			INNER JOIN
			tblContent AS C ON C.pkID=W.fkContentID
		WHERE W.fkContentID = @CURRENTCONTENT AND W.Status = 5 AND W.fkLanguageBranchID = @CURRENTLANGUAGE
		ORDER BY W.pkID ASC

		SET @COUNTER = @COUNTER -1
	END
	
	SELECT * FROM @ObsoletedVersions

    SELECT SUM(PreviouslyPublishedCount - @MaxVersions) AS TotalCount FROM @PreviouslyPublished

RETURN 0
GO
PRINT N'Update complete.';


GO
