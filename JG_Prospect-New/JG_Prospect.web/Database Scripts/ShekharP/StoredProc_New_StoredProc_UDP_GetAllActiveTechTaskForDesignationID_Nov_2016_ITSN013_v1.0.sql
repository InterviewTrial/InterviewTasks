-- =============================================
-- Author:		Shekhar Pawar
-- Create date: 01-Dec-2016
-- Description:	Get List of TechTask for DesignationID
-- =============================================
CREATE PROCEDURE [dbo].[UDP_GetAllActiveTechTaskForDesignationID] 
@DesignationID INT = 0
AS
BEGIN
	SET NOCOUNT ON;
	SELECT 
		t.TaskId, t.Title
	FROM 
	[dbo].[tblTask] t INNER JOIN [dbo].[tblTaskDesignations] td
		ON t.TaskId = td.TaskId
	WHERE  t.IsTechTask = 1
		AND 
	td.Designation IN(
		SELECT DesignationName 
			FROM 
			[dbo].[tbl_Designation] 
		WHERE ID = @DesignationID)
END