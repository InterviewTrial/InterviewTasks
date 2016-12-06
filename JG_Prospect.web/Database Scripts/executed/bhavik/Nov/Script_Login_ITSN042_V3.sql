USE [JGBS]

GO
/****** Object:  StoredProcedure [dbo].[UDP_GetInstallerUserDetailsByLoginId]    Script Date: 11/28/2016 10:55:24 PM ******/
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

 
	--# This query does not make sense, the guy was really stupid.
	/*SELECT Id,FristName,Lastname,Email,Address,Designation,[Status],
		[Password],[Address],Phone,Picture,Attachements,usertype 
	from tblInstallUsers 
	where (Email = @loginId and Status='Active')  OR 
	(Email = @loginId AND (Designation = 'SubContractor' OR Designation='Installer') AND 
	(Status='OfferMade' OR Status='Offer Made' OR Status='Active'))*/
END


GO


ALTER PROCEDURE [dbo].[UDP_getuserdetails] 
@loginid varchar(50)
AS
BEGIN
	
	SELECT Id,Username,Email,[Password],Usertype,Designation,[Status],Phone,[Address] , Picture from tblUsers
	where Login_Id=@loginid and (Status='Active' OR Usertype = 'Employee')
END

