USE [JGBS_Interview]
GO

/****** Object:  StoredProcedure [dbo].[UDP_SaveVendor]    Script Date: 11/26/2016 6:49:03 PM ******/
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


