USE [JGBS_Interview]
GO
/****** Object:  StoredProcedure [dbo].[UDP_GetVendors]    Script Date: 11/24/2016 7:09:11 PM ******/
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
	LEFT OUTER JOIN [dbo].[tbl_VendorCat_VendorSubCat] vvsc ON vvsc.[VendorCategoryId] =  tv.[VendorCategoryId]
	LEFT JOIN [dbo].[tblVendorSubCategory] vsc ON vsc.[VendorSubCategoryId] =  vvsc.[VendorSubCategoryId] 
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