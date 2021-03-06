SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jaylem
-- Create date: 26-Nov-2016
-- Description:	Returns all/selected Department 
-- =============================================
CREATE PROCEDURE [dbo].[UDP_GetDepartmentsByFilter]
	@DepId As Int
	AS
BEGIN
	SET NOCOUNT ON;	
	
	SELECT ID,DepartmentName,IsActive
	FROM tbl_Department
	WHERE ID = (CASE WHEN @DepId=0 THEN ID ELSE @DepId END)

END

GO
-- =============================================
-- Author:		Jaylem
-- Create date: 26-Nov-2016
-- Description:	Add/Edit Department details.
-- =============================================
CREATE PROCEDURE UDP_DepartmentInsertUpdate 
	@ID int,
	@DepartmentName varchar(50),
	@IsActive bit,
	@result int output  
AS
BEGIN
	SET NOCOUNT ON;
	SET @result=0;

	IF (SELECT TOP 1 ID FROM tbl_Department WHERE ID=@ID) Is Null
	BEGIN
		INSERT INTO tbl_Department(DepartmentName,IsActive)
		VALUES (@DepartmentName,@IsActive)
		Set @result =@@IDENTITY;
	END
	ELSE
	BEGIN
		UPDATE tbl_Department
		SET DepartmentName=@DepartmentName
		,IsActive = @IsActive
		WHERE ID=@ID
		Set @result =@ID;
	END
	return @result
END
GO

-- =============================================
-- Author:		Jaylem
-- Create date: 26-Nov-2016
-- Description:	Returns all/selected Designation 
-- =============================================
CREATE PROCEDURE [dbo].[UDP_GetDesignationByFilter]
	@DepartmentID As Int,
	@DesignationID As Int
	AS
BEGIN
	SET NOCOUNT ON;	
	
	SELECT ds.ID
	,ds.DesignationName
	,ds.IsActive
	,ds.DepartmentID
	,dt.DepartmentName
	FROM tbl_Designation ds
	INNER JOIN tbl_Department dt On dt.ID = ds.DepartmentID
	WHERE ds.ID = (CASE WHEN @DesignationID=0 THEN ds.ID ELSE @DesignationID END)
	AND ds.DepartmentID = (CASE WHEN @DepartmentID=0 THEN ds.DepartmentID ELSE @DepartmentID END)

END

GO
-- =============================================
-- Author:		Jaylem
-- Create date: 26-Nov-2016
-- Description:	Add/Edit Designation details.
-- =============================================
CREATE PROCEDURE UDP_DesignationInsertUpdate 
	@ID int,
	@DesignationName varchar(50),
	@IsActive bit,
	@DepartmentID Int,
	@result int output  
AS
BEGIN
	SET NOCOUNT ON;
	SET @result=0;

	IF (SELECT TOP 1 ID FROM tbl_Designation WHERE ID=@ID) Is Null
	BEGIN
		INSERT INTO tbl_Designation(DesignationName,IsActive,DepartmentID)
		VALUES (@DesignationName,@IsActive,@DepartmentID)
		Set @result =@@IDENTITY;
	END
	ELSE
	BEGIN
		UPDATE tbl_Designation
		SET DesignationName=@DesignationName
		,DepartmentID=@DepartmentID
		,IsActive = @IsActive
		WHERE ID=@ID
		Set @result =@ID;
	END
	return @result
END

GO