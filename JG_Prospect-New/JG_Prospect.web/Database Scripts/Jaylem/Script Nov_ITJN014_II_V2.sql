USE [JGBS_Interview]
GO
ALTER TABLE [dbo].[new_customer] ADD IsFirstTime [bit] NULL CONSTRAINT [DF_new_customer_IsFirstTime]  DEFAULT (1);   
GO
ALTER TABLE [dbo].[tblUsers] ADD IsFirstTime [bit] NULL CONSTRAINT [DF_tblUsers_IsFirstTime]  DEFAULT (1);  
GO

IF OBJECT_ID('dbo.UDP_ForgotPasswordReset', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[UDP_ForgotPasswordReset]
END
GO
-- =============================================
-- Author:		Jaylem
-- Create date: 05-Dec-2016
-- Description:	Update password
-- =============================================
CREATE PROCEDURE [dbo].[UDP_ForgotPasswordReset] 
	@Login_Id varchar(50) = '', 
	@NewPassword varchar(50) = '', 
	@IsCustomer Bit,
	@result int output
AS
BEGIN
	SET NOCOUNT ON;
	Set @result ='0'

	If @IsCustomer = 0
	BEGIN
		IF EXISTS (SELECT Id FROM tblUsers WHERE Login_Id=@Login_Id)
		BEGIN
			UPDATE tblUsers Set [Password]=@NewPassword,IsFirstTime=1 WHERE Login_Id = @Login_Id
			Set @result ='1'
		END
	END
	ELSE
	BEGIN
		IF EXISTS (SELECT Id FROM new_customer WHERE (Email = @Login_Id OR CellPh = @Login_Id) AND Email != 'noEmail@blankemail.com')
		BEGIN
			UPDATE new_customer Set [Password]=@NewPassword,IsFirstTime=1 WHERE (Email = @Login_Id OR CellPh = @Login_Id) AND Email != 'noEmail@blankemail.com'
			Set @result ='1'
		END
	END

	RETURN @result

END

GO

ALTER PROCEDURE [dbo].[UDP_changepassword]
	--@usertype varchar(20),
	@loginid varchar(50),
	@password varchar(50),
	@IsCustomer bit,
	@result int output
AS BEGIN

	If @IsCustomer = 0
	BEGIN
		IF EXISTS (SELECT Id FROM tblUsers WHERE Id=@loginid)
		BEGIN
			UPDATE tblUsers Set [Password]=@password,IsFirstTime=0 WHERE Id = @loginid
			Set @result ='1'
		END
	END
	ELSE
	BEGIN
		IF EXISTS (SELECT Id FROM new_customer WHERE Id=@loginid)
		BEGIN
			UPDATE new_customer Set [Password]=@password,IsFirstTime=0 WHERE Id=@loginid
			Set @result ='1'
		END
	END
     
    return @result

 END
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
	
	SELECT Id,Username,Email,[Password],Usertype,Designation,[Status],Phone,[Address] , Picture,IsFirstTime from tblUsers
	where Login_Id=@loginid and (Status='Active' OR Usertype = 'Employee')
END
