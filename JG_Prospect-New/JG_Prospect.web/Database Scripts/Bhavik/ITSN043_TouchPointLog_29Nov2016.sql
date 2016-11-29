USE [JGBS_Interview]
GO

/****** Object:  Table [dbo].[tblUserTouchPointLog]    Script Date: 11/29/2016 4:55:08 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tblUserTouchPointLog](
	[UserTouchPointLogID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NULL,
	[UpdatedByUserID] [int] NULL,
	[UpdatedUserInstallID] [varchar](50) NULL,
	[ChangeDateTime] [datetime] NULL,
	[LogDescription] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO







GO

/****** Object:  StoredProcedure [dbo].[Sp_InsertTouchPointLog]    Script Date: 11/29/2016 4:59:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Bhavik J. Vaishnani
-- Create date: 29-11-2016
-- Description:	Insert value of Touch Point log
-- =============================================
CREATE PROCEDURE [dbo].[Sp_InsertTouchPointLog] 
	-- Add the parameters for the stored procedure here
	@userID int = 0, 
	@loginUserID int = 0
	, @loginUserInstallID varchar (50) =''
	, @LogTime datetime
	, @changeLog varchar(max)	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO [dbo].[tblUserTouchPointLog]
           ([UserID]  ,[UpdatedByUserID] ,[UpdatedUserInstallID]
           ,[ChangeDateTime]
           ,[LogDescription])
     VALUES
           (@userID , @loginUserID ,@loginUserInstallID            
           , @LogTime
           ,@changeLog)
END

GO













 

/****** Object:  StoredProcedure [dbo].[Sp_GetTouchPointLogDataByUserID]    Script Date: 11/29/2016 4:56:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Bhavik J.
-- Create date: 29 - 11- 2016
-- Description:	Get Data of Touch Point Log
-- =============================================
CREATE PROCEDURE [dbo].[Sp_GetTouchPointLogDataByUserID]
	-- Add the parameters for the stored procedure here 
	@userID int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * from tblUserTouchPointLog where UserID = @userID
	
	END

GO


