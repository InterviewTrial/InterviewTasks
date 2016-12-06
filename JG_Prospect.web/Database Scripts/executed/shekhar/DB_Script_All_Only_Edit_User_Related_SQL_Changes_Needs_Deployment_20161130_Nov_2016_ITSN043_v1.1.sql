USE [JGBS_Dev]
GO
ALTER TABLE [dbo].[tblInstallUsers] ADD [DesignationID] INT NULL;
ALTER TABLE [dbo].[tblInstallUsers] ADD CONSTRAINT FK_tblInstallUsers_DesignationID_tbl_Designation_ID 
FOREIGN KEY (DesignationID) REFERENCES [dbo].[tbl_Designation](ID);
GO
--Cursor Logic to Data Correction Starts
DECLARE @InstallUserID INT
DECLARE @Designation VARCHAR(50)
DECLARE @DesignationIDFromDesignationTable INT
--------------------------------------------------------
DECLARE @DesignationUpdateCursor CURSOR
SET @DesignationUpdateCursor = CURSOR FAST_FORWARD
FOR
SELECT Id, Designation
FROM [dbo].[tblInstallUsers]
OPEN @DesignationUpdateCursor
FETCH NEXT FROM @DesignationUpdateCursor
INTO @InstallUserID,@Designation
WHILE @@FETCH_STATUS = 0
BEGIN
SELECT @DesignationIDFromDesignationTable = case @Designation
WHEN 'Recruiter' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='Recruiter')
WHEN 'IT - Sr .Net Developer' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='IT - Sr .Net Developer')
WHEN 'IT - PHP Developer' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='IT - PHP Developer')
WHEN 'SSE' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='IT - SEO / BackLinking')
WHEN 'Installer - Helper' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='Installer - Helper')
WHEN 'Installer - Journeyman' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='Installer - Journeyman')
WHEN 'IT - SEO / BackLinking' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='Installer - Foreman')
WHEN 'InstallerLeadMechanic' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='Installer - Lead mechanic')
WHEN 'Jr. Sales' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='Jr. Sales')
WHEN 'SubContractor' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='SubContractor')
WHEN 'Sr. Sales' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='Sr. Sales')
WHEN 'Installer - Foreman' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='Installer - Foreman')
WHEN 'Select' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='Recruiter')
WHEN 'Jr Project Manager' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='Jr Project Manager')
WHEN 'Installer' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='Installer - Helper')
WHEN 'IT - Jr .Net Developer' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='IT - Jr .Net Developer')
WHEN 'Admin' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='Admin')
WHEN 'IT - Android Developer' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='IT - Android Developer')
WHEN 'Forman' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='Installer - Foreman')
WHEN 'IT - Network Admin' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='IT - Network Admin')
WHEN 'Commercial Only' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='Commercial Only')
ELSE NULL
END
IF @DesignationIDFromDesignationTable IS NOT NULL
BEGIN
UPDATE [dbo].[tblInstallUsers] SET DesignationID = @DesignationIDFromDesignationTable
WHERE ID = @InstallUserID
END
--PRINT CAST(@InstallUserID AS VARCHAR) +'-'+ @Designation +'-'+ CAST(@DesignationIDFromDesignationTable AS VARCHAR)
FETCH NEXT FROM @DesignationUpdateCursor
INTO @InstallUserID,@Designation
END
CLOSE @DesignationUpdateCursor
DEALLOCATE @DesignationUpdateCursor
--Cursor Logic to Data Correction Ends
GO
GO
/****** Object:  StoredProcedure [dbo].[sp_GetHrData]    Script Date: 11/30/2016 3:00:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Author			Date		Description
-- Shekhar Pawar	20-Nov-2016	Added LEFT OUTER JOIN tblInstallUsers for column "AddedByUserInstallId"
-- Shekhar Pawar	28-Nov-2016 Added DesignationID column
-- Shekhar Pawar	29-Nov-2016 Added null dates logic for selecting all records
-- =============================================
ALTER PROCEDURE [dbo].[sp_GetHrData]
	@UserId int,
	@FromDate date = null,
	@ToDate date = null
AS
BEGIN
	
	SET NOCOUNT ON;

	IF @FromDate  IS NOT NULL AND @ToDate IS NOT NULL
	BEGIN
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
				t.Id,t.FristName,t.LastName,t.Phone,t.Zip,t.Designation,t.Status,t.HireDate,t.InstallId,t.picture, t.CreatedDateTime, Isnull(t.Source,'') AS Source,
				t.SourceUser, ISNULL(U.Username,'')  AS AddedBy , ISNULL (t.UserInstallId ,t.id) As UserInstallId , 
				InterviewDetail = case when (t.Status='InterviewDate' or t.Status='Interview Date') then coalesce(t.RejectionDate,'') + ' ' + coalesce(t.InterviewTime,'') else '' end,
				RejectDetail = case when (t.Status='Rejected' ) then coalesce(t.RejectionDate,'') + ' ' + coalesce(t.RejectionTime,'') + ' ' + '-' + coalesce(ru.LastName,'') else '' end,
				t.Email, t.DesignationID, t1.[UserInstallId] As AddedByUserInstallId
				--ISNULL (ISNULL (t1.[UserInstallId],t1.id),t.Id) As AddedByUserInstallId
			FROM 
				tblInstallUsers t 
					LEFT OUTER JOIN tblUsers U ON U.Id = t.SourceUser
					LEFT OUTER JOIN tblUsers ru on t.RejectedUserId=ru.Id
					LEFT OUTER JOIN tblInstallUsers t1 ON t1.Id= U.Id	  
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
				t.Id,t.FristName,t.LastName,t.Phone,t.Zip,t.Designation,t.Status,t.HireDate,t.InstallId,t.picture, t.CreatedDateTime, Isnull(t.Source,'') AS Source,
				t.SourceUser, ISNULL(U.Username,'')  AS AddedBy , ISNULL (t.UserInstallId ,t.id) As UserInstallId,	
				InterviewDetail = case when (t.Status='InterviewDate' or t.Status='Interview Date') 
				then coalesce(t.RejectionDate,'') + ' ' + coalesce(t.InterviewTime,'') else '' end,
				RejectDetail = case when (t.Status='Rejected' ) then coalesce(t.RejectionDate,'') + ' ' + coalesce(t.RejectionTime,'') + ' ' + '-' + coalesce(ru.LastName,'') else '' end,
				t.Email, t.DesignationID, t1.[UserInstallId] As AddedByUserInstallId
				--ISNULL (ISNULL (t1.[UserInstallId],t1.id),t.Id) As AddedByUserInstallId
			FROM 
				tblInstallUsers t 
					LEFT OUTER JOIN tblUsers U ON U.Id = t.SourceUser
					LEFT OUTER JOIN tblUsers ru on t.RejectedUserId=ru.Id
					LEFT OUTER JOIN tblInstallUsers t1 ON t1.Id= U.Id	  
			WHERE 
				(t.UserType = 'SalesUser' OR t.UserType = 'sales') 
					AND t.Status <> 'Deactive' 
					AND CAST(t.CreatedDateTime as date) >= CAST( @FromDate  as date) 
					ANd CAST(t.CreatedDateTime  as date) <= CAST( @ToDate  as date)
			ORDER BY Id DESC
		END
	END
	ELSE
	BEGIN 
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
			GROUP BY t.status
		END
	
	
	IF(@UserId<>0)
		Begin
			SELECT 
				t.Id,t.FristName,t.LastName,t.Phone,t.Zip,t.Designation,t.Status,t.HireDate,t.InstallId,t.picture, t.CreatedDateTime, Isnull(t.Source,'') AS Source,
				t.SourceUser, ISNULL(U.Username,'')  AS AddedBy , ISNULL (t.UserInstallId ,t.id) As UserInstallId , 
				InterviewDetail = case when (t.Status='InterviewDate' or t.Status='Interview Date') then coalesce(t.RejectionDate,'') + ' ' + coalesce(t.InterviewTime,'') else '' end,
				RejectDetail = case when (t.Status='Rejected' ) then coalesce(t.RejectionDate,'') + ' ' + coalesce(t.RejectionTime,'') + ' ' + '-' + coalesce(ru.LastName,'') else '' end,
				t.Email, t.DesignationID, t1.[UserInstallId] As AddedByUserInstallId
				--ISNULL (ISNULL (t1.[UserInstallId],t1.id),t.Id) As AddedByUserInstallId
			FROM 
				tblInstallUsers t 
					LEFT OUTER JOIN tblUsers U ON U.Id = t.SourceUser
					LEFT OUTER JOIN tblUsers ru on t.RejectedUserId=ru.Id
					LEFT OUTER JOIN tblInstallUsers t1 ON t1.Id= U.Id	  
			WHERE 
				(t.UserType = 'SalesUser' OR t.UserType = 'sales') 
					AND t.Status <> 'Deactive' 
					AND U.Id=@UserId 
			ORDER BY Id DESC
		END
	Else
		BEGIN
			SELECT 
				t.Id,t.FristName,t.LastName,t.Phone,t.Zip,t.Designation,t.Status,t.HireDate,t.InstallId,t.picture, t.CreatedDateTime, Isnull(t.Source,'') AS Source,
				t.SourceUser, ISNULL(U.Username,'')  AS AddedBy , ISNULL (t.UserInstallId ,t.id) As UserInstallId,	
				InterviewDetail = case when (t.Status='InterviewDate' or t.Status='Interview Date') 
				then coalesce(t.RejectionDate,'') + ' ' + coalesce(t.InterviewTime,'') else '' end,
				RejectDetail = case when (t.Status='Rejected' ) then coalesce(t.RejectionDate,'') + ' ' + coalesce(t.RejectionTime,'') + ' ' + '-' + coalesce(ru.LastName,'') else '' end,
				t.Email, t.DesignationID, t1.[UserInstallId] As AddedByUserInstallId
				--ISNULL (ISNULL (t1.[UserInstallId],t1.id),t.Id) As AddedByUserInstallId
			FROM 
				tblInstallUsers t 
					LEFT OUTER JOIN tblUsers U ON U.Id = t.SourceUser
					LEFT OUTER JOIN tblUsers ru on t.RejectedUserId=ru.Id
					LEFT OUTER JOIN tblInstallUsers t1 ON t1.Id= U.Id	  
			WHERE 
				(t.UserType = 'SalesUser' OR t.UserType = 'sales') 
					AND t.Status <> 'Deactive' 
			ORDER BY Id DESC
		END
	END


	--	IF(@UserId<>0)
	--	Begin
	--		SELECT 
	--			t.Id,t.FristName,t.LastName,t.Phone,t.Zip,t.Designation,t.Status,t.HireDate,t.InstallId,t.picture, t.CreatedDateTime, Isnull(Source,'') AS Source,
	--			SourceUser, ISNULL(U.Username,'')  AS AddedBy , ISNULL (t.UserInstallId ,t.id) As UserInstallId , 
	--			InterviewDetail = case when (t.Status='InterviewDate' or t.Status='Interview Date') then coalesce(RejectionDate,'') + ' ' + coalesce(InterviewTime,'') else '' end,
	--			RejectDetail = case when (t.Status='Rejected' ) then coalesce(RejectionDate,'') + ' ' + coalesce(RejectionTime,'') + ' ' + '-' + coalesce(ru.LastName,'') else '' end,
	--			t.Email
	--		FROM 
	--			tblInstallUsers t 
	--				LEFT OUTER JOIN tblUsers U ON U.Id = t.SourceUser
	--				LEFT OUTER JOIN tblUsers ru on t.RejectedUserId=ru.Id	  
	--		WHERE 
	--			(t.UserType = 'SalesUser' OR t.UserType = 'sales') 
	--				AND t.Status <> 'Deactive' 
	--				AND U.Id=@UserId 
	--				AND CAST(t.CreatedDateTime as date) >= CAST( @FromDate  as date) 
	--				AND CAST (t.CreatedDateTime  as date) <= CAST( @ToDate  as date)
	--		ORDER BY Id DESC
	--	END
	--Else
	--	BEGIN
	--		SELECT 
	--			t.Id,t.FristName,t.LastName,t.Phone,t.Zip,t.Designation,t.Status,t.HireDate,t.InstallId,t.picture, t.CreatedDateTime, Isnull(Source,'') AS Source,
	--			SourceUser, ISNULL(U.Username,'')  AS AddedBy , ISNULL (t.UserInstallId ,t.id) As UserInstallId,
	--			InterviewDetail = case when (t.Status='InterviewDate' or t.Status='Interview Date') then coalesce(RejectionDate,'') + ' ' + coalesce(InterviewTime,'') else '' end,
	--			RejectDetail = case when (t.Status='Rejected' ) then coalesce(RejectionDate,'') + ' ' + coalesce(RejectionTime,'') + ' ' + '-' + coalesce(ru.LastName,'') else '' end,
	--			t.Email
	--		FROM 
	--			tblInstallUsers t 
	--				LEFT OUTER JOIN tblUsers U ON U.Id = t.SourceUser
	--				LEFT OUTER JOIN tblUsers ru on t.RejectedUserId=ru.Id	  
	--		WHERE 
	--			(t.UserType = 'SalesUser' OR t.UserType = 'sales') 
	--				AND t.Status <> 'Deactive' 
	--				AND CAST(t.CreatedDateTime as date) >= CAST( @FromDate  as date) 
	--				ANd CAST(t.CreatedDateTime  as date) <= CAST( @ToDate  as date)
	--		ORDER BY Id DESC
	--	END
 
END

GO
/****** Object:  StoredProcedure [dbo].[usp_GetUsersNDesignationForSalesFilter]    Script Date: 11/30/2016 3:00:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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

GO
-- =============================================
-- Author:		Shekhar Pawar
-- Create date: 01-Dec-2016
-- Description:	Get List of TechTask for DesignationID
-- =============================================
CREATE PROCEDURE [dbo].[UDP_GetAllActiveTechTaskForDesignationID] 
@DesignationID INT = 0
AS
BEGIN
	SET NOCOUNT ON;
	SELECT 
		t.TaskId, t.Title
	FROM 
	[dbo].[tblTask] t INNER JOIN [dbo].[tblTaskDesignations] td
		ON t.TaskId = td.TaskId
	WHERE  t.IsTechTask = 1
		AND 
	td.Designation IN(
		SELECT DesignationName 
			FROM 
			[dbo].[tbl_Designation] 
		WHERE ID = @DesignationID)
END
GO