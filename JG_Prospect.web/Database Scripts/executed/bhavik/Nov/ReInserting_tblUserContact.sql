/*------------ INSERTING PHONE TYPE --------*/

TRUNCATE TABLE tblUserContact

  INSERT INTO [dbo].[tblUserContact]
           ([ContactName],[ContactValue],[ContactType],[AddedBy],[AddeOn])
     VALUES
           ('Cell Phone','CellPhone','PHONE',1,GETDATE())
GO
INSERT INTO [dbo].[tblUserContact]
           ([ContactName],[ContactValue],[ContactType],[AddedBy],[AddeOn])
     VALUES
           ('House Phone','HousePhone','PHONE',1,GETDATE())
GO

INSERT INTO [dbo].[tblUserContact]
           ([ContactName],[ContactValue],[ContactType],[AddedBy],[AddeOn])
     VALUES
           ('Work Phone','WorkPhone','PHONE',1,GETDATE())
GO

INSERT INTO [dbo].[tblUserContact]
           ([ContactName],[ContactValue],[ContactType],[AddedBy],[AddeOn])
     VALUES
           ('Alt. Phone','AltPhone','PHONE',1,GETDATE())
GO

INSERT INTO [dbo].[tblUserContact]
           ([ContactName],[ContactValue],[ContactType],[AddedBy],[AddeOn])
     VALUES
           ('skype','skype','PHONE',1,GETDATE())
GO

INSERT INTO [dbo].[tblUserContact]
           ([ContactName],[ContactValue],[ContactType],[AddedBy],[AddeOn])
     VALUES
           ('whatsapp','whatsapp','OTHER',1,GETDATE())

INSERT INTO [dbo].[tblUserContact]
           ([ContactName],[ContactValue],[ContactType],[AddedBy],[AddeOn])
     VALUES
           ('Other','Other','OTHER',1,GETDATE())
GO
GO