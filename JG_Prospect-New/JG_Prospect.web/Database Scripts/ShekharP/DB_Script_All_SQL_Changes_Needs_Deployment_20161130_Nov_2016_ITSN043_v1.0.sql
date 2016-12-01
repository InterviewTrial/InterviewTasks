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
DROP PROC sp_FindStringInTable
GO
DROP PROC UPP_savevendor
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
/****** Object:  StoredProcedure [dbo].[UDP_GetVendorNotes]    Script Date: 11/30/2016 3:00:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UDP_GetVendorNotes]
@VendorId nvarchar(50)=null
AS
BEGIN

	SELECT 
		NotesId,
		userid,
		Notes,
		CreatedOn 
	FROM 
		[dbo].[tbl_VendorNotes]
	WHERE 
		VendorId=@VendorId 
END
GO
/****** Object:  StoredProcedure [dbo].[UDP_GetVendors]    Script Date: 11/30/2016 3:00:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[UDP_GetVendors]  
@VendorStatus NVARCHAR(50) = null,  
@IsRetailWholesale BIT = true,   
@ProductCategoryID VARCHAR(20) = null,
@VendorCategoryID VARCHAR(20) = null, 
@VendorSubCategoryID VARCHAR(20) = null
as  
BEGIN  
	DECLARE @BaseQuery NVARCHAR(MAX)=null 
    SET @BaseQuery = 'SELECT DISTINCT tv.VendorName as VendorName,tv.VendorId as VendorId,tvAdd.Id as AddressId,tvAdd.Zip 
	FROM [dbo].[tblvendors] tv 
	INNER JOIN [dbo].[tbl_Vendor_VendorCat] tvVcat ON tv.VendorId=tvVcat.Vendorid  
	LEFT OUTER JOIN [dbo].[tblVendorAddress] tvAdd ON tv.VendorId=tvAdd.VendorId 
	INNER JOIN [dbo].[tblVendorCategory] vc ON vc.[VendorCategpryId] = tv.[VendorCategoryId]
	INNER JOIN [dbo].[tblProductVendorCat] pvc ON pvc.[VendorCategoryId] = vc.[VendorCategpryId]
	INNER JOIN [dbo].[tblProductMaster] pm ON pm.[ProductId] = pvc.[ProductCategoryId] 
	LEFT OUTER JOIN [dbo].[tbl_Vendor_VendorSubCat] vvsc ON tv.VendorId=vvsc.VendorId
	LEFT OUTER JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCatId]  
	WHERE tv.VendorName <> '''' ' 

	DECLARE @WhereQuery  NVARCHAR(MAX)=null 

	IF @IsRetailWholesale = 1 
	BEGIN
		SET @WhereQuery = ' AND vc.IsRetail_Wholesale = 1 '
	END
	ELSE
	BEGIN
		SET @WhereQuery = ' AND vc.IsRetail_Wholesale = 0 '
	END

	IF @VendorStatus IS NOT NULL
	BEGIN
		SET @WhereQuery =  @WhereQuery + ' AND tv.VendorStatus = ''' + @VendorStatus + ''''
	END
	
	IF @ProductCategoryID IS NOT NULL
	BEGIN
		SET @WhereQuery =  @WhereQuery + ' AND pm.[ProductId] = '''+ @ProductCategoryID +''''
	END

	IF @VendorCategoryID IS NOT NULL
	BEGIN
		SET @WhereQuery =  @WhereQuery + ' AND pvc.[VendorCategoryId] = '''+ @VendorCategoryID +''''
	END

	IF @VendorSubCategoryID IS NOT NULL
	BEGIN
		SET @WhereQuery =  @WhereQuery + ' AND pvc.[VendorSubCategoryId] = '+ @VendorSubCategoryID
	END

	SET @BaseQuery = @BaseQuery + @WhereQuery 

	print @BaseQuery  
	EXECUTE sp_executesql @BaseQuery

END  
GO
/****** Object:  StoredProcedure [dbo].[UDP_SaveVendor]    Script Date: 11/30/2016 3:00:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UDP_SaveVendor]  
@vendor_id int,  
@vendor_name varchar(100) = NULL,  
@vendor_category int = NULL,  
@contact_person varchar(100) = NULL,  
@contact_number varchar(20) = NULL,  
@fax varchar(20) = NULL,  
@email varchar(50) = NULL,  
@address varchar(100) = NULL,  
@notes varchar(500) = NULL,  
@ManufacturerType varchar(70)  = NULL,  
@BillingAddress varchar(MAX)  = NULL,  
@TaxId varchar(50)  = NULL,  
@ExpenseCategory varchar(50)  = NULL,  
@AutoTruckInsurance varchar(50)  = NULL,  
@VendorSubCategoryId int,  
@VendorStatus nvarchar(50) = NULL,  
@Website nvarchar(100) = NULL,  
@ContactExten nvarchar(6) = NULL,
@Vendrosource nvarchar(500)=null,
@AddressID int=null,
@PaymentTerms nvarchar(500)=null,
@PaymentMethod nvarchar(500)=null,
@TempID nvarchar(500)=null, 
@NotesTempID nvarchar(250)=null ,
@VendorCategories nvarchar(max)=null,
@VendorSubCategories nvarchar(max)=null,
@UserID varchar(100)  = NULL
as  
if exists(select 1 from tblVendors where VendorId=@vendor_id)  
begin  
		UPDATE tblVendors  
		SET  
		VendorName=@vendor_name,  
		VendorCategoryId=@vendor_category,  
		ContactPerson=@contact_person,  
		ContactNumber= @contact_number,  
		Fax=@fax,  
		Email=@email,  
		[Address]=@address,  
		Notes=@notes,  
		ManufacturerType = @ManufacturerType,  
		BillingAddress = @BillingAddress,  
		TaxId = @TaxId,  
		ExpenseCategory = @ExpenseCategory,  
		AutoTruckInsurance = @AutoTruckInsurance,  
		VendorSubCategoryId=@VendorSubCategoryId,  
		VendorStatus=@VendorStatus,  
		Website=@Website,  
		ContactExten = @ContactExten,
		Vendrosource = @Vendrosource,
		AddressID = @AddressID,
		PaymentTerms = @PaymentTerms,
		PaymentMethod = @PaymentMethod
		WHERE VendorId = @vendor_id  
		
		IF @VendorCategories IS NOT NULL
		BEGIN
			DELETE FROM 
				tbl_Vendor_VendorCat 
			WHERE 
				VendorId = @vendor_id
			INSERT INTO 
				tbl_Vendor_VendorCat(
				VendorId,
				VendorCatId)
			SELECT 
				@vendor_id,Item 
			FROM 
				dbo.SplitString(@VendorCategories, ',')
		END
		
		IF @VendorSubCategories IS NOT NULL
		Begin
			DELETE FROM 
				tbl_Vendor_VendorSubCat 
			WHERE 
				VendorId = @vendor_id
			INSERT INTO 
				tbl_Vendor_VendorSubCat(
				VendorId,
				VendorSubCatId)
			SELECT 
				@vendor_id,
				Item 
			FROM 
				dbo.SplitString(@VendorSubCategories, ',')
		End
END
ELSE
BEGIN		
		INSERT INTO tblVendors
		(
		VendorName,
		VendorCategoryId,
		ContactPerson,
		ContactNumber,
		Fax,
		Email,
		[Address],
		Notes,
		ManufacturerType,
		BillingAddress,
		TaxId,
		ExpenseCategory,
		AutoTruckInsurance,
		VendorSubCategoryId,
		VendorStatus,
		Website,
		ContactExten,
		Vendrosource,
		AddressID,
		PaymentTerms,
		PaymentMethod)   
		VALUES(
		@vendor_name,
		@vendor_category,
		@contact_person,
		@contact_number,
		@fax,
		@email,
		@address,
		@notes,
		@ManufacturerType,
		@BillingAddress,
		@TaxId,
		@ExpenseCategory,
		@AutoTruckInsurance,
		@VendorSubCategoryId,
		@VendorStatus,
		@Website,
		@ContactExten,
		@Vendrosource,
		@AddressID,
		@PaymentTerms,
		@PaymentMethod) 
		
		SELECT @vendor_id = SCOPE_IDENTITY()

		UPDATE tblVendorEmail 
		SET
		VendorID=@vendor_id
		WHERE TempID=@TempID
		
		UPDATE tblVendorAddress 
		SET
		VendorId=@vendor_id
		WHERE TempID=@TempID
		
		--UPDATE 
		--	tbl_VendorNotes 
		--SET 
		--	VendorId=@vendor_id 
		--WHERE 
		--	TempId=@NotesTempID

		INSERT INTO tbl_VendorNotes 
		(userid,
		Notes,
		CreatedOn,
		VendorId)
		VALUES(
		@UserID,
		@notes,
		GETDATE(),
		@vendor_id)

		IF @VendorCategories IS NOT NULL
		BEGIN
			IF @VendorCategories IS NOT NULL
			BEGIN
				INSERT INTO tbl_Vendor_VendorCat(VendorId,VendorCatId)
				SELECT 
					@vendor_id,
					Item 
				FROM 
					dbo.SplitString(@VendorCategories, ',')
			END
		END
		
		IF @VendorSubCategories IS NOT NULL
		BEGIN		
			IF @VendorSubCategories IS NOT NULL
			BEGIN
				INSERT INTO tbl_Vendor_VendorSubCat
					(VendorId,
					VendorSubCatId)
				SELECT 
					@vendor_id,
					Item 
				FROM 
					dbo.SplitString(@VendorSubCategories, ',')	
			END
		END		
END
GO
/****** Object:  StoredProcedure [dbo].[UDP_SelectVendorAddressByVendorID]    Script Date: 11/30/2016 3:00:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UDP_SelectVendorAddressByVendorID]  
@VendorID INT=NULL
AS  
BEGIN
 SELECT [Id]
      ,[VendorId]
      ,[AddressType]
      ,[Address]
      ,[City]
      ,[Zip]
      ,[Country]
      ,[TempID]
      ,[Latitude]
      ,[Longitude]
      ,[State]
  FROM [dbo].[tblVendorAddress]
  WHERE [VendorID] = @VendorID
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
/****** Object:  StoredProcedure [dbo].[USP_LoadSearchVendorAutoSuggestion]    Script Date: 11/30/2016 3:00:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[USP_LoadSearchVendorAutoSuggestion] 
@stringToFind VARCHAR(100)
AS

BEGIN TRY

SET NOCOUNT ON;


WITH SuggestionForVendors (label,Category)
AS
(	
   SELECT DISTINCT TOP 3 CAST(tv.VendorId AS varchar) AS AutoSuggest, 'VendorId' AS Category 
	FROM [dbo].[tblvendors] tv 
	INNER JOIN [dbo].[tbl_Vendor_VendorCat] tvVcat ON tv.VendorId=tvVcat.Vendorid  
	LEFT OUTER JOIN [dbo].[tblVendorAddress] tvAdd ON tv.VendorId=tvAdd.VendorId 
	INNER JOIN [dbo].[tblVendorCategory] vc ON vc.[VendorCategpryId] = tv.[VendorCategoryId]
	INNER JOIN [dbo].[tblProductVendorCat] pvc ON pvc.[VendorCategoryId] = vc.[VendorCategpryId]
	INNER JOIN [dbo].[tblProductMaster] pm ON pm.[ProductId] = pvc.[ProductCategoryId] 
	LEFT OUTER JOIN [dbo].[tbl_Vendor_VendorSubCat] vvsc ON tv.VendorId=vvsc.VendorId
	LEFT OUTER JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCatId] 
   WHERE tv.VendorId LIKE '%' + @stringToFind +'%'

   UNION

   SELECT DISTINCT TOP 3 tv.VendorName AS AutoSuggest, 'VendorName' AS Category 
	FROM [dbo].[tblvendors] tv 
	INNER JOIN [dbo].[tbl_Vendor_VendorCat] tvVcat ON tv.VendorId=tvVcat.Vendorid  
	LEFT OUTER JOIN [dbo].[tblVendorAddress] tvAdd ON tv.VendorId=tvAdd.VendorId 
	INNER JOIN [dbo].[tblVendorCategory] vc ON vc.[VendorCategpryId] = tv.[VendorCategoryId]
	INNER JOIN [dbo].[tblProductVendorCat] pvc ON pvc.[VendorCategoryId] = vc.[VendorCategpryId]
	INNER JOIN [dbo].[tblProductMaster] pm ON pm.[ProductId] = pvc.[ProductCategoryId] 
	LEFT OUTER JOIN [dbo].[tbl_Vendor_VendorSubCat] vvsc ON tv.VendorId=vvsc.VendorId
	LEFT OUTER JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCatId]  
   WHERE tv.VendorName LIKE '%' + @stringToFind +'%'
   
   UNION

   SELECT DISTINCT TOP 3 CAST(tv.VendorCategoryId AS varchar)  AS AutoSuggest, 'VendorCategoryId' AS Category 
	FROM [dbo].[tblvendors] tv 
	INNER JOIN [dbo].[tbl_Vendor_VendorCat] tvVcat ON tv.VendorId=tvVcat.Vendorid  
	LEFT OUTER JOIN [dbo].[tblVendorAddress] tvAdd ON tv.VendorId=tvAdd.VendorId 
	INNER JOIN [dbo].[tblVendorCategory] vc ON vc.[VendorCategpryId] = tv.[VendorCategoryId]
	INNER JOIN [dbo].[tblProductVendorCat] pvc ON pvc.[VendorCategoryId] = vc.[VendorCategpryId]
	INNER JOIN [dbo].[tblProductMaster] pm ON pm.[ProductId] = pvc.[ProductCategoryId] 
	LEFT OUTER JOIN [dbo].[tbl_Vendor_VendorSubCat] vvsc ON tv.VendorId=vvsc.VendorId
	LEFT OUTER JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCatId] 
   WHERE tv.VendorCategoryId LIKE '%' + @stringToFind +'%'

   UNION

   SELECT DISTINCT TOP 3 tv.ContactPerson  AS AutoSuggest, 'ContactPerson' AS Category 
	FROM [dbo].[tblvendors] tv 
	INNER JOIN [dbo].[tbl_Vendor_VendorCat] tvVcat ON tv.VendorId=tvVcat.Vendorid  
	LEFT OUTER JOIN [dbo].[tblVendorAddress] tvAdd ON tv.VendorId=tvAdd.VendorId 
	INNER JOIN [dbo].[tblVendorCategory] vc ON vc.[VendorCategpryId] = tv.[VendorCategoryId]
	INNER JOIN [dbo].[tblProductVendorCat] pvc ON pvc.[VendorCategoryId] = vc.[VendorCategpryId]
	INNER JOIN [dbo].[tblProductMaster] pm ON pm.[ProductId] = pvc.[ProductCategoryId] 
	LEFT OUTER JOIN [dbo].[tbl_Vendor_VendorSubCat] vvsc ON tv.VendorId=vvsc.VendorId
	LEFT OUTER JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCatId] 
   WHERE tv.ContactPerson LIKE '%' + @stringToFind +'%'

   UNION

   SELECT DISTINCT TOP 3 tv.ContactNumber  AS AutoSuggest, 'ContactNumber' AS Category 
	FROM [dbo].[tblvendors] tv 
	INNER JOIN [dbo].[tbl_Vendor_VendorCat] tvVcat ON tv.VendorId=tvVcat.Vendorid  
	LEFT OUTER JOIN [dbo].[tblVendorAddress] tvAdd ON tv.VendorId=tvAdd.VendorId 
	INNER JOIN [dbo].[tblVendorCategory] vc ON vc.[VendorCategpryId] = tv.[VendorCategoryId]
	INNER JOIN [dbo].[tblProductVendorCat] pvc ON pvc.[VendorCategoryId] = vc.[VendorCategpryId]
	INNER JOIN [dbo].[tblProductMaster] pm ON pm.[ProductId] = pvc.[ProductCategoryId] 
	LEFT OUTER JOIN [dbo].[tbl_Vendor_VendorSubCat] vvsc ON tv.VendorId=vvsc.VendorId
	LEFT OUTER JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCatId]  
   WHERE tv.ContactNumber LIKE '%' + @stringToFind +'%'

   UNION

   SELECT DISTINCT TOP 3 tv.Fax  AS AutoSuggest, 'Fax' AS Category 
	FROM [dbo].[tblvendors] tv 
	INNER JOIN [dbo].[tbl_Vendor_VendorCat] tvVcat ON tv.VendorId=tvVcat.Vendorid  
	LEFT OUTER JOIN [dbo].[tblVendorAddress] tvAdd ON tv.VendorId=tvAdd.VendorId 
	INNER JOIN [dbo].[tblVendorCategory] vc ON vc.[VendorCategpryId] = tv.[VendorCategoryId]
	INNER JOIN [dbo].[tblProductVendorCat] pvc ON pvc.[VendorCategoryId] = vc.[VendorCategpryId]
	INNER JOIN [dbo].[tblProductMaster] pm ON pm.[ProductId] = pvc.[ProductCategoryId] 
	LEFT OUTER JOIN [dbo].[tbl_Vendor_VendorSubCat] vvsc ON tv.VendorId=vvsc.VendorId
	LEFT OUTER JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCatId]  
   WHERE tv.Fax LIKE '%' + @stringToFind +'%'

   UNION

   SELECT DISTINCT TOP 3 tv.Email  AS AutoSuggest, 'Email' AS Category 
	FROM [dbo].[tblvendors] tv 
	INNER JOIN [dbo].[tbl_Vendor_VendorCat] tvVcat ON tv.VendorId=tvVcat.Vendorid  
	LEFT OUTER JOIN [dbo].[tblVendorAddress] tvAdd ON tv.VendorId=tvAdd.VendorId 
	INNER JOIN [dbo].[tblVendorCategory] vc ON vc.[VendorCategpryId] = tv.[VendorCategoryId]
	INNER JOIN [dbo].[tblProductVendorCat] pvc ON pvc.[VendorCategoryId] = vc.[VendorCategpryId]
	INNER JOIN [dbo].[tblProductMaster] pm ON pm.[ProductId] = pvc.[ProductCategoryId] 
	LEFT OUTER JOIN [dbo].[tbl_Vendor_VendorSubCat] vvsc ON tv.VendorId=vvsc.VendorId
	LEFT OUTER JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCatId]  
   WHERE tv.Email LIKE '%' + @stringToFind +'%'

   UNION

   SELECT DISTINCT TOP 3 tv.[Address]  AS AutoSuggest, 'Address' AS Category 
	FROM [dbo].[tblvendors] tv 
	INNER JOIN [dbo].[tbl_Vendor_VendorCat] tvVcat ON tv.VendorId=tvVcat.Vendorid  
	LEFT OUTER JOIN [dbo].[tblVendorAddress] tvAdd ON tv.VendorId=tvAdd.VendorId 
	INNER JOIN [dbo].[tblVendorCategory] vc ON vc.[VendorCategpryId] = tv.[VendorCategoryId]
	INNER JOIN [dbo].[tblProductVendorCat] pvc ON pvc.[VendorCategoryId] = vc.[VendorCategpryId]
	INNER JOIN [dbo].[tblProductMaster] pm ON pm.[ProductId] = pvc.[ProductCategoryId] 
	LEFT OUTER JOIN [dbo].[tbl_Vendor_VendorSubCat] vvsc ON tv.VendorId=vvsc.VendorId
	LEFT OUTER JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCatId] 
   WHERE tv.[Address] LIKE '%' + @stringToFind +'%'

   UNION

   SELECT DISTINCT TOP 3 tv.BillingAddress  AS BillingAddress, 'BillingAddress' AS Category 
	FROM [dbo].[tblvendors] tv 
	INNER JOIN [dbo].[tbl_Vendor_VendorCat] tvVcat ON tv.VendorId=tvVcat.Vendorid  
	LEFT OUTER JOIN [dbo].[tblVendorAddress] tvAdd ON tv.VendorId=tvAdd.VendorId 
	INNER JOIN [dbo].[tblVendorCategory] vc ON vc.[VendorCategpryId] = tv.[VendorCategoryId]
	INNER JOIN [dbo].[tblProductVendorCat] pvc ON pvc.[VendorCategoryId] = vc.[VendorCategpryId]
	INNER JOIN [dbo].[tblProductMaster] pm ON pm.[ProductId] = pvc.[ProductCategoryId] 
	LEFT OUTER JOIN [dbo].[tbl_Vendor_VendorSubCat] vvsc ON tv.VendorId=vvsc.VendorId
	LEFT OUTER JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCatId] 
   WHERE tv.BillingAddress LIKE '%' + @stringToFind +'%'
)

SELECT * FROM SuggestionForVendors s 
ORDER BY s.Category DESC, s.label

END TRY

BEGIN CATCH 
   PRINT 'There was an error. Check to make sure object exists.'
   PRINT error_message()
END CATCH 







GO
/****** Object:  StoredProcedure [dbo].[USP_SelectSearchedVendorByAutoSuggestion]    Script Date: 11/30/2016 3:00:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_SelectSearchedVendorByAutoSuggestion] 
@SearchValue VARCHAR(100),
@SearchCategory VARCHAR(100)
AS
BEGIN TRY
SET NOCOUNT ON;
IF @SearchCategory = 'VendorId'
BEGIN
SELECT DISTINCT
	tv.VendorName AS VendorName,
	tv.VendorId AS VendorId,
	tvAdd.Id AS AddressId,
	tvAdd.Zip 
FROM [dbo].[tblvendors] tv 
	INNER JOIN [dbo].[tbl_Vendor_VendorCat] tvVcat ON tv.VendorId=tvVcat.Vendorid  
	LEFT OUTER JOIN [dbo].[tblVendorAddress] tvAdd ON tv.VendorId=tvAdd.VendorId 
	INNER JOIN [dbo].[tblVendorCategory] vc ON vc.[VendorCategpryId] = tv.[VendorCategoryId]
	INNER JOIN [dbo].[tblProductVendorCat] pvc ON pvc.[VendorCategoryId] = vc.[VendorCategpryId]
	INNER JOIN [dbo].[tblProductMaster] pm ON pm.[ProductId] = pvc.[ProductCategoryId] 
	LEFT OUTER JOIN [dbo].[tbl_Vendor_VendorSubCat] vvsc ON tv.VendorId=vvsc.VendorId
	LEFT OUTER JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCatId]  
WHERE tv.VendorId = @SearchValue
ORDER BY VendorName
END

IF @SearchCategory = 'VendorName'
BEGIN
SELECT DISTINCT
	tv.VendorName AS VendorName,
	tv.VendorId AS VendorId,
	tvAdd.Id AS AddressId,
	tvAdd.Zip 
FROM [dbo].[tblvendors] tv 
	INNER JOIN [dbo].[tbl_Vendor_VendorCat] tvVcat ON tv.VendorId=tvVcat.Vendorid  
	LEFT OUTER JOIN [dbo].[tblVendorAddress] tvAdd ON tv.VendorId=tvAdd.VendorId 
	INNER JOIN [dbo].[tblVendorCategory] vc ON vc.[VendorCategpryId] = tv.[VendorCategoryId]
	INNER JOIN [dbo].[tblProductVendorCat] pvc ON pvc.[VendorCategoryId] = vc.[VendorCategpryId]
	INNER JOIN [dbo].[tblProductMaster] pm ON pm.[ProductId] = pvc.[ProductCategoryId] 
	LEFT OUTER JOIN [dbo].[tbl_Vendor_VendorSubCat] vvsc ON tv.VendorId=vvsc.VendorId
	LEFT OUTER JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCatId]  
WHERE tv.VendorName = @SearchValue
ORDER BY VendorName
END

IF @SearchCategory = 'VendorCategoryId'
BEGIN
SELECT DISTINCT
	tv.VendorName AS VendorName,
	tv.VendorId AS VendorId,
	tvAdd.Id AS AddressId,
	tvAdd.Zip 
FROM [dbo].[tblvendors] tv 
	INNER JOIN [dbo].[tbl_Vendor_VendorCat] tvVcat ON tv.VendorId=tvVcat.Vendorid  
	LEFT OUTER JOIN [dbo].[tblVendorAddress] tvAdd ON tv.VendorId=tvAdd.VendorId 
	INNER JOIN [dbo].[tblVendorCategory] vc ON vc.[VendorCategpryId] = tv.[VendorCategoryId]
	INNER JOIN [dbo].[tblProductVendorCat] pvc ON pvc.[VendorCategoryId] = vc.[VendorCategpryId]
	INNER JOIN [dbo].[tblProductMaster] pm ON pm.[ProductId] = pvc.[ProductCategoryId] 
	LEFT OUTER JOIN [dbo].[tbl_Vendor_VendorSubCat] vvsc ON tv.VendorId=vvsc.VendorId
	LEFT OUTER JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCatId]  
WHERE tv.VendorCategoryId = @SearchValue
ORDER BY VendorName
END

IF @SearchCategory = 'ContactPerson'
BEGIN
SELECT DISTINCT
	tv.VendorName AS VendorName,
	tv.VendorId AS VendorId,
	tvAdd.Id AS AddressId,
	tvAdd.Zip 
FROM [dbo].[tblvendors] tv 
	INNER JOIN [dbo].[tbl_Vendor_VendorCat] tvVcat ON tv.VendorId=tvVcat.Vendorid  
	LEFT OUTER JOIN [dbo].[tblVendorAddress] tvAdd ON tv.VendorId=tvAdd.VendorId 
	INNER JOIN [dbo].[tblVendorCategory] vc ON vc.[VendorCategpryId] = tv.[VendorCategoryId]
	INNER JOIN [dbo].[tblProductVendorCat] pvc ON pvc.[VendorCategoryId] = vc.[VendorCategpryId]
	INNER JOIN [dbo].[tblProductMaster] pm ON pm.[ProductId] = pvc.[ProductCategoryId] 
	LEFT OUTER JOIN [dbo].[tbl_Vendor_VendorSubCat] vvsc ON tv.VendorId=vvsc.VendorId
	LEFT OUTER JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCatId]  
WHERE tv.ContactPerson = @SearchValue
ORDER BY VendorName
END

IF @SearchCategory = 'ContactNumber'
BEGIN
SELECT DISTINCT
	tv.VendorName AS VendorName,
	tv.VendorId AS VendorId,
	tvAdd.Id AS AddressId,
	tvAdd.Zip 
FROM [dbo].[tblvendors] tv 
	INNER JOIN [dbo].[tbl_Vendor_VendorCat] tvVcat ON tv.VendorId=tvVcat.Vendorid  
	LEFT OUTER JOIN [dbo].[tblVendorAddress] tvAdd ON tv.VendorId=tvAdd.VendorId 
	INNER JOIN [dbo].[tblVendorCategory] vc ON vc.[VendorCategpryId] = tv.[VendorCategoryId]
	INNER JOIN [dbo].[tblProductVendorCat] pvc ON pvc.[VendorCategoryId] = vc.[VendorCategpryId]
	INNER JOIN [dbo].[tblProductMaster] pm ON pm.[ProductId] = pvc.[ProductCategoryId] 
	LEFT OUTER JOIN [dbo].[tbl_Vendor_VendorSubCat] vvsc ON tv.VendorId=vvsc.VendorId
	LEFT OUTER JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCatId] 
WHERE tv.ContactNumber = @SearchValue
ORDER BY VendorName
END

IF @SearchCategory = 'Fax'
BEGIN
SELECT DISTINCT
	tv.VendorName AS VendorName,
	tv.VendorId AS VendorId,
	tvAdd.Id AS AddressId,
	tvAdd.Zip 
FROM [dbo].[tblvendors] tv 
	INNER JOIN [dbo].[tbl_Vendor_VendorCat] tvVcat ON tv.VendorId=tvVcat.Vendorid  
	LEFT OUTER JOIN [dbo].[tblVendorAddress] tvAdd ON tv.VendorId=tvAdd.VendorId 
	INNER JOIN [dbo].[tblVendorCategory] vc ON vc.[VendorCategpryId] = tv.[VendorCategoryId]
	INNER JOIN [dbo].[tblProductVendorCat] pvc ON pvc.[VendorCategoryId] = vc.[VendorCategpryId]
	INNER JOIN [dbo].[tblProductMaster] pm ON pm.[ProductId] = pvc.[ProductCategoryId] 
	LEFT OUTER JOIN [dbo].[tbl_Vendor_VendorSubCat] vvsc ON tv.VendorId=vvsc.VendorId
	LEFT OUTER JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCatId] 
WHERE tv.Fax = @SearchValue
ORDER BY VendorName
END

IF @SearchCategory = 'Email'
BEGIN
SELECT DISTINCT
	tv.VendorName AS VendorName,
	tv.VendorId AS VendorId,
	tvAdd.Id AS AddressId,
	tvAdd.Zip 
FROM [dbo].[tblvendors] tv 
	INNER JOIN [dbo].[tbl_Vendor_VendorCat] tvVcat ON tv.VendorId=tvVcat.Vendorid  
	LEFT OUTER JOIN [dbo].[tblVendorAddress] tvAdd ON tv.VendorId=tvAdd.VendorId 
	INNER JOIN [dbo].[tblVendorCategory] vc ON vc.[VendorCategpryId] = tv.[VendorCategoryId]
	INNER JOIN [dbo].[tblProductVendorCat] pvc ON pvc.[VendorCategoryId] = vc.[VendorCategpryId]
	INNER JOIN [dbo].[tblProductMaster] pm ON pm.[ProductId] = pvc.[ProductCategoryId] 
	LEFT OUTER JOIN [dbo].[tbl_Vendor_VendorSubCat] vvsc ON tv.VendorId=vvsc.VendorId
	LEFT OUTER JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCatId] 
WHERE tv.Email = @SearchValue
ORDER BY VendorName
END

IF @SearchCategory = 'Address'
BEGIN
SELECT DISTINCT
	tv.VendorName AS VendorName,
	tv.VendorId AS VendorId,
	tvAdd.Id AS AddressId,
	tvAdd.Zip 
FROM [dbo].[tblvendors] tv 
	INNER JOIN [dbo].[tbl_Vendor_VendorCat] tvVcat ON tv.VendorId=tvVcat.Vendorid  
	LEFT OUTER JOIN [dbo].[tblVendorAddress] tvAdd ON tv.VendorId=tvAdd.VendorId 
	INNER JOIN [dbo].[tblVendorCategory] vc ON vc.[VendorCategpryId] = tv.[VendorCategoryId]
	INNER JOIN [dbo].[tblProductVendorCat] pvc ON pvc.[VendorCategoryId] = vc.[VendorCategpryId]
	INNER JOIN [dbo].[tblProductMaster] pm ON pm.[ProductId] = pvc.[ProductCategoryId] 
	LEFT OUTER JOIN [dbo].[tbl_Vendor_VendorSubCat] vvsc ON tv.VendorId=vvsc.VendorId
	LEFT OUTER JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCatId]  
WHERE tv.[Address] = @SearchValue
ORDER BY VendorName
END

IF @SearchCategory = 'BillingAddress'
BEGIN
SELECT DISTINCT
	tv.VendorName AS VendorName,
	tv.VendorId AS VendorId,
	tvAdd.Id AS AddressId,
	tvAdd.Zip 
FROM [dbo].[tblvendors] tv 
	INNER JOIN [dbo].[tbl_Vendor_VendorCat] tvVcat ON tv.VendorId=tvVcat.Vendorid  
	LEFT OUTER JOIN [dbo].[tblVendorAddress] tvAdd ON tv.VendorId=tvAdd.VendorId 
	INNER JOIN [dbo].[tblVendorCategory] vc ON vc.[VendorCategpryId] = tv.[VendorCategoryId]
	INNER JOIN [dbo].[tblProductVendorCat] pvc ON pvc.[VendorCategoryId] = vc.[VendorCategpryId]
	INNER JOIN [dbo].[tblProductMaster] pm ON pm.[ProductId] = pvc.[ProductCategoryId] 
	LEFT OUTER JOIN [dbo].[tbl_Vendor_VendorSubCat] vvsc ON tv.VendorId=vvsc.VendorId
	LEFT OUTER JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCatId] 
WHERE tv.BillingAddress = @SearchValue
ORDER BY VendorName
END

END TRY

BEGIN CATCH 
   PRINT 'There was an error. Check to make sure object exists.'
   PRINT error_message()
END CATCH 







GO
