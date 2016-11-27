USE [JGBS_Interview]




GO
/****** Object:  StoredProcedure [dbo].[USP_SetUserDisplayID]    Script Date: 11/24/2016 3:53:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Bhavik
-- Create date: 16 11 2016
-- Description:	Get Designation ID For a user
-- =============================================
ALTER PROCEDURE [dbo].[USP_SetUserDisplayID] 
	-- Add the parameters for the stored procedure here
	@InstallUserID int = 0, 
	@DesignationsCode varchar(15),
	@UpdateCurrentSequence varchar (10) =''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

IF (@UpdateCurrentSequence = 'YES')
BEGIN
-- SET UserInstallId as NULL. so following process will generae a new ID for respective user.

	UPDATE tblInstallUsers
		SET UserInstallId = null
	WHERE Id = @InstallUserID
END


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
		SET UserInstallId = @DesignationsCode + '-A'+ Right('000' + CONVERT(NVARCHAR, @DesSequence), 4)
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

 
TRUNCATE TABLE tblUserDesigLastSequenceNo
GO


UPDATE tblInstallUsers SET UserInstallId= NULL
GO

GO

DECLARE @U_id  int 
DECLARE @U_designation varchar(50)
DECLARE @U_desc_code varchar(50)


DECLARE c_customers CURSOR FOR
  SELECT Id,Designation FROM tblInstallUsers

   OPEN c_customers
   FETCH  c_customers into @U_id, @U_designation 

  WHILE @@FETCH_STATUS=0
	BEGIN
		IF @U_designation = 'Admin'
			SET @U_desc_code = 'ADM'
                 
		 ELSE IF @U_designation = 'Jr. Sales'
			SET @U_desc_code = 'JSL'
                
		ELSE IF @U_designation = 'Jr. Project Manager'
			SET @U_desc_code = 'JPM'

		ELSE IF @U_designation = 'Jr Project Manager'
			SET @U_desc_code = 'JPM'

		ELSE IF @U_designation = 'Office Manager'
			SET @U_desc_code = 'OFM'	

		ELSE IF @U_designation = 'Recruiter'
			SET @U_desc_code = 'REC'

		ELSE IF @U_designation = 'Sales Manager'
			SET @U_desc_code = 'SLM'

		ELSE IF @U_designation = 'Sr. Sales'
			SET @U_desc_code = 'SSL'

		ELSE IF @U_designation = 'IT - Network Admin'
			SET @U_desc_code = 'ITNA'

		ELSE IF @U_designation = 'IT - Jr .Net Developer'
			SET @U_desc_code = 'ITJN'

		ELSE IF @U_designation = 'IT - Sr .Net Developer'
			SET @U_desc_code = 'ITSN'

		ELSE IF @U_designation = 'IT - Android Developer'
			SET @U_desc_code = 'ITAD'

		ELSE IF @U_designation = 'IT - PHP Developer'
			SET @U_desc_code = 'ITPH'

		ELSE IF @U_designation = 'IT - SEO / BackLinking'
			SET @U_desc_code = 'ITSB'

		ELSE IF @U_designation = 'Installer - Helper'
			SET @U_desc_code = 'INH'

		ELSE IF @U_designation = 'Installer – Journeyman'
			SET @U_desc_code = 'INJ'

		ELSE IF @U_designation = 'Installer – Mechanic'
			SET @U_desc_code = 'INM'

		ELSE IF @U_designation = 'Installer - Lead mechanic'
			SET @U_desc_code = 'INLM'

		ELSE IF @U_designation = 'Installer – Foreman'
			SET @U_desc_code = 'INF'

		ELSE IF @U_designation = 'Commercial Only'
			SET @U_desc_code = 'COM'

		ELSE IF @U_designation = 'SubContractor'
			SET @U_desc_code = 'SBC'
		ELSE 
			SET @U_desc_code = 'OUID'

	exec USP_SetUserDisplayID @U_id, @U_desc_code, 'No'

	fetch next from c_customers into @U_id, @U_designation
      
	END

	CLOSE c_customers
DEALLOCATE c_customers
