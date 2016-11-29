
-- =============================================
-- Author:		Shekhar Pawar
-- Create date: 16/11/2016
-- Description:	Fetch all sales and install users for who are in edit user in system
-- =============================================
ALTER PROCEDURE [dbo].[usp_GetUsersNDesignationForSalesFilter] 
AS
BEGIN

SET NOCOUNT ON;

	SELECT  
		DISTINCT Users.Id, FristName + ' ' + LastName AS FirstName,[Status], 'Group1' AS GroupNumber
	FROM tblInstallUsers AS Users 
	WHERE 
		Users.FristName IS NOT NULL AND 
		Users.FristName <> '' AND
		(
			[Status] = 'Active' 
		)
		AND Designation IN('Recruiter', 'Admin', 'Office Manager', 'Jr. Sales', 'Sales Manager', 'Jr Project Manager')

	UNION ALL

	SELECT  
		DISTINCT Users.Id, FristName + ' ' + LastName AS FirstName,[Status], 'Group2' AS GroupNumber
	FROM tblInstallUsers AS Users 
	WHERE 
		Users.FristName IS NOT NULL AND 
		Users.FristName <> '' AND
		(
			[Status] = 'Deactive'
		)
		AND Designation IN('Recruiter', 'Admin', 'Office Manager', 'Jr. Sales', 'Sales Manager', 'Jr Project Manager')

	UNION ALL

	SELECT  
		DISTINCT Users.Id, FristName + ' ' + LastName AS FirstName,[Status], 'Group3' AS GroupNumber
	FROM tblInstallUsers AS Users 
	WHERE 
		Users.FristName IS NOT NULL AND 
		Users.FristName <> '' AND
		(
			[Status] = 'Install Prospect'
		)

	UNION ALL

	SELECT  
		DISTINCT Users.Id, FristName + ' ' + LastName AS FirstName,[Status], 'Group4' AS GroupNumber
	FROM tblInstallUsers AS Users 
	WHERE 
		Users.FristName IS NOT NULL AND 
		Users.FristName <> '' AND
		(
			[Status] = 'OfferMade' OR 
			[Status] = 'Offer Made' OR 
			[Status] = 'Interview Date' OR 
			[Status] = 'InterviewDate'
		)
	ORDER BY GroupNumber, [Status], FristName + ' ' + LastName
END
