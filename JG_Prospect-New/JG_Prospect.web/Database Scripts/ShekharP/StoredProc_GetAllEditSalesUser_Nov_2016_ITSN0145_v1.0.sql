-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Author			Date		Description
-- Shekhar Pawar	17-Nov-2016	Added LEFT OUTER JOIN tblInstallUsers for column "AddedByUserInstallId"
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
		t.Id,t.FristName,t.LastName,t.Phone,t.Zip,t.Designation,t.Status,t.HireDate,t.InstallId,t.picture, t.CreatedDateTime, Isnull(t.Source,'') AS Source,
		t.SourceUser, ISNULL(U.Username, U.Login_Id)  AS AddedBy, U.Id As AddeBy_UserID , ISNULL (t.UserInstallId ,t.id) As UserInstallId ,
		InterviewDetail = case when (t.Status='InterviewDate' or t.Status='Interview Date') then coalesce(t.RejectionDate,'') + ' ' + coalesce(t.InterviewTime,'') else '' end,
		RejectDetail = case when (t.Status='Rejected' ) then coalesce(t.RejectionDate,'') + ' ' + coalesce(t.RejectionTime,'') + ' ' + '-' + coalesce(ru.LastName,'') else '' end,
		t.Email, t1.[UserInstallId] As AddedByUserInstallId
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
	
	--SELECT 
	--	t.Id,t.FristName,t.LastName,t.Phone,t.Zip,t.Designation,t.Status,t.HireDate,t.InstallId,t.picture, t.CreatedDateTime, Isnull(Source,'') AS Source,
	--	SourceUser, ISNULL(U.Username, U.Login_Id)  AS AddedBy, U.Id As AddeBy_UserID , ISNULL (t.UserInstallId ,t.id) As UserInstallId ,
	--	InterviewDetail = case when (t.Status='InterviewDate' or t.Status='Interview Date') then coalesce(RejectionDate,'') + ' ' + coalesce(InterviewTime,'') else '' end,
	--	RejectDetail = case when (t.Status='Rejected' ) then coalesce(RejectionDate,'') + ' ' + coalesce(RejectionTime,'') + ' ' + '-' + coalesce(ru.LastName,'') else '' end,
	--	t.Email

	--FROM 
	--	tblInstallUsers t 
	--		LEFT OUTER JOIN tblUsers U ON U.Id = t.SourceUser
	--		LEFT OUTER JOIN tblUsers ru on t.RejectedUserId=ru.Id	  
	--WHERE 
	--	(t.UserType = 'SalesUser' OR t.UserType = 'sales') 
	--		AND t.Status <> 'Deactive' 
	--ORDER BY Id DESC
	
  --select t.Id,r.InstallerId,t.InstallId,t.FristName,t.LastName,t.HireDate,t.Phone,t.Zip,t.Designation,t.Status,t.Picture 
  --FROM tblInstallUsers t 
	 -- WHERE t.UserType = 'SalesUser' OR t.UserType = 'sales'
	 -- order by Id desc 
 
END


