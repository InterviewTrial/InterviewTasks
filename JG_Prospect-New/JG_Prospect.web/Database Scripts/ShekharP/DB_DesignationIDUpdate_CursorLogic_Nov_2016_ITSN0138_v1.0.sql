DECLARE @InstallUserID INT
DECLARE @Designation VARCHAR(50)
DECLARE @DesignationIDFromDesignationTable INT
--------------------------------------------------------
DECLARE @DesignationUpdateCursor CURSOR
SET @DesignationUpdateCursor = CURSOR FAST_FORWARD
FOR
SELECT Id, Designation
FROM [dbo].[tblInstallUsers]
OPEN @DesignationUpdateCursor
FETCH NEXT FROM @DesignationUpdateCursor
INTO @InstallUserID,@Designation
WHILE @@FETCH_STATUS = 0
BEGIN
SELECT @DesignationIDFromDesignationTable = case @Designation
WHEN 'Recruiter' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='Recruiter')
WHEN 'IT - Sr .Net Developer' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='IT - Sr .Net Developer')
WHEN 'IT - PHP Developer' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='IT - PHP Developer')
WHEN 'SSE' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='IT - SEO / BackLinking')
WHEN 'Installer - Helper' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='Installer - Helper')
WHEN 'Installer - Journeyman' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='Installer - Journeyman')
WHEN 'IT - SEO / BackLinking' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='Installer - Foreman')
WHEN 'InstallerLeadMechanic' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='Installer - Lead mechanic')
WHEN 'Jr. Sales' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='Jr. Sales')
WHEN 'SubContractor' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='SubContractor')
WHEN 'Sr. Sales' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='Sr. Sales')
WHEN 'Installer - Foreman' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='Installer - Foreman')
WHEN 'Select' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='Recruiter')
WHEN 'Jr Project Manager' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='Jr Project Manager')
WHEN 'Installer' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='Installer - Helper')
WHEN 'IT - Jr .Net Developer' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='IT - Jr .Net Developer')
WHEN 'Admin' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='Admin')
WHEN 'IT - Android Developer' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='IT - Android Developer')
WHEN 'Forman' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='Installer - Foreman')
WHEN 'IT - Network Admin' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='IT - Network Admin')
WHEN 'Commercial Only' THEN (SELECT TOP 1 ID FROM tbl_Designation WHERE DesignationName='Commercial Only')
ELSE NULL
END
IF @DesignationIDFromDesignationTable IS NOT NULL
BEGIN
UPDATE [dbo].[tblInstallUsers] SET DesignationID = @DesignationIDFromDesignationTable
WHERE ID = @InstallUserID
END
--PRINT CAST(@InstallUserID AS VARCHAR) +'-'+ @Designation +'-'+ CAST(@DesignationIDFromDesignationTable AS VARCHAR)
FETCH NEXT FROM @DesignationUpdateCursor
INTO @InstallUserID,@Designation
END
CLOSE @DesignationUpdateCursor
DEALLOCATE @DesignationUpdateCursor