USE [JGBS]
--USE [JGBS_Interview]
GO

/****** Object:  Table [dbo].[tblUserAuditTrail]    Script Date: 10/19/2016 11:34:50 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tblUserAuditTrail](
	[AuditID] [int] IDENTITY(1,1) NOT NULL,
	[UserLoginID] [varchar](260) NULL,
	[Description] [varchar](max) NULL,
	[LastLoginOn] [datetime] NULL,
	[LastActionOn] [datetime] NULL,
	[LogOutTime] [datetime] NULL,
	[LogInGuID] [varchar](40) NULL,
 CONSTRAINT [PK_tblUserAuditTrail] PRIMARY KEY CLUSTERED 
(
	[AuditID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO



/****** Object:  StoredProcedure [dbo].[SP_AddUpdateUserAuditRecord]    Script Date: 10/19/2016 11:37:32 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Bhavik Vaishnani
-- Create date: 19-oct-2106
-- Description:	To Insert / Update User Audit Entery
-- =============================================
CREATE PROCEDURE [dbo].[SP_AddUpdateUserAuditRecord] 
	-- Add the parameters for the stored procedure here
	@LogInGuID nvarchar (40), 
	@UserLoginID nvarchar (260),
	@Description nvarchar (260),
	@CurrentActionTime DateTime
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @AuditID INT;
	DECLARE @Delimiter varchar(5) = ' |:| ';


IF EXISTS (SELECT AuditID 
			FROM tblUserAuditTrail
			WHERE LogInGuID = @LogInGuID)
	BEGIN

	UPDATE [dbo].[tblUserAuditTrail]
    SET 
		[Description] = [Description] + ' || ' + CONVERT(VARCHAR(10), GETDATE(), 10) + ' ' + CONVERT(VARCHAR(8), GETDATE(), 108) + @Delimiter + @Description
		, [LastActionOn] = @CurrentActionTime
	        
	WHERE LogInGuID = @LogInGuID
	
	END
ELSE
	BEGIN

	INSERT INTO [dbo].[tblUserAuditTrail]
           ([UserLoginID]
           ,[Description]
           ,[LastLoginOn]
		   ,[LastActionOn]      
           ,[LogInGuID])
     VALUES
		(@UserLoginID
		, CONVERT(VARCHAR(10), GETDATE(), 10) + ' ' + CONVERT(VARCHAR(8), GETDATE(), 108) + @Delimiter + ' Login - ' + @Description
--		,' Login - ' + @Description
		,GETDATE()
		,GETDATE()
		,@LogInGuID)

	END

END

GO


/****** Object:  StoredProcedure [dbo].[SP_UpdateUserAuditLogOutTime]    Script Date: 10/19/2016 11:38:14 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Bhavik Vaishnani
-- Create date: 19-oct-2106
-- Description:	To Insert User Audit Entery Log out & Last Action time
-- =============================================
CREATE PROCEDURE [dbo].[SP_UpdateUserAuditLogOutTime]
	-- Add the parameters for the stored procedure here
	@LogInGuID nvarchar (40),
	@LogOutTime DateTime
AS
BEGIN
	SET NOCOUNT ON;

	 
	 UPDATE [dbo].[tblUserAuditTrail]
    SET 
		LogOutTime = @LogOutTime
		, LastLoginOn = @LogOutTime  
	WHERE LogInGuID = @LogInGuID
 

END

GO



/****** Object:  StoredProcedure [dbo].[SP_GetAuditTrailDataByLoginID]    Script Date: 10/19/2016 11:38:58 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Bhavik Vaishnani
-- Create date: 19 -Oct-2016
-- Description:	Will get Respective Audit List for User
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetAuditTrailDataByLoginID] 
	-- Add the parameters for the stored procedure here
	@UserLoginID varchar(260) 
	 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
	AuditID
	, Description
	, Format(LastLoginOn,'MM-dd-yy HH:MM:ss') As LastLoginOn
	, LastActionOn
	, LogOutTime
	, '1' AS PageVisitCount 
	, CASE  
		  WHEN DATEDIFF(DAY, LastLoginOn , GETDATE()) < 8 THEN ' dayTab' 
		  WHEN DATEDIFF(DAY, LastLoginOn , GETDATE()) < 31 THEN ' MonthTab' 
		  WHEN DATEDIFF(DAY, LastLoginOn , GETDATE()) < 92 THEN ' QTab' 
		  ELSE 'all' 
		END as TimeTabGrp
	
	, CONVERT(Varchar(20), DATEDIFF(SECOND, LastLoginOn , [LastActionOn])) AS TotalVisiteTime
	-- , CAST(([LogOutTime]-LastLoginOn) as time(0)) '[MM:SS]' 

	FROM tblUserAuditTrail 

		WHERE UserLoginID = @UserLoginID
	Order by LastLoginOn DESC
END

GO


