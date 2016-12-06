GO

/****** Object:  Table [dbo].[tblUserEmail]    Script Date: 12/2/2016 8:59:07 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tblUserEmail](
	[UserEmailID] [int] IDENTITY(1,1) NOT NULL,
	[emailID] [varchar](256) NULL,
	[IsPrimary] [bit] NULL,
	[UserID] [int] NULL,
 CONSTRAINT [PK_tblUserEmail] PRIMARY KEY CLUSTERED 
(
	[UserEmailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


 





 /****** Object:  Table [dbo].[tblUserPhone]    Script Date: 12/2/2016 9:06:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tblUserPhone](
	[UserPhoneID] [int] IDENTITY(1,1) NOT NULL,
	[Phone] [varchar](50) NULL,
	[IsPrimary] [bit] NULL,
	[PhoneTypeID] [int] NULL,
	[UserID] [int] NULL,
 CONSTRAINT [PK_tblUserPhone] PRIMARY KEY CLUSTERED 
(
	[UserPhoneID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO








  




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





/***************** Re - run Script of SP ************************//








GO




/****** Object:  StoredProcedure [dbo].[Sp_InsertUpdateUserPhone]    Script Date: 12/2/2016 4:50:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Bhavik J. Vaishnani
-- Create date: 23-11-2016
-- Description:	Insert/ Update User Phone
-- =============================================
CREATE PROCEDURE [dbo].[Sp_InsertUpdateUserPhone] 
	-- Add the parameters for the stored procedure here
	@isPrimaryPhone bit,
	@phoneText varchar(256),
	@phoneType varchar(50),
	@UserID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DELETE FROM tblUserPhone WHERE UserID = @UserID


    INSERT INTO [dbo].[tblUserPhone]
           ([Phone]
           ,[IsPrimary]
           ,[PhoneTypeID]
           ,[UserID])
     VALUES
           (@phoneText
           ,@isPrimaryPhone
           ,@phoneType
           ,@UserID)
	
END

GO











GO

/****** Object:  StoredProcedure [dbo].[SP_GetUserEmailByUserId]    Script Date: 12/2/2016 4:51:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Bhavik J. Vaishnani.
-- Create date: 22-11-2016
-- Description:	get List of all email Id on the base of UserID
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetUserEmailByUserId] 
	-- Add the parameters for the stored procedure here
	@UserID int = 0
	  
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * From tblUserEmail tue where  tue.UserID = @UserID
END

GO












GO

/****** Object:  StoredProcedure [dbo].[SP_InsertUserEmail]    Script Date: 12/2/2016 4:51:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Bhavik
-- Create date: 22-11-2016
-- Description:	Insert email data
-- =============================================
CREATE PROCEDURE [dbo].[SP_InsertUserEmail] 
	-- Add the parameters for the stored procedure here
	@EmailID varchar(max), 
	@UserID int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

---SPLIT THE VALUE --- START--
DECLARE @Split char(3),
        @X xml

SELECT @Split = '|,|'



SELECT @X = CONVERT(xml,' <root> <s>' + REPLACE(@EmailID,@Split,'</s> <s>') + '</s>   </root> ')
---SPLIT THE VALUE --- END--


DELETE FROM tblUserEmail WHERE UserID = @UserID

IF @EmailID <> ''
BEGIN
		INSERT INTO [dbo].[tblUserEmail]
				   ([emailID]
				   ,[IsPrimary]
				   ,[UserID])
		 SELECT [Value] = T.c.value('.','varchar(255)') , 0 ,@UserID
		FROM @X.nodes('/root/s') T(c)

END



END

GO











GO

/****** Object:  StoredProcedure [dbo].[USP_CheckDuplicateSalesUser]    Script Date: 12/2/2016 4:52:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Bhavik
-- Create date: 12-11-2016
-- Description:	Return ID if respective duplicate value is found
-- =============================================
ALTER PROCEDURE [dbo].[USP_CheckDuplicateSalesUser] 
	-- Add the parameters for the stored procedure here
    @CurrentID INT,
	@DataForValidation NVARCHAR(100),
	@DataType INT,
	@PhoneTypeID INT
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
		
		--ELSE IF EXISTS (SELECT UserPhoneID FROM tblUserPhone WHERE Phone = @DataForValidation AND PhoneTypeID = @PhoneTypeID AND UserID <> @CurrentID)
		ELSE IF EXISTS (SELECT UserPhoneID FROM tblUserPhone WHERE Phone = @DataForValidation AND UserID <> @CurrentID)
		BEGIN
				--SELECT @USERID = UserID FROM tblUserPhone WHERE Phone = @DataForValidation AND PhoneTypeID = @PhoneTypeID AND UserID <> @CurrentID
				SELECT @USERID = UserID FROM tblUserPhone WHERE Phone = @DataForValidation AND UserID <> @CurrentID
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
		ELSE IF EXISTS (SELECT UserEmailID FROM tblUserEmail WHERE emailID = @DataForValidation AND UserID <> @CurrentID) --#This will work for Edit page also
		BEGIN
			SELECT @USERID = UserID FROM tblUserEmail WHERE emailID = @DataForValidation AND UserID <> @CurrentID
			   SET @Message = CONVERT(VARCHAR(20), @USERID) +  '#Email ID already exists'
		END
		

	END
		
	SELECT @Message
END

GO



/************* LOGIN *******************/



GO
/****** Object:  StoredProcedure [dbo].[UDP_IsValidInstallerUser]    Script Date: 12/2/2016 8:48:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER ProcEDURE [dbo].[UDP_IsValidInstallerUser]
@userid varchar(50),
@password varchar(50),
@result int output
AS
BEGIN
	if exists(
		select Id from tblInstallUsers 
		where Email=@userid and Password=@password and (Status='Active' OR Status='OfferMade' OR Status = 'InterviewDate') 
		UNION
		SELECT TE.UserID FROM tblInstallUsers TIU INNER JOIN tblUserEmail TE ON TIU.Id = TE.UserID
		WHERE 	TE.emailID=@userid and Password=@password and 	(Status='Active' OR Status='OfferMade' OR Status = 'InterviewDate')
	)
	begin
		Set @result ='1'
	end
	else
	begin
		set @result='0'
	end


	return @result

END





GO
/****** Object:  StoredProcedure [dbo].[UDP_GetInstallerUserDetailsByLoginId]    Script Date: 12/2/2016 8:50:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





ALTER ProcEDURE [dbo].[UDP_GetInstallerUserDetailsByLoginId]
@loginId varchar(50) 
AS
BEGIN
	
	SELECT Id,FristName,Lastname,Email,Address,Designation,[Status],
		[Password],[Address],Phone,Picture,Attachements,usertype , Picture
	from tblInstallUsers 
	where (Email = @loginId )  
	 AND 
	(Status='OfferMade' OR Status='Offer Made' OR Status='Active' OR Status = 'InterviewDate')

UNION

	SELECT Id,FristName,Lastname,TE.emailID as Email,Address,Designation,[Status],
		[Password],[Address],Phone,Picture,Attachements,usertype , Picture
	from tblInstallUsers TIU INNER JOIN tblUserEmail TE on TIU.Id = TE.UserID

	where (TE.emailID = @loginId)
	 AND 
	(Status='OfferMade' OR Status='Offer Made' OR Status='Active' OR Status = 'InterviewDate')
	
	--# This query does not make sense, the guy was really stupid.
	/*SELECT Id,FristName,Lastname,Email,Address,Designation,[Status],
		[Password],[Address],Phone,Picture,Attachements,usertype 
	from tblInstallUsers 
	where (Email = @loginId and Status='Active')  OR 
	(Email = @loginId AND (Designation = 'SubContractor' OR Designation='Installer') AND 
	(Status='OfferMade' OR Status='Offer Made' OR Status='Active'))*/
END








GO
/****** Object:  StoredProcedure [dbo].[UDP_GETInstallUserDetails]    Script Date: 12/2/2016 8:53:05 PM ******/
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
,PositionAppliedFor
from tblInstallUsers where ID=@id
END
--modified/created by Other Party











GO
/****** Object:  StoredProcedure [dbo].[UDP_getuserdetails]    Script Date: 12/2/2016 9:01:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[UDP_getuserdetails] 
@loginid varchar(50)
AS
BEGIN
	
	SELECT Id,Username,Email,[Password],Usertype,Designation,[Status],Phone,[Address] , Picture from tblUsers
	where Login_Id=@loginid and (Status='Active' OR Usertype = 'Employee')
END



