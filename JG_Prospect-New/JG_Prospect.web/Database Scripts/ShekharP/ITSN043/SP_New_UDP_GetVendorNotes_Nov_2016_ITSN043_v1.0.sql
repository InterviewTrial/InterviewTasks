USE [JGBS_Interview]
GO

/****** Object:  StoredProcedure [dbo].[UDP_GetVendorNotes]    Script Date: 11/26/2016 6:50:09 PM ******/
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


