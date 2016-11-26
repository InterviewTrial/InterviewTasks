USE [JGBS_Interview]
GO

/****** Object:  StoredProcedure [dbo].[UPP_savevendor]    Script Date: 11/26/2016 6:51:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[UPP_savevendor]  
@vendor_id int,  
@vendor_name varchar(100),  
@vendor_category int,  
@contact_person varchar(100),  
@contact_number varchar(20),  
@fax varchar(20),  
@email varchar(50),  
@address varchar(100),  
@notes varchar(500),  
@ManufacturerType varchar(70) = '',  
@BillingAddress varchar(MAX) = '',  
@TaxId varchar(50) = '',  
@ExpenseCategory varchar(50) = '',  
@AutoTruckInsurance varchar(50) = '',  
@VendorSubCategoryId int,  
@VendorStatus nvarchar(50)='',  
@Website nvarchar(100)='',  
@ContactExten nvarchar(6)='',
@Vendrosource nvarchar(500)=null,
@AddressID int=null,
@PaymentTerms nvarchar(500)=null,
@PaymentMethod nvarchar(500)=null,
@TempID nvarchar(500)=null, 
@NotesTempID nvarchar(250)=null ,
@VendorCategories nvarchar(max)=null,
@VendorSubCategories nvarchar(max)=null
as  
if exists(select 1 from tblVendors where VendorId=@vendor_id)  
begin  
		update tblVendors  
		set  
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
		where VendorId = @vendor_id  
		
		if(@VendorCategories != '')
		Begin
			delete from tbl_Vendor_VendorCat where VendorId = @vendor_id
			insert into tbl_Vendor_VendorCat(VendorId,VendorCatId)
			SELECT @vendor_id,Item FROM dbo.SplitString(@VendorCategories, ',')
		End
		
		if(@VendorSubCategories != '')
		Begin
			delete from tbl_Vendor_VendorSubCat where VendorId = @vendor_id
			insert into tbl_Vendor_VendorSubCat(VendorId,VendorSubCatId)
			SELECT @vendor_id,Item FROM dbo.SplitString(@VendorSubCategories, ',')
		End
end  
else  
begin
		
		declare @temptbl table
		(
			ID int
		)
		
		insert into tblVendors(
		VendorName,VendorCategoryId,
		ContactPerson,ContactNumber,
		Fax,Email,[Address],Notes,
		ManufacturerType,BillingAddress,
		TaxId,ExpenseCategory,
		AutoTruckInsurance,VendorSubCategoryId,
		VendorStatus,Website,
		ContactExten,Vendrosource,
		AddressID,PaymentTerms,PaymentMethod)   
		output inserted.VendorId into @temptbl
		values(
		@vendor_name,@vendor_category,
		@contact_person,@contact_number,
		@fax,@email,
		@address,@notes,
		@ManufacturerType,@BillingAddress,
		@TaxId,@ExpenseCategory,
		@AutoTruckInsurance,@VendorSubCategoryId,
		@VendorStatus,@Website,
		@ContactExten,@Vendrosource,
		@AddressID,@PaymentTerms,@PaymentMethod) 
		
		select @vendor_id=ID from @temptbl
		
		update tblVendorEmail set 
		VendorID=@vendor_id
		where TempID=@TempID
		
		update tblVendorAddress set
		VendorId=@vendor_id
		where TempID=@TempID
		
		update tbl_VendorNotes set VendorId=@vendor_id where TempId=@NotesTempID
		
		--if(@VendorSubCategoryId > 0)
		--begin
		--insert into tbl_Vendor_VendorSubCat(VendorId,VendorSubCatId)
		--values (@vendor_id,@VendorSubCategoryId)
		--end
		
		--if(@vendor_category > 0)
		--begin
		--insert into tbl_Vendor_VendorCat(VendorId,VendorCatId)
		--values (@vendor_id,@vendor_category)
		--end
		
		if(@VendorCategories != '')
		Begin
			insert into tbl_Vendor_VendorCat(VendorId,VendorCatId)
			SELECT @vendor_id,Item FROM dbo.SplitString(@VendorCategories, ',')
		End
		
		if(@VendorSubCategories != '')
		Begin
			insert into tbl_Vendor_VendorSubCat(VendorId,VendorSubCatId)
			SELECT @vendor_id,Item FROM dbo.SplitString(@VendorSubCategories, ',')
		End
		
end




GO


