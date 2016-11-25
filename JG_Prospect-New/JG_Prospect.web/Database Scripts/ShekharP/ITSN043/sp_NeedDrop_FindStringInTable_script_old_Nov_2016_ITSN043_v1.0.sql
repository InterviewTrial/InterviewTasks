USE [JGBS_Interview]
GO
/****** Object:  StoredProcedure [dbo].[sp_FindStringInTable]    Script Date: 11/24/2016 7:44:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_FindStringInTable] 
@stringToFind VARCHAR(100)
,@table sysname 
AS

BEGIN TRY

SET NOCOUNT ON;


   DECLARE @sqlCommand varchar(max) = 'SELECT VendorId,VendorName,AddressID as addressId FROM [' + @table + '] WHERE ' 
	   
   SELECT @sqlCommand = @sqlCommand + '[' + COLUMN_NAME + '] LIKE ''' + @stringToFind + ''' OR '
   FROM INFORMATION_SCHEMA.COLUMNS 
   WHERE TABLE_NAME = @table 
   AND DATA_TYPE IN ('char','nchar','ntext','nvarchar','text','varchar')

   SET @sqlCommand = left(@sqlCommand,len(@sqlCommand)-3)
   EXEC (@sqlCommand)
   PRINT @sqlCommand
END TRY

BEGIN CATCH 
   PRINT 'There was an error. Check to make sure object exists.'
   PRINT error_message()
END CATCH 






