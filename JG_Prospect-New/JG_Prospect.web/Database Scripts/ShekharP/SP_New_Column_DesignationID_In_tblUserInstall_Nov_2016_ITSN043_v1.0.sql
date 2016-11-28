USE [JGBS_Interview]
GO
ALTER TABLE [dbo].[tblInstallUsers] ADD [DesignationID] INT NULL;
ALTER TABLE [dbo].[tblInstallUsers] ADD CONSTRAINT FK_tblInstallUsers_DesignationID_tbl_Designation_ID 
FOREIGN KEY (DesignationID) REFERENCES [dbo].[tbl_Designation](ID);
GO