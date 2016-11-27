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