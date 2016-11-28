-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Author			Date		Description
-- Shekhar Pawar	20-Nov-2016	Added LEFT OUTER JOIN tblInstallUsers for column "AddedByUserInstallId"
-- Shekhar Pawar	28-Nov-2016 Added DesignationID column
-- =============================================
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
