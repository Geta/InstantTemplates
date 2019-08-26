--beginvalidatingquery
	if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_DatabaseVersion]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
    begin
            declare @ver int
            exec @ver=sp_DatabaseVersion
            if (@ver >= 7049)
				select 0, 'Already correct database version'
            else if (@ver = 7048)
                 select 1, 'Upgrading database'
            else
                 select -1, 'Invalid database version detected'
    end
    else
            select -1, 'Not an EPiServer database'
--endvalidatingquery
GO

--Update property types
 UPDATE tblPropertyDefinitionType SET AssemblyName = 'EPiServer.XForms' WHERE TypeName = 'EPiServer.Core.PropertyXForm' AND AssemblyName = 'EPiServer'
 GO

 --Update known types in DDS
 UPDATE tblBigTable SET ItemType = 'EPiServer.Personalization.VisitorGroups.Criteria.ViewedCategoriesModel, EPiServer.Cms.AspNet' WHERE StoreName = 'EPiServer.Personalization.VisitorGroups.Criteria.ViewedCategoriesModel'
 UPDATE tblBigTable SET ItemType = 'EPiServer.Personalization.VisitorGroups.Criteria.GeographicCoordinateModel, EPiServer.Cms.AspNet' WHERE StoreName = 'EPiServer.Personalization.VisitorGroups.Criteria.GeographicCoordinateModel'
 UPDATE tblBigTable SET ItemType = 'EPiServer.Personalization.VisitorGroups.Criteria.GeographicLocationModel, EPiServer.Cms.AspNet' WHERE StoreName = 'EPiServer.Personalization.VisitorGroups.Criteria.GeographicLocationModel'
 UPDATE tblBigTable SET ItemType = 'EPiServer.Personalization.VisitorGroups.Criteria.NumberOfVisitsModel, EPiServer.Cms.AspNet' WHERE StoreName = 'EPiServer.Personalization.VisitorGroups.Criteria.NumberOfVisitsModel'
 UPDATE tblBigTable SET ItemType = 'EPiServer.Personalization.VisitorGroups.Criteria.ReferrerModel, EPiServer.Cms.AspNet' WHERE StoreName = 'EPiServer.Personalization.VisitorGroups.Criteria.ReferrerModel'
 UPDATE tblBigTable SET ItemType = 'EPiServer.Personalization.VisitorGroups.Criteria.SearchWordModel, EPiServer.Cms.AspNet' WHERE StoreName = 'EPiServer.Personalization.VisitorGroups.Criteria.SearchWordModel'
 UPDATE tblBigTable SET ItemType = 'EPiServer.Personalization.VisitorGroups.Criteria.StartUrlModel, EPiServer.Cms.AspNet' WHERE StoreName = 'EPiServer.Personalization.VisitorGroups.Criteria.StartUrlModel'
 UPDATE tblBigTable SET ItemType = 'EPiServer.Personalization.VisitorGroups.Criteria.TimeOfDayModel, EPiServer.Cms.AspNet' WHERE StoreName = 'EPiServer.Personalization.VisitorGroups.Criteria.TimeOfDayModel'
 UPDATE tblBigTable SET ItemType = 'EPiServer.Personalization.VisitorGroups.Criteria.UserProfileModel, EPiServer.Cms.AspNet' WHERE StoreName = 'EPiServer.Personalization.VisitorGroups.Criteria.UserProfileModel'
 UPDATE tblBigTable SET ItemType = 'EPiServer.Personalization.VisitorGroups.Criteria.ViewedPagesModel, EPiServer.Cms.AspNet' WHERE StoreName = 'EPiServer.Personalization.VisitorGroups.Criteria.ViewedPagesModel'
 UPDATE tblBigTable SET ItemType = 'EPiServer.Personalization.VisitorGroups.Criteria.VisitorGroupMembershipModel, EPiServer.Cms.AspNet' WHERE StoreName = 'EPiServer.Personalization.VisitorGroups.Criteria.VisitorGroupMembershipModel'
 UPDATE tblBigTable SET ItemType = 'EPiServer.Personalization.VisitorGroups.Criteria.PageInfo, EPiServer.Cms.AspNet' WHERE StoreName = 'EPiServer.Personalization.VisitorGroups.Criteria.PageInfo'
 UPDATE tblBigTable SET ItemType = 'EPiServer.Web.PropertyControls.PropertySettings.MultipleOptionsListSettings, EPiServer.Cms.AspNet' WHERE StoreName = 'EPiServer.Web.PropertyControls.PropertySettings.MultipleOptionsListSettings'

 UPDATE tblSystemBigTable SET ItemType = 'EPiServer.MirroringService.MirroringData, EPiServer.Cms.AspNet' WHERE StoreName = 'EPiServer.MirroringService.MirroringData'
 UPDATE tblSystemBigTable SET ItemType = 'EPiServer.Editor.TinyMCE.TinyMCESettings, EPiServer.Cms.TinyMce' WHERE StoreName = 'EPiServer.Editor.TinyMCE.TinyMCESettings'
 UPDATE tblSystemBigTable SET ItemType = 'EPiServer.Editor.TinyMCE.ToolbarRow, EPiServer.Cms.TinyMce' WHERE StoreName = 'EPiServer.Editor.TinyMCE.ToolbarRow'

 UPDATE tblBigTableReference SET ElementType = 'EPiServer.Personalization.VisitorGroups.Criteria.ViewedCategoriesModel, EPiServer.Cms.AspNet' WHERE ElementStoreName = 'EPiServer.Personalization.VisitorGroups.Criteria.ViewedCategoriesModel'
 UPDATE tblBigTableReference SET ElementType = 'EPiServer.Personalization.VisitorGroups.Criteria.GeographicCoordinateModel, EPiServer.Cms.AspNet' WHERE ElementStoreName = 'EPiServer.Personalization.VisitorGroups.Criteria.GeographicCoordinateModel'
 UPDATE tblBigTableReference SET ElementType = 'EPiServer.Personalization.VisitorGroups.Criteria.GeographicLocationModel, EPiServer.Cms.AspNet' WHERE ElementStoreName = 'EPiServer.Personalization.VisitorGroups.Criteria.GeographicLocationModel'
 UPDATE tblBigTableReference SET ElementType = 'EPiServer.Personalization.VisitorGroups.Criteria.NumberOfVisitsModel, EPiServer.Cms.AspNet' WHERE ElementStoreName = 'EPiServer.Personalization.VisitorGroups.Criteria.NumberOfVisitsModel'
 UPDATE tblBigTableReference SET ElementType = 'EPiServer.Personalization.VisitorGroups.Criteria.ReferrerModel, EPiServer.Cms.AspNet' WHERE ElementStoreName = 'EPiServer.Personalization.VisitorGroups.Criteria.ReferrerModel'
 UPDATE tblBigTableReference SET ElementType = 'EPiServer.Personalization.VisitorGroups.Criteria.SearchWordModel, EPiServer.Cms.AspNet' WHERE ElementStoreName = 'EPiServer.Personalization.VisitorGroups.Criteria.SearchWordModel'
 UPDATE tblBigTableReference SET ElementType = 'EPiServer.Personalization.VisitorGroups.Criteria.StartUrlModel, EPiServer.Cms.AspNet' WHERE ElementStoreName = 'EPiServer.Personalization.VisitorGroups.Criteria.StartUrlModel'
 UPDATE tblBigTableReference SET ElementType = 'EPiServer.Personalization.VisitorGroups.Criteria.TimeOfDayModel, EPiServer.Cms.AspNet' WHERE ElementStoreName = 'EPiServer.Personalization.VisitorGroups.Criteria.TimeOfDayModel'
 UPDATE tblBigTableReference SET ElementType = 'EPiServer.Personalization.VisitorGroups.Criteria.UserProfileModel, EPiServer.Cms.AspNet' WHERE ElementStoreName = 'EPiServer.Personalization.VisitorGroups.Criteria.UserProfileModel'
 UPDATE tblBigTableReference SET ElementType = 'EPiServer.Personalization.VisitorGroups.Criteria.ViewedPagesModel, EPiServer.Cms.AspNet' WHERE ElementStoreName = 'EPiServer.Personalization.VisitorGroups.Criteria.ViewedPagesModel'
 UPDATE tblBigTableReference SET ElementType = 'EPiServer.Personalization.VisitorGroups.Criteria.VisitorGroupMembershipModel, EPiServer.Cms.AspNet' WHERE ElementStoreName = 'EPiServer.Personalization.VisitorGroups.Criteria.VisitorGroupMembershipModel'
 UPDATE tblBigTableReference SET ElementType = 'EPiServer.Personalization.VisitorGroups.Criteria.PageInfo, EPiServer.Cms.AspNet' WHERE ElementStoreName = 'EPiServer.Personalization.VisitorGroups.Criteria.PageInfo'
 UPDATE tblBigTableReference SET ElementType = 'EPiServer.Editor.TinyMCE.TinyMCESettings, EPiServer.Cms.TinyMce' WHERE ElementStoreName = 'EPiServer.Editor.TinyMCE.TinyMCESettings'
 UPDATE tblBigTableReference SET ElementType = 'EPiServer.Editor.TinyMCE.ToolbarRow, EPiServer.Cms.TinyMce' WHERE ElementStoreName = 'EPiServer.Editor.TinyMCE.ToolbarRow'
 UPDATE tblBigTableReference SET CollectionType = 'System.Collections.Generic.List`1[[EPiServer.Editor.TinyMCE.ToolbarRow, EPiServer.Cms.TinyMce]], mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089' WHERE PropertyName = 'ToolbarRows' AND CollectionType LIKE '%EPiServer.Editor.TinyMCE.ToolbarRow, EPiServer%'
 UPDATE tblBigTableReference SET ElementType = 'EPiServer.Web.PropertyControls.PropertySettings.MultipleOptionsListSettings, EPiServer.Cms.AspNet' WHERE ElementStoreName = 'EPiServer.Web.PropertyControls.PropertySettings.MultipleOptionsListSettings'

 UPDATE tblBigTableStoreInfo SET PropertyType = 'EPiServer.Personalization.VisitorGroups.Criteria.VisitorGroupMembershipStatus, EPiServer.Cms.AspNet' WHERE PropertyType LIKE 'EPiServer.Personalization.VisitorGroups.Criteria.VisitorGroupMembershipStatus%'
 UPDATE tblBigTableStoreInfo SET PropertyType = 'EPiServer.Personalization.VisitorGroups.MatchStringType, EPiServer.Cms.AspNet' WHERE PropertyType LIKE 'EPiServer.Personalization.VisitorGroups.MatchStringType%'
 UPDATE tblBigTableStoreInfo SET PropertyType = 'EPiServer.Personalization.VisitorGroups.Criteria.ReferrerType, EPiServer.Cms.AspNet' WHERE PropertyType LIKE 'EPiServer.Personalization.VisitorGroups.Criteria.ReferrerType%'
 UPDATE tblBigTableStoreInfo SET PropertyType = 'EPiServer.Personalization.VisitorGroups.Criteria.TimeFrame, EPiServer.Cms.AspNet' WHERE PropertyType LIKE 'EPiServer.Personalization.VisitorGroups.Criteria.TimeFrame%'
 UPDATE tblBigTableStoreInfo SET PropertyType = 'EPiServer.Personalization.VisitorGroups.Criteria.TimePeriod, EPiServer.Cms.AspNet' WHERE PropertyType LIKE 'EPiServer.Personalization.VisitorGroups.Criteria.TimePeriod%'
 UPDATE tblBigTableStoreInfo SET PropertyType = 'EPiServer.Personalization.VisitorGroups.Criteria.ComparisonType, EPiServer.Cms.AspNet' WHERE PropertyType LIKE 'EPiServer.Personalization.VisitorGroups.Criteria.ComparisonType%'
 UPDATE tblBigTableStoreInfo SET PropertyType = 'EPiServer.Personalization.VisitorGroups.Criteria.PageInfo, EPiServer.Cms.AspNet' WHERE PropertyType LIKE 'EPiServer.Personalization.VisitorGroups.Criteria.PageInfo%'
 UPDATE tblBigTableStoreInfo SET PropertyType = 'EPiServer.Personalization.VisitorGroups.Criteria.DistanceUnit, EPiServer.Cms.AspNet' WHERE PropertyType LIKE 'EPiServer.Personalization.VisitorGroups.Criteria.DistanceUnit%'
 UPDATE tblBigTableStoreInfo SET PropertyType = 'EPiServer.MirroringService.MirroringData+ItemChangingState, EPiServer.Cms.AspNet' WHERE PropertyType LIKE 'EPiServer.MirroringService.MirroringData+ItemChangingState%'
 UPDATE tblBigTableStoreInfo SET PropertyType = 'EPiServer.MirroringService.MirroringTransferProtocol.Common.MirroringState, EPiServer.Cms.AspNet' WHERE PropertyType LIKE 'EPiServer.MirroringService.MirroringTransferProtocol.Common.MirroringState%'
 UPDATE tblBigTableStoreInfo SET PropertyType = 'EPiServer.MirroringService.MirroringTransferProtocol.Common.MirroringTransferAction, EPiServer.Cms.AspNet' WHERE PropertyType LIKE 'EPiServer.MirroringService.MirroringTransferProtocol.Common.MirroringTransferAction%'
 UPDATE tblBigTableStoreInfo SET PropertyType = 'EPiServer.MirroringService.MirroringTransferProtocol.Common.ValidationContext, EPiServer.Cms.AspNet' WHERE PropertyType LIKE 'EPiServer.MirroringService.MirroringTransferProtocol.Common.ValidationContext%'
 UPDATE tblBigTableStoreInfo SET PropertyType = 'System.Collections.Generic.IList`1[[EPiServer.Editor.TinyMCE.ToolbarRow, EPiServer.Cms.TinyMce]], mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089' WHERE  PropertyName = 'ToolbarRows' AND PropertyType LIKE '%EPiServer.Editor.TinyMCE.ToolbarRow, EPiServer%'                                                                                                                                                                                                                                                                                       

IF EXISTS(select * FROM sys.views where name = 'VW_VisitorGroupCriterion') 
BEGIN
	UPDATE [VW_VisitorGroupCriterion] SET TypeName = 'EPiServer.Personalization.VisitorGroups.Criteria.ViewedCategoriesCriterion, EPiServer.Cms.AspNet' WHERE TypeName = 'EPiServer.Personalization.VisitorGroups.Criteria.ViewedCategoriesCriterion, EPiServer'
	UPDATE [VW_VisitorGroupCriterion] SET TypeName = 'EPiServer.Personalization.VisitorGroups.Criteria.GeographicLocationCriterion, EPiServer.Cms.AspNet' WHERE TypeName = 'EPiServer.Personalization.VisitorGroups.Criteria.GeographicLocationCriterion, EPiServer'
	UPDATE [VW_VisitorGroupCriterion] SET TypeName = 'EPiServer.Personalization.VisitorGroups.Criteria.GeographicCoordinateCriterion, EPiServer.Cms.AspNet' WHERE TypeName = 'EPiServer.Personalization.VisitorGroups.Criteria.GeographicCoordinateCriterion, EPiServer'
	UPDATE [VW_VisitorGroupCriterion] SET TypeName = 'EPiServer.Personalization.VisitorGroups.Criteria.NumberOfVisitsCriterion, EPiServer.Cms.AspNet' WHERE TypeName = 'EPiServer.Personalization.VisitorGroups.Criteria.NumberOfVisitsCriterion, EPiServer'
	UPDATE [VW_VisitorGroupCriterion] SET TypeName = 'EPiServer.Personalization.VisitorGroups.Criteria.ReferrerCriterion, EPiServer.Cms.AspNet' WHERE TypeName = 'EPiServer.Personalization.VisitorGroups.Criteria.ReferrerCriterion, EPiServer'
	UPDATE [VW_VisitorGroupCriterion] SET TypeName = 'EPiServer.Personalization.VisitorGroups.Criteria.SearchWordReferrerCriterion, EPiServer.Cms.AspNet' WHERE TypeName = 'EPiServer.Personalization.VisitorGroups.Criteria.SearchWordReferrerCriterion, EPiServer'
	UPDATE [VW_VisitorGroupCriterion] SET TypeName = 'EPiServer.Personalization.VisitorGroups.Criteria.ReferrerCriterion, EPiServer.Cms.AspNet' WHERE TypeName = 'EPiServer.Personalization.VisitorGroups.Criteria.ReferrerCriterion, EPiServer'
	UPDATE [VW_VisitorGroupCriterion] SET TypeName = 'EPiServer.Personalization.VisitorGroups.Criteria.StartUrlCriterion, EPiServer.Cms.AspNet' WHERE TypeName = 'EPiServer.Personalization.VisitorGroups.Criteria.StartUrlCriterion, EPiServer'
	UPDATE [VW_VisitorGroupCriterion] SET TypeName = 'EPiServer.Personalization.VisitorGroups.Criteria.TimeOfDayCriterion, EPiServer.Cms.AspNet' WHERE TypeName = 'EPiServer.Personalization.VisitorGroups.Criteria.TimeOfDayCriterion, EPiServer'
	UPDATE [VW_VisitorGroupCriterion] SET TypeName = 'EPiServer.Personalization.VisitorGroups.Criteria.UserProfileCriterion, EPiServer.Cms.AspNet' WHERE TypeName = 'EPiServer.Personalization.VisitorGroups.Criteria.UserProfileCriterion, EPiServer'
	UPDATE [VW_VisitorGroupCriterion] SET TypeName = 'EPiServer.Personalization.VisitorGroups.Criteria.ViewedPagesCriterion, EPiServer.Cms.AspNet' WHERE TypeName = 'EPiServer.Personalization.VisitorGroups.Criteria.ViewedPagesCriterion, EPiServer'
	UPDATE [VW_VisitorGroupCriterion] SET TypeName = 'EPiServer.Personalization.VisitorGroups.Criteria.VisitorGroupMembershipCriterion, EPiServer.Cms.AspNet' WHERE TypeName = 'EPiServer.Personalization.VisitorGroups.Criteria.VisitorGroupMembershipCriterion, EPiServer'
END
GO

 --Update scheduled jobs
 UPDATE tblScheduledItem SET AssemblyName = 'EPiServer.Cms.AspNet' WHERE TypeName = 'EPiServer.Enterprise.Mirroring.MirroringManager' AND AssemblyName = 'EPiServer.Enterprise'
 UPDATE tblScheduledItem SET AssemblyName = 'EPiServer.Cms.AspNet' WHERE TypeName = 'EPiServer.Personalization.SubscriptionJob' AND AssemblyName = 'EPiServer'
 UPDATE tblScheduledItem SET AssemblyName = 'EPiServer.Cms.AspNet' WHERE TypeName = 'EPiServer.Util.ThumbnailPropertiesClearJob' AND AssemblyName = 'EPiServer'
 GO

PRINT N'Altering [dbo].[netReportChangedPages]...';


GO
-- Return a list of pages in a particular branch of the tree changed between a start date and a stop date
ALTER PROCEDURE [dbo].[netReportChangedPages](
	@PageID int,
	@StartDate datetime,
	@StopDate datetime,
	@Language int = -1,
	@ChangedByUserName nvarchar(256) = null,
	@PageSize int,
	@PageNumber int = 0,
	@SortColumn varchar(40) = 'Saved',
	@SortDescending bit = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @OrderBy NVARCHAR(MAX)
	SET @OrderBy =
		CASE @SortColumn
			WHEN 'PageName' THEN 'tblPageLanguage.Name'
			WHEN 'ChangedBy' THEN 'tblPageLanguage.ChangedByName'
			WHEN 'Saved' THEN 'tblPageLanguage.Saved'
			WHEN 'Language' THEN 'tblLanguageBranch.LanguageID'
			WHEN 'PageTypeName' THEN 'tblPageType.Name'
		END
	IF(@SortDescending = 1)
		SET @OrderBy = @OrderBy + ' DESC'
		
	DECLARE @sql NVARCHAR(MAX)
	Set @sql = 'WITH PageCTE AS
	(
		SELECT ROW_NUMBER() OVER(ORDER BY '
			+ @OrderBy
			+ ') AS rownum,
		tblPageLanguage.fkPageID, tblPageLanguage.Version AS PublishedVersion, count(*) over () as totcount
		FROM tblPageLanguage 
		INNER JOIN tblTree ON tblTree.fkChildID=tblPageLanguage.fkPageID 
		INNER JOIN tblPage ON tblPage.pkID=tblPageLanguage.fkPageID 
		INNER JOIN tblPageType ON tblPageType.pkID=tblPage.fkPageTypeID 
		INNER JOIN tblLanguageBranch ON tblLanguageBranch.pkID=tblPageLanguage.fkLanguageBranchID 
		WHERE (tblTree.fkParentID=@PageID OR (tblPageLanguage.fkPageID=@PageID AND tblTree.NestingLevel = 1 ))
        AND (@StartDate IS NULL OR tblPageLanguage.Saved >= @StartDate)
        AND (@StopDate IS NULL OR tblPageLanguage.Saved <= @StopDate)
        AND (@Language = -1 OR tblPageLanguage.fkLanguageBranchID = @Language)
        AND (@ChangedByUserName IS NULL OR tblPageLanguage.ChangedByName = @ChangedByUserName)
        AND (@ChangedByUserName IS NULL OR tblPageLanguage.ChangedByName = @ChangedByUserName)
        AND tblPage.ContentType = 0
        AND tblPageLanguage.Status=4
	)
	SELECT PageCTE.fkPageID, PageCTE.PublishedVersion, PageCTE.rownum, totcount
	FROM PageCTE
	WHERE rownum > @PageSize * (@PageNumber)
	AND rownum <= @PageSize * (@PageNumber+1)
	ORDER BY rownum'
	
	EXEC sp_executesql @sql, N'@PageID int, @StartDate datetime, @StopDate datetime, @Language int, @ChangedByUserName nvarchar(256), @PageSize int, @PageNumber int',
		@PageID = @PageID, 
		@StartDate = @StartDate, 
		@StopDate = @StopDate, 
		@Language = @Language, 
		@ChangedByUserName = @ChangedByUserName, 
		@PageSize = @PageSize, 
		@PageNumber = @PageNumber
END
GO
PRINT N'Altering [dbo].[netReportExpiredPages]...';


GO
-- Returns a list of pages which will expire between the supplied dates in a particular branch of the tree.
ALTER PROCEDURE [dbo].[netReportExpiredPages](
	@PageID int,
	@StartDate datetime,
	@StopDate datetime,
	@Language int = -1,
	@PageSize int,
	@PageNumber int = 0,
	@SortColumn varchar(40) = 'StopPublish',
	@SortDescending bit = 0,
	@PublishedByName nvarchar(256) = null
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @OrderBy NVARCHAR(MAX)
	SET @OrderBy =
		CASE @SortColumn
			WHEN 'PageName' THEN 'tblPageLanguage.Name'
			WHEN 'StartPublish' THEN 'tblPageLanguage.StartPublish'
			WHEN 'StopPublish' THEN 'tblPageLanguage.StopPublish'
			WHEN 'ChangedBy' THEN 'tblPageLanguage.ChangedByName'
			WHEN 'Saved' THEN 'tblPageLanguage.Saved'
			WHEN 'Language' THEN 'tblLanguageBranch.LanguageID'
			WHEN 'PageTypeName' THEN 'tblPageType.Name'
		END
	IF(@SortDescending = 1)
		SET @OrderBy = @OrderBy + ' DESC'

    DECLARE @sql NVARCHAR(MAX)
	SET @sql = 'WITH PageCTE AS
    (
        SELECT ROW_NUMBER() OVER(ORDER BY ' 
			+ @OrderBy 
			+ ') AS rownum,
        tblPageLanguage.fkPageID, tblPageLanguage.Version AS PublishedVersion, count(tblPageLanguage.fkPageID) over () as totcount                        
        FROM tblPageLanguage 
        INNER JOIN tblTree ON tblTree.fkChildID=tblPageLanguage.fkPageID 
        INNER JOIN tblPage ON tblPage.pkID=tblPageLanguage.fkPageID 
        INNER JOIN tblPageType ON tblPageType.pkID=tblPage.fkPageTypeID 
        INNER JOIN tblLanguageBranch ON tblLanguageBranch.pkID=tblPageLanguage.fkLanguageBranchID 
        WHERE 
        (tblTree.fkParentID = @PageID OR (tblPageLanguage.fkPageID = @PageID AND tblTree.NestingLevel = 1))
        AND 
        (@StartDate IS NULL OR tblPageLanguage.StopPublish >= @StartDate)
        AND
        (@StopDate IS NULL OR tblPageLanguage.StopPublish <= @StopDate)
		AND
		(@Language = -1 OR tblPageLanguage.fkLanguageBranchID = @Language)
        AND tblPage.ContentType = 0
		AND tblPageLanguage.Status=4
		AND
		(@PublishedByName IS NULL OR tblPageLanguage.ChangedByName = @PublishedByName)
    )
    SELECT PageCTE.fkPageID, PageCTE.PublishedVersion, PageCTE.rownum, totcount
    FROM PageCTE
    WHERE rownum > @PageSize * (@PageNumber)
    AND rownum <= @PageSize * (@PageNumber+1)
    ORDER BY rownum'
    
    EXEC sp_executesql @sql, N'@PageID int, @StartDate datetime, @StopDate datetime, @Language int, @PublishedByName nvarchar(256), @PageSize int, @PageNumber int',
		@PageID = @PageID, 
		@StartDate = @StartDate, 
		@StopDate = @StopDate, 
		@Language = @Language, 
		@PublishedByName = @PublishedByName, 
		@PageSize = @PageSize, 
		@PageNumber = @PageNumber
END
GO
PRINT N'Altering [dbo].[netReportPublishedPages]...';


GO
-- Return a list of pages in a particular branch of the tree published between a start date and a stop date
ALTER PROCEDURE [dbo].[netReportPublishedPages](
	@PageID int,
	@StartDate datetime,
	@StopDate datetime,
	@Language int = -1,
	@ChangedByUserName nvarchar(256) = null,
	@PageSize int,
	@PageNumber int = 0,
	@SortColumn varchar(40) = 'StartPublish',
	@SortDescending bit = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @OrderBy NVARCHAR(MAX)
	SET @OrderBy =
		CASE @SortColumn
			WHEN 'PageName' THEN 'tblPageLanguage.Name'
			WHEN 'StartPublish' THEN 'tblPageLanguage.StartPublish'
			WHEN 'StopPublish' THEN 'tblPageLanguage.StopPublish'
			WHEN 'ChangedBy' THEN 'tblPageLanguage.ChangedByName'
			WHEN 'Saved' THEN 'tblPageLanguage.Saved'
			WHEN 'Language' THEN 'tblLanguageBranch.LanguageID'
			WHEN 'PageTypeName' THEN 'tblPageType.Name'
		END
	IF(@SortDescending = 1)
		SET @OrderBy = @OrderBy + ' DESC'

	DECLARE @sql NVARCHAR(MAX)
	SET @sql = 'WITH PageCTE AS
	(
		SELECT ROW_NUMBER() OVER(ORDER BY ' 
			+ @OrderBy
			+ ') AS rownum,
		tblPageLanguage.fkPageID, tblPageLanguage.Version AS PublishedVersion, count(*) over () as totcount
		FROM tblPageLanguage 
		INNER JOIN tblTree ON tblTree.fkChildID=tblPageLanguage.fkPageID 
		INNER JOIN tblPage ON tblPage.pkID=tblPageLanguage.fkPageID 
		INNER JOIN tblPageType ON tblPageType.pkID=tblPage.fkPageTypeID 
		INNER JOIN tblLanguageBranch ON tblLanguageBranch.pkID=tblPageLanguage.fkLanguageBranchID
		WHERE
		(tblTree.fkParentID=@PageID OR (tblPageLanguage.fkPageID=@PageID AND tblTree.NestingLevel = 1 ))
        AND tblPage.ContentType = 0
		AND tblPageLanguage.Status=4
		AND 
		(@StartDate IS NULL OR tblPageLanguage.StartPublish >= @StartDate)
		AND
		(@StopDate IS NULL OR tblPageLanguage.StartPublish <= @StopDate)
		AND
		(@Language = -1 OR tblPageLanguage.fkLanguageBranchID = @Language)
		AND
		(@ChangedByUserName IS NULL OR tblPageLanguage.ChangedByName = @ChangedByUserName)
	)
	SELECT PageCTE.fkPageID, PageCTE.PublishedVersion, PageCTE.rownum, totcount
	FROM PageCTE
	WHERE rownum > @PageSize * (@PageNumber)
	AND rownum <= @PageSize * (@PageNumber+1)
	ORDER BY rownum'

	EXEC sp_executesql @sql, N'@PageID int, @StartDate datetime, @StopDate datetime, @Language int, @ChangedByUserName nvarchar(256), @PageSize int, @PageNumber int',
		@PageID = @PageID, 
		@StartDate = @StartDate, 
		@StopDate = @StopDate, 
		@Language = @Language, 
		@ChangedByUserName = @ChangedByUserName, 
		@PageSize = @PageSize, 
		@PageNumber = @PageNumber
	
END
GO
PRINT N'Altering [dbo].[netReportReadyToPublish]...';


GO
-- Return a list of pages in a particular branch of the tree published between a start date and a stop date
ALTER PROCEDURE [dbo].netReportReadyToPublish(
	@PageID int,
	@StartDate datetime,
	@StopDate datetime,
	@Language int = -1,
	@ChangedByUserName nvarchar(256) = null,
	@PageSize int,
	@PageNumber int = 0,
	@SortColumn varchar(40) = 'PageName',
	@SortDescending bit = 0,
	@IsReadyToPublish bit = 1
)
AS
BEGIN
	SET NOCOUNT ON;
	WITH PageCTE AS
    (
        SELECT ROW_NUMBER() OVER(ORDER BY 
			-- Page Name Sorting
			CASE WHEN @SortColumn = 'PageName' AND @SortDescending = 1 THEN tblWorkPage.Name END DESC,
			CASE WHEN @SortColumn = 'PageName' THEN tblWorkPage.Name END ASC,
			-- Saved Sorting
			CASE WHEN @SortColumn = 'Saved' AND @SortDescending = 1 THEN tblWorkPage.Saved END DESC,
			CASE WHEN @SortColumn = 'Saved' THEN tblWorkPage.Saved END ASC,
			-- StartPublish Sorting
			CASE WHEN @SortColumn = 'StartPublish' AND @SortDescending = 1 THEN tblWorkPage.StartPublish END DESC,
			CASE WHEN @SortColumn = 'StartPublish' THEN tblWorkPage.StartPublish END ASC,
			-- Changed By Sorting
			CASE WHEN @SortColumn = 'ChangedBy' AND @SortDescending = 1 THEN tblWorkPage.ChangedByName END DESC,
			CASE WHEN @SortColumn = 'ChangedBy' THEN tblWorkPage.ChangedByName END ASC,
			-- Language Sorting
			CASE WHEN @SortColumn = 'Language' AND @SortDescending = 1 THEN tblLanguageBranch.LanguageID END DESC,
			CASE WHEN @SortColumn = 'Language' THEN tblLanguageBranch.LanguageID END ASC
			, 
			tblWorkPage.pkID ASC
        ) AS rownum,
        tblWorkPage.fkPageID, count(tblWorkPage.fkPageID) over () as totcount,
        tblWorkPage.pkID as versionId
        FROM tblWorkPage 
        INNER JOIN tblTree ON tblTree.fkChildID=tblWorkPage.fkPageID 
        INNER JOIN tblPage ON tblPage.pkID=tblWorkPage.fkPageID 
		INNER JOIN tblLanguageBranch ON tblLanguageBranch.pkID=tblWorkPage.fkLanguageBranchID 
        WHERE 
			(tblTree.fkParentID=@PageID OR (tblWorkPage.fkPageID=@PageID AND tblTree.NestingLevel = 1 ))
        AND
			(@ChangedByUserName IS NULL OR tblWorkPage.ChangedByName = @ChangedByUserName)
        AND
			tblPage.ContentType = 0
        AND
			(@Language = -1 OR tblWorkPage.fkLanguageBranchID = @Language)
        AND 
			(@StartDate IS NULL OR tblWorkPage.Saved >= @StartDate)
        AND
			(@StopDate IS NULL OR tblWorkPage.Saved <= @StopDate)
        AND
			(tblWorkPage.ReadyToPublish = @IsReadyToPublish AND tblWorkPage.HasBeenPublished = 0)
    )
    SELECT PageCTE.fkPageID, PageCTE.rownum, totcount, PageCTE.versionId
    FROM PageCTE
    WHERE rownum > @PageSize * (@PageNumber)
    AND rownum <= @PageSize * (@PageNumber+1)
    ORDER BY rownum
END
GO
PRINT N'Altering [dbo].[editSetVersionStatus]...';


GO
ALTER PROCEDURE [dbo].[editSetVersionStatus]
(
	@WorkContentID INT,
	@Status INT,
	@UserName NVARCHAR(255),
	@Saved DATETIME = NULL,
	@RejectComment NVARCHAR(2000) = NULL,
	@DelayPublishUntil DateTime = NULL
)
AS
BEGIN
	SET NOCOUNT ON
	SET XACT_ABORT ON
	
	UPDATE 
		tblWorkContent
	SET
		Status = @Status,
		NewStatusByName=@UserName,
		RejectComment= COALESCE(@RejectComment, RejectComment),
		Saved = COALESCE(@Saved, Saved),
		DelayPublishUntil = @DelayPublishUntil
	WHERE
		pkID=@WorkContentID 

	IF (@@ROWCOUNT = 0)
		RETURN 1

	-- If there is no published version for this language update published table as well
	DECLARE @ContentID INT;
	DECLARE @LanguageBranchID INT;

	SELECT @LanguageBranchID = lang.fkLanguageBranchID, @ContentID = lang.fkContentID FROM tblContentLanguage AS lang INNER JOIN tblWorkContent AS work 
		ON lang.fkContentID = work.fkContentID WHERE 
		work.pkID = @WorkContentID AND work.fkLanguageBranchID = lang.fkLanguageBranchID AND lang.Status <> 4

	IF @ContentID IS NOT NULL
		BEGIN

			UPDATE
				tblContentLanguage
			SET
				Status = @Status,
				DelayPublishUntil = @DelayPublishUntil
			WHERE
				fkContentID=@ContentID AND fkLanguageBranchID=@LanguageBranchID

		END

	RETURN 0
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
	RETURN 7049
GO

PRINT N'Update complete.';
GO
