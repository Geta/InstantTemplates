--beginvalidatingquery
	if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_DatabaseVersion]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
    begin
            declare @ver int
            exec @ver=sp_DatabaseVersion
            if (@ver >= 7053)
				select 0, 'Already correct database version'
            else if (@ver = 7052)
                 select 1, 'Upgrading database'
            else
                 select -1, 'Invalid database version detected'
    end
    else
            select -1, 'Not an EPiServer database'
--endvalidatingquery

PRINT N'Altering [dbo].[tblContentProperty]...';
GO
ALTER TABLE [dbo].[tblContentProperty] DROP CONSTRAINT [PK_tblContentProperty]
GO
ALTER TABLE [dbo].[tblContentProperty] ALTER COLUMN [pkID] bigint NOT NULL
GO
ALTER TABLE [dbo].[tblContentProperty] ADD CONSTRAINT [PK_tblContentProperty] PRIMARY KEY NONCLUSTERED ([pkID] ASC)
GO

PRINT N'Altering [dbo].[tblWorkContentProperty]...';
GO
ALTER TABLE [dbo].[tblWorkContentProperty] DROP CONSTRAINT [PK_tblWorkProperty]
GO
ALTER TABLE [dbo].[tblWorkContentProperty] ALTER COLUMN [pkID] bigint NOT NULL
GO
ALTER TABLE [dbo].[tblWorkContentProperty] ADD CONSTRAINT [PK_tblWorkProperty] PRIMARY KEY NONCLUSTERED ([pkID] ASC)
GO

PRINT N'Altering [dbo].[sp_DatabaseVersion]...';
GO
ALTER PROCEDURE [dbo].[sp_DatabaseVersion]
AS
	RETURN 7053
GO

PRINT N'Update complete.';
GO
