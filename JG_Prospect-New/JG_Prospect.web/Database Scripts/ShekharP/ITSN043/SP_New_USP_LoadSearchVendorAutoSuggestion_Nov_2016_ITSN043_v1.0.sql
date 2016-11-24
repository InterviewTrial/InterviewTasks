USE [JGBS_Interview]
GO
/****** Object:  StoredProcedure [dbo].[USP_LoadSearchVendorAutoSuggestion]    Script Date: 11/24/2016 7:07:25 PM ******/
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
	LEFT OUTER JOIN [dbo].[tbl_VendorCat_VendorSubCat] vvsc ON vvsc.[VendorCategoryId] =  tv.[VendorCategoryId]
	LEFT JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCategoryId] 
   WHERE tv.VendorId LIKE '%' + @stringToFind +'%'

   UNION

   SELECT DISTINCT TOP 3 tv.VendorName AS AutoSuggest, 'VendorName' AS Category 
	FROM [dbo].[tblvendors] tv 
	INNER JOIN [dbo].[tbl_Vendor_VendorCat] tvVcat ON tv.VendorId=tvVcat.Vendorid  
	LEFT OUTER JOIN [dbo].[tblVendorAddress] tvAdd ON tv.VendorId=tvAdd.VendorId 
	INNER JOIN [dbo].[tblVendorCategory] vc ON vc.[VendorCategpryId] = tv.[VendorCategoryId]
	INNER JOIN [dbo].[tblProductVendorCat] pvc ON pvc.[VendorCategoryId] = vc.[VendorCategpryId]
	INNER JOIN [dbo].[tblProductMaster] pm ON pm.[ProductId] = pvc.[ProductCategoryId] 
	LEFT OUTER JOIN [dbo].[tbl_VendorCat_VendorSubCat] vvsc ON vvsc.[VendorCategoryId] =  tv.[VendorCategoryId]
	LEFT JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCategoryId] 
   WHERE tv.VendorName LIKE '%' + @stringToFind +'%'
   
   UNION

   SELECT DISTINCT TOP 3 CAST(tv.VendorCategoryId AS varchar)  AS AutoSuggest, 'VendorCategoryId' AS Category 
	FROM [dbo].[tblvendors] tv 
	INNER JOIN [dbo].[tbl_Vendor_VendorCat] tvVcat ON tv.VendorId=tvVcat.Vendorid  
	LEFT OUTER JOIN [dbo].[tblVendorAddress] tvAdd ON tv.VendorId=tvAdd.VendorId 
	INNER JOIN [dbo].[tblVendorCategory] vc ON vc.[VendorCategpryId] = tv.[VendorCategoryId]
	INNER JOIN [dbo].[tblProductVendorCat] pvc ON pvc.[VendorCategoryId] = vc.[VendorCategpryId]
	INNER JOIN [dbo].[tblProductMaster] pm ON pm.[ProductId] = pvc.[ProductCategoryId] 
	LEFT OUTER JOIN [dbo].[tbl_VendorCat_VendorSubCat] vvsc ON vvsc.[VendorCategoryId] =  tv.[VendorCategoryId]
	LEFT JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCategoryId] 
   WHERE tv.VendorCategoryId LIKE '%' + @stringToFind +'%'

   UNION

   SELECT DISTINCT TOP 3 tv.ContactPerson  AS AutoSuggest, 'ContactPerson' AS Category 
	FROM [dbo].[tblvendors] tv 
	INNER JOIN [dbo].[tbl_Vendor_VendorCat] tvVcat ON tv.VendorId=tvVcat.Vendorid  
	LEFT OUTER JOIN [dbo].[tblVendorAddress] tvAdd ON tv.VendorId=tvAdd.VendorId 
	INNER JOIN [dbo].[tblVendorCategory] vc ON vc.[VendorCategpryId] = tv.[VendorCategoryId]
	INNER JOIN [dbo].[tblProductVendorCat] pvc ON pvc.[VendorCategoryId] = vc.[VendorCategpryId]
	INNER JOIN [dbo].[tblProductMaster] pm ON pm.[ProductId] = pvc.[ProductCategoryId] 
	LEFT OUTER JOIN [dbo].[tbl_VendorCat_VendorSubCat] vvsc ON vvsc.[VendorCategoryId] =  tv.[VendorCategoryId]
	LEFT JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCategoryId] 
   WHERE tv.ContactPerson LIKE '%' + @stringToFind +'%'

   UNION

   SELECT DISTINCT TOP 3 tv.ContactNumber  AS AutoSuggest, 'ContactNumber' AS Category 
	FROM [dbo].[tblvendors] tv 
	INNER JOIN [dbo].[tbl_Vendor_VendorCat] tvVcat ON tv.VendorId=tvVcat.Vendorid  
	LEFT OUTER JOIN [dbo].[tblVendorAddress] tvAdd ON tv.VendorId=tvAdd.VendorId 
	INNER JOIN [dbo].[tblVendorCategory] vc ON vc.[VendorCategpryId] = tv.[VendorCategoryId]
	INNER JOIN [dbo].[tblProductVendorCat] pvc ON pvc.[VendorCategoryId] = vc.[VendorCategpryId]
	INNER JOIN [dbo].[tblProductMaster] pm ON pm.[ProductId] = pvc.[ProductCategoryId] 
	LEFT OUTER JOIN [dbo].[tbl_VendorCat_VendorSubCat] vvsc ON vvsc.[VendorCategoryId] =  tv.[VendorCategoryId]
	LEFT JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCategoryId] 
   WHERE tv.ContactNumber LIKE '%' + @stringToFind +'%'

   UNION

   SELECT DISTINCT TOP 3 tv.Fax  AS AutoSuggest, 'Fax' AS Category 
	FROM [dbo].[tblvendors] tv 
	INNER JOIN [dbo].[tbl_Vendor_VendorCat] tvVcat ON tv.VendorId=tvVcat.Vendorid  
	LEFT OUTER JOIN [dbo].[tblVendorAddress] tvAdd ON tv.VendorId=tvAdd.VendorId 
	INNER JOIN [dbo].[tblVendorCategory] vc ON vc.[VendorCategpryId] = tv.[VendorCategoryId]
	INNER JOIN [dbo].[tblProductVendorCat] pvc ON pvc.[VendorCategoryId] = vc.[VendorCategpryId]
	INNER JOIN [dbo].[tblProductMaster] pm ON pm.[ProductId] = pvc.[ProductCategoryId] 
	LEFT OUTER JOIN [dbo].[tbl_VendorCat_VendorSubCat] vvsc ON vvsc.[VendorCategoryId] =  tv.[VendorCategoryId]
	LEFT JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCategoryId] 
   WHERE tv.Fax LIKE '%' + @stringToFind +'%'

   UNION

   SELECT DISTINCT TOP 3 tv.Email  AS AutoSuggest, 'Email' AS Category 
	FROM [dbo].[tblvendors] tv 
	INNER JOIN [dbo].[tbl_Vendor_VendorCat] tvVcat ON tv.VendorId=tvVcat.Vendorid  
	LEFT OUTER JOIN [dbo].[tblVendorAddress] tvAdd ON tv.VendorId=tvAdd.VendorId 
	INNER JOIN [dbo].[tblVendorCategory] vc ON vc.[VendorCategpryId] = tv.[VendorCategoryId]
	INNER JOIN [dbo].[tblProductVendorCat] pvc ON pvc.[VendorCategoryId] = vc.[VendorCategpryId]
	INNER JOIN [dbo].[tblProductMaster] pm ON pm.[ProductId] = pvc.[ProductCategoryId] 
	LEFT OUTER JOIN [dbo].[tbl_VendorCat_VendorSubCat] vvsc ON vvsc.[VendorCategoryId] =  tv.[VendorCategoryId]
	LEFT JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCategoryId] 
   WHERE tv.Email LIKE '%' + @stringToFind +'%'

   UNION

   SELECT DISTINCT TOP 3 tv.[Address]  AS AutoSuggest, 'Address' AS Category 
	FROM [dbo].[tblvendors] tv 
	INNER JOIN [dbo].[tbl_Vendor_VendorCat] tvVcat ON tv.VendorId=tvVcat.Vendorid  
	LEFT OUTER JOIN [dbo].[tblVendorAddress] tvAdd ON tv.VendorId=tvAdd.VendorId 
	INNER JOIN [dbo].[tblVendorCategory] vc ON vc.[VendorCategpryId] = tv.[VendorCategoryId]
	INNER JOIN [dbo].[tblProductVendorCat] pvc ON pvc.[VendorCategoryId] = vc.[VendorCategpryId]
	INNER JOIN [dbo].[tblProductMaster] pm ON pm.[ProductId] = pvc.[ProductCategoryId] 
	LEFT OUTER JOIN [dbo].[tbl_VendorCat_VendorSubCat] vvsc ON vvsc.[VendorCategoryId] =  tv.[VendorCategoryId]
	LEFT JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCategoryId] 
   WHERE tv.[Address] LIKE '%' + @stringToFind +'%'

   UNION

   SELECT DISTINCT TOP 3 tv.BillingAddress  AS BillingAddress, 'BillingAddress' AS Category 
	FROM [dbo].[tblvendors] tv 
	INNER JOIN [dbo].[tbl_Vendor_VendorCat] tvVcat ON tv.VendorId=tvVcat.Vendorid  
	LEFT OUTER JOIN [dbo].[tblVendorAddress] tvAdd ON tv.VendorId=tvAdd.VendorId 
	INNER JOIN [dbo].[tblVendorCategory] vc ON vc.[VendorCategpryId] = tv.[VendorCategoryId]
	INNER JOIN [dbo].[tblProductVendorCat] pvc ON pvc.[VendorCategoryId] = vc.[VendorCategpryId]
	INNER JOIN [dbo].[tblProductMaster] pm ON pm.[ProductId] = pvc.[ProductCategoryId] 
	LEFT OUTER JOIN [dbo].[tbl_VendorCat_VendorSubCat] vvsc ON vvsc.[VendorCategoryId] =  tv.[VendorCategoryId]
	LEFT JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCategoryId] 
   WHERE tv.BillingAddress LIKE '%' + @stringToFind +'%'
)

SELECT * FROM SuggestionForVendors s 
ORDER BY s.Category DESC, s.label

END TRY

BEGIN CATCH 
   PRINT 'There was an error. Check to make sure object exists.'
   PRINT error_message()
END CATCH 






