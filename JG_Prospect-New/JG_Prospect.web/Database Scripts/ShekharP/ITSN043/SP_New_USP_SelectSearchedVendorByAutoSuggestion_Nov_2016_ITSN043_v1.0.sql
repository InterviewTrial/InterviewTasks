USE [JGBS_Interview]
GO
/****** Object:  StoredProcedure [dbo].[USP_SelectSearchedVendorByAutoSuggestion]    Script Date: 11/24/2016 7:14:07 PM ******/
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
	LEFT OUTER JOIN [dbo].[tbl_VendorCat_VendorSubCat] vvsc ON vvsc.[VendorCategoryId] =  tv.[VendorCategoryId]
	LEFT JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCategoryId] 
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
	LEFT OUTER JOIN [dbo].[tbl_VendorCat_VendorSubCat] vvsc ON vvsc.[VendorCategoryId] =  tv.[VendorCategoryId]
	LEFT JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCategoryId] 
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
	LEFT OUTER JOIN [dbo].[tbl_VendorCat_VendorSubCat] vvsc ON vvsc.[VendorCategoryId] =  tv.[VendorCategoryId]
	LEFT JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCategoryId] 
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
	LEFT OUTER JOIN [dbo].[tbl_VendorCat_VendorSubCat] vvsc ON vvsc.[VendorCategoryId] =  tv.[VendorCategoryId]
	LEFT JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCategoryId] 
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
	LEFT OUTER JOIN [dbo].[tbl_VendorCat_VendorSubCat] vvsc ON vvsc.[VendorCategoryId] =  tv.[VendorCategoryId]
	LEFT JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCategoryId] 
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
	LEFT OUTER JOIN [dbo].[tbl_VendorCat_VendorSubCat] vvsc ON vvsc.[VendorCategoryId] =  tv.[VendorCategoryId]
	LEFT JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCategoryId] 
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
	LEFT OUTER JOIN [dbo].[tbl_VendorCat_VendorSubCat] vvsc ON vvsc.[VendorCategoryId] =  tv.[VendorCategoryId]
	LEFT JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCategoryId] 
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
	LEFT OUTER JOIN [dbo].[tbl_VendorCat_VendorSubCat] vvsc ON vvsc.[VendorCategoryId] =  tv.[VendorCategoryId]
	LEFT JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCategoryId] 
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
	LEFT OUTER JOIN [dbo].[tbl_VendorCat_VendorSubCat] vvsc ON vvsc.[VendorCategoryId] =  tv.[VendorCategoryId]
	LEFT JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCategoryId] 
WHERE tv.BillingAddress = @SearchValue
ORDER BY VendorName
END

END TRY

BEGIN CATCH 
   PRINT 'There was an error. Check to make sure object exists.'
   PRINT error_message()
END CATCH 






