--beginvalidatingquery
	if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_DatabaseVersion]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
    begin
            declare @ver int
            exec @ver=sp_DatabaseVersion
            if (@ver >= 7054)
				select 0, 'Already correct database version'
            else if (@ver = 7053)
                 select 1, 'Upgrading database'
            else
                 select -1, 'Invalid database version detected'
    end
    else
            select -1, 'Not an EPiServer database'
--endvalidatingquery

CREATE NONCLUSTERED INDEX [IX_tblScheduledItemLog_fkScheduledItemId] ON [dbo].[tblScheduledItemLog] ([fkScheduledItemId]) 
GO

PRINT N'Altering [dbo].[sp_DatabaseVersion]...';
GO
ALTER PROCEDURE [dbo].[sp_DatabaseVersion]
AS
	RETURN 7054
GO

PRINT N'Update complete.';
GO
