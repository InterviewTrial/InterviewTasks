USE [JGBS_Interview]
GO

/****** Object:  Table [dbo].[tblUserContact]    Script Date: 11/16/2016 8:15:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tblUserContact](
	[UserContactID] [int] IDENTITY(1,1) NOT NULL,
	[ContactName] [varchar](50) NULL,
	[ContactValue] [varchar](50) NULL,
	[ContactType] [varchar](10) NULL,
	[AddedBy] [int] NULL,
	[AddeOn] [datetime] NULL,
 CONSTRAINT [PK_tblUserContact] PRIMARY KEY CLUSTERED 
(
	[UserContactID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO



 
/****** Object:  StoredProcedure [dbo].[SP_GetUserPhoneType]    Script Date: 11/16/2016 8:25:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Bhavik J. Vaishnani
-- Create date: 13 - 11- 2016
-- Description:	Get all the Value from User Contact
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetUserPhoneType] 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SELECT * FROM tblUserContact
    -- Insert statements for procedure here
	
END





GO
/****** Object:  StoredProcedure [dbo].[SP_AddNewPhoneType]    Script Date: 11/16/2016 8:31:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Bhavik
-- Create date: 14 - 11 -2016
-- Description:	Add New Phone Type
-- =============================================
CREATE PROCEDURE [dbo].[SP_AddNewPhoneType] 
	-- Add the parameters for the stored procedure here
	@NewPhoneType varchar(50) = '', 
	@AddedByID int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	INSERT INTO [dbo].[tblUserContact]
           ([ContactName]
           ,[ContactValue]
           ,[ContactType]
           ,[AddedBy]
           ,[AddeOn])
     VALUES
           (@NewPhoneType
           ,@NewPhoneType
           ,'Other'
           ,@AddedByID
           ,GETDATE())


	

    -- Insert statements for procedure here
	--SELECT @NewPhoneType, @AddedByID
END





GO

/****** Object:  Table [dbo].[tblUserDesigLastSequenceNo]    Script Date: 11/16/2016 8:33:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tblUserDesigLastSequenceNo](
	[UserDesigSequenceId] [int] IDENTITY(1,1) NOT NULL,
	[DesignationCode] [varchar](15) NULL,
	[LastSequenceNo] [int] NULL,
 CONSTRAINT [PK_UserDesigLastSequenceNo] PRIMARY KEY CLUSTERED 
(
	[UserDesigSequenceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


/*------  Added Col in tblInstallUser Table */

ALTER TABLE tblInstallUsers
ADD [UserInstallId] [varchar](50) NULL

GO

GO

/****** Object:  StoredProcedure [dbo].[USP_SetUserDisplayID]    Script Date: 11/16/2016 8:36:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Bhavik
-- Create date: 16 11 2016
-- Description:	Get Designation ID For a user
-- =============================================
CREATE PROCEDURE [dbo].[USP_SetUserDisplayID] 
	-- Add the parameters for the stored procedure here
	@InstallUserID int = 0, 
	@DesignationsCode varchar(15)	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @InstallId VARCHAR(50) = NULL

	SELECT @InstallId = UserInstallId
FROM tblInstallUsers
WHERE Id = @InstallUserID

IF @InstallId IS NULL
BEGIN
	-- get sequence of last entered task for perticular designation.
	DECLARE @DesSequence bigint

	SELECT @DesSequence = LastSequenceNo FROM tblUserDesigLastSequenceNo WHERE DesignationCode = @DesignationsCode

	-- if it is first time task is entered for designation start from 001.
	IF(@DesSequence IS NULL)
	BEGIN
		SET @DesSequence = 0  
	END

	SET @DesSequence = @DesSequence + 1  

	

	UPDATE tblInstallUsers
		SET UserInstallId = @DesignationsCode + Right('-A000' + CONVERT(NVARCHAR, @DesSequence), 6)
	WHERE Id = @InstallUserID
	

	-- INCREMENT SEQUENCE NUMBER FOR DESIGNATION TO USE NEXT TIME
	IF NOT EXISTS( 
					SELECT uds.UserDesigSequenceId 
					FROM dbo.tblUserDesigLastSequenceNo uds 
					WHERE uds.DesignationCode = @DesignationsCode 
				 )
	BEGIN

	INSERT INTO dbo.tblUserDesigLastSequenceNo
		(
    
			DesignationCode,
			LastSequenceNo
		)
		VALUES
		(
			@DesignationsCode,
			@DesSequence
		) 
	END
	ELSE		
	BEGIN
		UPDATE dbo.tblUserDesigLastSequenceNo
		SET
			dbo.tblUserDesigLastSequenceNo.LastSequenceNo = @DesSequence
		WHERE dbo.tblUserDesigLastSequenceNo.DesignationCode = @DesignationsCode 
	END

	END
END

GO









GO
/****** Object:  StoredProcedure [dbo].[UDP_GETInstallUserDetails]    Script Date: 11/16/2016 8:37:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[UDP_GETInstallUserDetails]
@id int
As 
BEGIN

	SELECT Id,FristName,Lastname,Email,[Address],Designation,
	[Status],[Password],Phone,Picture,Attachements,zip,[state],city,
Bussinessname,SSN,SSN1,SSN2,[Signature],DOB,Citizenship,' ',
EIN1,EIN2,A,B,C,D,E,F,G,H,[5],[6],[7],maritalstatus,PrimeryTradeId,SecondoryTradeId,Source,Notes,StatusReason,GeneralLiability,PCLiscense,WorkerComp,HireDate,TerminitionDate,WorkersCompCode,NextReviewDate,EmpType,LastReviewDate,PayRates,ExtraEarning,ExtraEarningAmt,PayMethod,Deduction,DeductionType,AbaAccountNo,AccountNo,AccountType,PTradeOthers,
STradeOthers,DeductionReason,InstallId,SuiteAptRoom,FullTimePosition,ContractorsBuilderOwner,MajorTools,DrugTest,ValidLicense,TruckTools,PrevApply,LicenseStatus,CrimeStatus,StartDate,SalaryReq,Avialability,ResumePath,skillassessmentstatus,assessmentPath,WarrentyPolicy,CirtificationTraining,businessYrs,underPresentComp,websiteaddress,PersonName,PersonType,CompanyPrinciple,UserType,Email2,Phone2,CompanyName,SourceUser,DateSourced,InstallerType,BusinessType,CEO,LegalOfficer,President,Owner,AllParteners,MailingAddress,Warrantyguarantee,WarrantyYrs,MinorityBussiness,WomensEnterprise,InterviewTime,CruntEmployement,CurrentEmoPlace,LeavingReason,CompLit,FELONY,shortterm,LongTerm,BestCandidate,TalentVenue,Boardsites,NonTraditional,ConSalTraning,BestTradeOne,BestTradeTwo,BestTradeThree
,aOne,aOneTwo,bOne,cOne,aTwo,aTwoTwo,bTwo,cTwo,aThree,aThreeTwo,bThree,cThree,TC,ExtraIncomeType,RejectionDate ,UserInstallId
from tblInstallUsers where ID=@id
END
--modified/created by Other Party






GO
/****** Object:  StoredProcedure [dbo].[GetAllEditSalesUser]    Script Date: 11/16/2016 8:38:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[GetAllEditSalesUser]
	-- Add the parameters for the stored procedure here
	AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	SELECT 
		t.Id,t.FristName,t.LastName,t.Phone,t.Zip,t.Designation,t.Status,t.HireDate,t.InstallId,t.picture, t.CreatedDateTime, Isnull(Source,'') AS Source,
		SourceUser, ISNULL(U.Username, U.Login_Id)  AS AddedBy, U.Id As AddeBy_UserID , ISNULL (t.UserInstallId ,t.id) As UserInstallId ,
		InterviewDetail = case when (t.Status='InterviewDate' or t.Status='Interview Date') then coalesce(RejectionDate,'') + ' ' + coalesce(InterviewTime,'') else '' end,
		RejectDetail = case when (t.Status='Rejected' ) then coalesce(RejectionDate,'') + ' ' + coalesce(RejectionTime,'') + ' ' + '-' + coalesce(ru.LastName,'') else '' end,
		t.Email

	FROM 
		tblInstallUsers t 
			LEFT OUTER JOIN tblUsers U ON U.Id = t.SourceUser
			LEFT OUTER JOIN tblUsers ru on t.RejectedUserId=ru.Id	  
	WHERE 
		(t.UserType = 'SalesUser' OR t.UserType = 'sales') 
			AND t.Status <> 'Deactive' 
	ORDER BY Id DESC
	
  --select t.Id,r.InstallerId,t.InstallId,t.FristName,t.LastName,t.HireDate,t.Phone,t.Zip,t.Designation,t.Status,t.Picture 
  --FROM tblInstallUsers t 
	 -- WHERE t.UserType = 'SalesUser' OR t.UserType = 'sales'
	 -- order by Id desc 
 
END




/****** Object:  StoredProcedure [dbo].[sp_GetHrData]    Script Date: 11/16/2016 8:38:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_GetHrData]
	@UserId int,
	@FromDate date,
	@ToDate date
AS
BEGIN
	
	SET NOCOUNT ON;

	IF(@UserId<>0)
		BEGIN
			SELECT 
				t.status,count(*)cnt 
			FROM 
				tblInstallUsers t 
					LEFT OUTER JOIN tblUsers U ON U.Id = t.SourceUser
					LEFT OUTER JOIN tblUsers ru on t.RejectedUserId=ru.Id	  
			WHERE 
				(t.UserType = 'SalesUser' OR t.UserType = 'sales') 
					AND U.Id=@UserId 
					AND CAST(t.CreatedDateTime as date) >= CAST( @FromDate  as date) 
					AND CAST(t.CreatedDateTime  as date) <= CAST( @ToDate  as date)
			GROUP BY t.status
		END
	ELSE 
		BEGIN
			SELECT 
				t.status,count(*)cnt 
			FROM 
				tblInstallUsers t 
					LEFT OUTER JOIN tblUsers U ON U.Id = t.SourceUser
					LEFT OUTER JOIN tblUsers ru on t.RejectedUserId=ru.Id	  
			WHERE 
				(t.UserType = 'SalesUser' OR t.UserType = 'sales')
					AND CAST(t.CreatedDateTime as date) >= CAST( @FromDate  as date) 
					AND CAST(t.CreatedDateTime  as date) <= CAST( @ToDate  as date)
			GROUP BY t.status
		END
	
	
	IF(@UserId<>0)
		Begin
			SELECT 
				t.Id,t.FristName,t.LastName,t.Phone,t.Zip,t.Designation,t.Status,t.HireDate,t.InstallId,t.picture, t.CreatedDateTime, Isnull(Source,'') AS Source,
				SourceUser, ISNULL(U.Username,'')  AS AddedBy , ISNULL (t.UserInstallId ,t.id) As UserInstallId , 
				InterviewDetail = case when (t.Status='InterviewDate' or t.Status='Interview Date') then coalesce(RejectionDate,'') + ' ' + coalesce(InterviewTime,'') else '' end,
				RejectDetail = case when (t.Status='Rejected' ) then coalesce(RejectionDate,'') + ' ' + coalesce(RejectionTime,'') + ' ' + '-' + coalesce(ru.LastName,'') else '' end,
				t.Email
			FROM 
				tblInstallUsers t 
					LEFT OUTER JOIN tblUsers U ON U.Id = t.SourceUser
					LEFT OUTER JOIN tblUsers ru on t.RejectedUserId=ru.Id	  
			WHERE 
				(t.UserType = 'SalesUser' OR t.UserType = 'sales') 
					AND t.Status <> 'Deactive' 
					AND U.Id=@UserId 
					AND CAST(t.CreatedDateTime as date) >= CAST( @FromDate  as date) 
					AND CAST (t.CreatedDateTime  as date) <= CAST( @ToDate  as date)
			ORDER BY Id DESC
		END
	Else
		BEGIN
			SELECT 
				t.Id,t.FristName,t.LastName,t.Phone,t.Zip,t.Designation,t.Status,t.HireDate,t.InstallId,t.picture, t.CreatedDateTime, Isnull(Source,'') AS Source,
				SourceUser, ISNULL(U.Username,'')  AS AddedBy , ISNULL (t.UserInstallId ,t.id) As UserInstallId,
				InterviewDetail = case when (t.Status='InterviewDate' or t.Status='Interview Date') then coalesce(RejectionDate,'') + ' ' + coalesce(InterviewTime,'') else '' end,
				RejectDetail = case when (t.Status='Rejected' ) then coalesce(RejectionDate,'') + ' ' + coalesce(RejectionTime,'') + ' ' + '-' + coalesce(ru.LastName,'') else '' end,
				t.Email
			FROM 
				tblInstallUsers t 
					LEFT OUTER JOIN tblUsers U ON U.Id = t.SourceUser
					LEFT OUTER JOIN tblUsers ru on t.RejectedUserId=ru.Id	  
			WHERE 
				(t.UserType = 'SalesUser' OR t.UserType = 'sales') 
					AND t.Status <> 'Deactive' 
					AND CAST(t.CreatedDateTime as date) >= CAST( @FromDate  as date) 
					ANd CAST(t.CreatedDateTime  as date) <= CAST( @ToDate  as date)
			ORDER BY Id DESC
		END
 
END




GO

/****** Object:  StoredProcedure [dbo].[USP_CheckDuplicateSalesUser]    Script Date: 11/17/2016 12:18:35 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Bhavik
-- Create date: 12-11-2016
-- Description:	Return ID if respective duplicate value is found
-- =============================================
CREATE PROCEDURE [dbo].[USP_CheckDuplicateSalesUser] 
	-- Add the parameters for the stored procedure here
    @CurrentID INT,
	@DataForValidation NVARCHAR(100),
	@DataType INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @Message NVARCHAR(1000)='';
	DECLARE @USERID INT;

	IF(@DataType = 1 ) --#Check Phone Number
	BEGIN 
		IF EXISTS (SELECT Id FROM tblInstallUsers WHERE Phone = @DataForValidation AND ID <> @CurrentID) --#This will work for Edit page also
		BEGIN
		 
		 SELECT @USERID = Id FROM tblInstallUsers WHERE Phone = @DataForValidation AND ID <> @CurrentID
			SET @Message = CONVERT(VARCHAR(20), @USERID)+'# Contact number already exists'
		END
		
	END
	ELSE IF(@DataType = 2) --#Check Email ID
	BEGIN 
		IF EXISTS (SELECT Id FROM tblInstallUsers WHERE Email = @DataForValidation AND ID <> @CurrentID) --#This will work for Edit page also
		BEGIN
			SELECT @USERID = Id FROM tblInstallUsers WHERE Email = @DataForValidation AND ID <> @CurrentID
			   SET @Message = CONVERT(VARCHAR(20), @USERID) +  '#Email ID already exists'
		END
		--ELSE IF EXISTS(SELECT 1 FROM tblCustomersPrimaryContact WHERE strEMail = @DataForValidation AND intCustomerId <> @CurrentID)
		--BEGIN
		--	SET @Message = '990#Email ID already exists'
		--END
	END
		
	SELECT @Message
END

GO


