USE [JGBS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh Keraliya
-- Create date: 07/15/2016
-- Description:	Update task priority
-- =============================================
CREATE PROCEDURE [dbo].[usp_UpdateTaskPriority] 
(	
	@TaskId int , 	
	@TaskPriority tinyint
)
AS
BEGIN
	
	UPDATE tblTask
	SET TaskPriority = @TaskPriority
	WHERE TaskId = @TaskId

END
GO

 


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh Keraliya
-- Create date: 8/25/16
-- Description:	This procedure is used to search tasks by different parameters.
-- =============================================
ALTER PROCEDURE [dbo].[uspSearchTasks]
	@Designations	VARCHAR(4000) = '0',
	@UserId			INT = NULL,
	@Status			TINYINT = NULL,
	@CreatedFrom	DATETIME = NULL,
	@CreatedTo		DATETIME = NULL,
	@SearchTerm		VARCHAR(250) = NULL,
	@SortExpression	VARCHAR(250) = 'CreatedOn DESC',
	@PageIndex		INT = 0,
	@PageSize		INT = 10
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET @PageIndex = @PageIndex + 1

	;WITH Tasklist
	AS
	(	
		SELECT 
			--TaskUserMatch.IsMatch AS TaskUserMatch,
			--TaskUserRequestsMatch.IsMatch AS TaskUserRequestsMatch,
			--TaskDesignationMatch.IsMatch AS TaskDesignationMatch,
			Tasks.TaskId, 
			Tasks.Title, 
			Tasks.InstallId, 
			Tasks.[Status], 
			Tasks.[CreatedOn],
			Tasks.[DueDate], 
			Tasks.IsDeleted,
			Tasks.CreatedBy,
			Tasks.TaskPriority,
			STUFF
			(
				(SELECT  CAST(', ' + td.Designation as VARCHAR) AS Designation
				FROM tblTaskDesignations td
				WHERE td.TaskId = Tasks.TaskId
				FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)')
				,1
				,2
				,' '
			) AS TaskDesignations,
			STUFF
			(
				(SELECT  CAST(', ' + u.FristName as VARCHAR) AS Name
				FROM tblTaskAssignedUsers tu
					INNER JOIN tblInstallUsers u ON tu.UserId = u.Id
				WHERE tu.TaskId = Tasks.TaskId
				FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)')
				,1
				,2
				,' '
			) AS TaskAssignedUsers,
			STUFF
			(
				(SELECT  CAST(', ' + CAST(tu.UserId AS VARCHAR) + ':' + u.FristName as VARCHAR) AS Name
				FROM tblTaskAssignmentRequests tu
					INNER JOIN tblInstallUsers u ON tu.UserId = u.Id
				WHERE tu.TaskId = Tasks.TaskId
				FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)')
				,1
				,2
				,' '
			) AS TaskAssignmentRequestUsers
		FROM          
			tblTask AS Tasks 
			OUTER APPLY
			(
				SELECT TOP 1 
						1 AS IsMatch,
						TaskUsers.UserId AS UserId,
						UsersMaster.FristName AS FristName
				FROM tblTaskAssignedUsers TaskUsers
						LEFT JOIN tblInstallUsers AS UsersMaster ON TaskUsers.UserId = UsersMaster.Id
				WHERE 
					TaskUsers.TaskId = Tasks.TaskId AND
					TaskUsers.[UserId] = ISNULL(@UserId, TaskUsers.[UserId]) AND
					1 = CASE
							WHEN @UserId IS NOT NULL THEN 1 -- set true, when user id is provided. so that join will handle record filtering and search term will have no effect on user.
							WHEN @SearchTerm IS NULL THEN 1 -- set true, when search term is null. so that join will handle record filtering and search term will have no effect on user.
							WHEN UsersMaster.FristName LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if users with given search terms are available. 
							ELSE 0
						END
			) As TaskUserMatch
			OUTER APPLY
			(
				SELECT TOP 1 
						1 AS IsMatch,
						TaskUsers.UserId AS UserId,
						UsersMaster.FristName AS FristName
				FROM tblTaskAssignmentRequests TaskUsers
						LEFT JOIN tblInstallUsers AS UsersMaster ON TaskUsers.UserId = UsersMaster.Id
				WHERE 
					TaskUsers.TaskId = Tasks.TaskId AND
					TaskUsers.[UserId] = ISNULL(@UserId, TaskUsers.[UserId]) AND
					1 = CASE
							WHEN @UserId IS NOT NULL THEN 1 -- set true, when user id is provided. so that join will handle record filtering and search term will have no effect on user.
							WHEN @SearchTerm IS NULL THEN 1 -- set true, when search term is null. so that join will handle record filtering and search term will have no effect on user.
							WHEN UsersMaster.FristName LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if users with given search terms are available. 
							ELSE 0
						END
			) As TaskUserRequestsMatch
			OUTER APPLY
			(
				SELECT TOP 1 
						CASE
						WHEN @SearchTerm IS NULL THEN
							CASE
								WHEN @Designations = '0' THEN 1
								WHEN EXISTS (SELECT ss.Item  FROM dbo.SplitString(@Designations,',') ss WHERE ss.Item = TaskDesignations.Designation) THEN 1
								ELSE 0 
							END
						ELSE 
							CASE
								WHEN @Designations = '0' AND TaskDesignations.Designation LIKE '%' + @SearchTerm + '%' THEN 1
								WHEN (Tasks.[InstallId] LIKE '%' + @SearchTerm + '%'  OR Tasks.[Title] LIKE '%' + @SearchTerm + '%') THEN 1
								ELSE 0
							END
						END AS IsMatch,
						TaskDesignations.Designation AS Designation
				FROM tblTaskDesignations AS TaskDesignations
				WHERE 
					TaskDesignations.TaskId = Tasks.TaskId AND
					1 = CASE
							WHEN @Designations = '0' AND @SearchTerm IS NULL THEN 1 -- set true, when '0' (all designations) is provided with no search term.
							WHEN @Designations = '0' AND @SearchTerm IS NOT NULL AND TaskDesignations.Designation LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if designations found by search term.
							WHEN EXISTS (SELECT ss.Item  FROM dbo.SplitString(@Designations,',') ss WHERE ss.Item = TaskDesignations.Designation) THEN 1 -- filter based on provided designations.
							ELSE 0
						END
			)  AS TaskDesignationMatch
		WHERE
			Tasks.ParentTaskId IS NULL 
			AND 
			1 = CASE 
					-- filter records only by user, when search term is not provided.
					WHEN @SearchTerm IS NULL THEN
						CASE
							WHEN TaskUserMatch.IsMatch = 1 OR TaskDesignationMatch.IsMatch = 1 THEN 1
							WHEN TaskUserRequestsMatch.IsMatch = 1 OR TaskDesignationMatch.IsMatch = 1 THEN 1
							ELSE 0
						END
					-- filter records by installid, title, users when search term is provided.
					ELSE
						CASE
							WHEN Tasks.[InstallId] LIKE '%' + @SearchTerm + '%' THEN 1
							WHEN Tasks.[Title] LIKE '%' + @SearchTerm + '%' THEN 1
							WHEN TaskUserMatch.IsMatch = 1 THEN 1
							WHEN TaskUserRequestsMatch.IsMatch = 1 THEN 1
							ELSE 0
						END
				END
			--AND
			--1 = CASE 
			--	WHEN @SearchTerm IS NULL THEN 
			--		CASE
			--			WHEN TaskDesignationMatch.IsMatch = 1 THEN 1
			--			ELSE 0
			--		END
			--	ELSE
			--		CASE
			--			WHEN Tasks.[InstallId] LIKE '%' + @SearchTerm + '%' THEN 1
			--			WHEN Tasks.[Title] LIKE '%' + @SearchTerm + '%' THEN 1
			--			WHEN TaskDesignationMatch.IsMatch = 1 THEN 1
			--			ELSE 0
			--		END
			--END
			AND
			Tasks.[Status] = ISNULL(@Status,Tasks.[Status]) 
			AND
			CONVERT(VARCHAR,Tasks.[CreatedOn],101)  >= ISNULL(@CreatedFrom,CONVERT(VARCHAR,Tasks.[CreatedOn],101)) AND
			CONVERT(VARCHAR,Tasks.[CreatedOn],101)  <= ISNULL(@CreatedTo,CONVERT(VARCHAR,Tasks.[CreatedOn],101))
	),

FinalData AS( 
	SELECT * ,
			Row_number() OVER
			(
				ORDER BY
					CASE WHEN @SortExpression = 'UserID DESC' THEN Tasklist.TaskAssignedUsers END DESC,
					CASE WHEN @SortExpression = 'CreatedOn DESC' THEN Tasklist.CreatedOn END DESC,
					CASE WHEN @SortExpression = 'Status ASC' THEN Tasklist.[Status] END ASC
			) AS RowNo
	FROM Tasklist )
	
	SELECT * FROM FinalData 
	WHERE  
		RowNo BETWEEN (@PageIndex - 1) * @PageSize + 1 AND 
		@PageIndex * @PageSize

	SELECT 
		COUNT(DISTINCT Tasks.TaskId) AS VirtualCount
	FROM          
		tblTask AS Tasks 
		OUTER APPLY
		(
			SELECT TOP 1 
					1 AS IsMatch,
					TaskUsers.UserId AS UserId,
					UsersMaster.FristName AS FristName
			FROM tblTaskAssignedUsers TaskUsers
					LEFT JOIN tblInstallUsers AS UsersMaster ON TaskUsers.UserId = UsersMaster.Id
			WHERE 
				TaskUsers.TaskId = Tasks.TaskId AND
				TaskUsers.[UserId] = ISNULL(@UserId, TaskUsers.[UserId]) AND
				1 = CASE
						WHEN @UserId IS NOT NULL THEN 1 -- set true, when user id is provided. so that join will handle record filtering and search term will have no effect on user.
						WHEN @SearchTerm IS NULL THEN 1 -- set true, when search term is null. so that join will handle record filtering and search term will have no effect on user.
						WHEN UsersMaster.FristName LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if users with given search terms are available. 
						ELSE 0
					END
		) As TaskUserMatch
		OUTER APPLY
		(
			SELECT TOP 1 
					1 AS IsMatch,
					TaskUsers.UserId AS UserId,
					UsersMaster.FristName AS FristName
			FROM tblTaskAssignmentRequests TaskUsers
					LEFT JOIN tblInstallUsers AS UsersMaster ON TaskUsers.UserId = UsersMaster.Id
			WHERE 
				TaskUsers.TaskId = Tasks.TaskId AND
				TaskUsers.[UserId] = ISNULL(@UserId, TaskUsers.[UserId]) AND
				1 = CASE
						WHEN @UserId IS NOT NULL THEN 1 -- set true, when user id is provided. so that join will handle record filtering and search term will have no effect on user.
						WHEN @SearchTerm IS NULL THEN 1 -- set true, when search term is null. so that join will handle record filtering and search term will have no effect on user.
						WHEN UsersMaster.FristName LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if users with given search terms are available. 
						ELSE 0
					END
		) As TaskUserRequestsMatch
		OUTER APPLY
		(
			SELECT TOP 1 
					1 AS IsMatch,
					TaskDesignations.Designation AS Designation
			FROM tblTaskDesignations AS TaskDesignations
			WHERE 
				TaskDesignations.TaskId = Tasks.TaskId AND
				1 = CASE
						WHEN @Designations = '0' AND @SearchTerm IS NULL THEN 1 -- set true, when '0' (all designations) is provided with no search term.
						WHEN @Designations = '0' AND @SearchTerm IS NOT NULL AND TaskDesignations.Designation LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if designations found by search term.
						WHEN EXISTS (SELECT ss.Item  FROM dbo.SplitString(@Designations,',') ss WHERE ss.Item = TaskDesignations.Designation) THEN 1 -- filter based on provided designations.
						ELSE 0
					END
		)  AS TaskDesignationMatch
	WHERE
		Tasks.ParentTaskId IS NULL 
		AND 
		1 = CASE 
				-- filter records only by user, when search term is not provided.
				WHEN @SearchTerm IS NULL THEN
					CASE
						WHEN TaskUserMatch.IsMatch = 1 OR TaskDesignationMatch.IsMatch = 1 THEN 1
						WHEN TaskUserRequestsMatch.IsMatch = 1 OR TaskDesignationMatch.IsMatch = 1THEN 1
						ELSE 0
					END
				-- filter records by installid, title, users when search term is provided.
				ELSE
					CASE
						WHEN Tasks.[InstallId] LIKE '%' + @SearchTerm + '%' THEN 1
						WHEN Tasks.[Title] LIKE '%' + @SearchTerm + '%' THEN 1
						WHEN TaskUserMatch.IsMatch = 1 THEN 1
						WHEN TaskUserRequestsMatch.IsMatch = 1 THEN 1
						ELSE 0
					END
			END
		--AND
		--1 = CASE 
		--		WHEN @SearchTerm IS NULL THEN 
		--			CASE
		--				WHEN TaskDesignationMatch.IsMatch = 1 THEN 1
		--				ELSE 0
		--			END
		--		ELSE
		--			CASE
		--				WHEN Tasks.[InstallId] LIKE '%' + @SearchTerm + '%' THEN 1
		--				WHEN Tasks.[Title] LIKE '%' + @SearchTerm + '%' THEN 1
		--				WHEN TaskDesignationMatch.IsMatch = 1 THEN 1
		--				ELSE 0
		--			END
		--	END 
		AND
		Tasks.[Status] = ISNULL(@Status,Tasks.[Status]) 
		AND
		CONVERT(VARCHAR,Tasks.[CreatedOn],101)  >= ISNULL(@CreatedFrom,CONVERT(VARCHAR,Tasks.[CreatedOn],101)) AND
		CONVERT(VARCHAR,Tasks.[CreatedOn],101)  <= ISNULL(@CreatedTo,CONVERT(VARCHAR,Tasks.[CreatedOn],101))

END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 13 Sep 16
-- Update date: 06 Oct 16
-- Description:	Get last checked-in Task specification from history.
-- =============================================
ALTER PROCEDURE [dbo].[GetLatestTaskWorkSpecification]
	@TaskId int,
	@Status Bit = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- freezed copy (copy with given status).
	SELECT TOP 1
			
			s.Id AS Id,
			sv.[Status] AS [Status],
			sv.Content,
			sv.IsInstallUser,
			sv.DateCreated,
			LastUser.Id AS LastUserId,
			LastUser.Username AS LastUsername,
			LastUser.FirstName AS LastUserFirstName,
			LastUser.LastName AS LastUserLastName,
			LastUser.Email AS LastUserEmail

	FROM tblTaskWorkSpecification s
			INNER JOIN tblTaskWorkSpecificationVersions sv ON s.Id= sv.TaskWorkSpecificationId
			OUTER APPLY
			(
				SELECT TOP 1 iu.Id,iu.FristName AS Username, iu.FristName AS FirstName, iu.LastName, iu.Email
				FROM tblInstallUsers iu
				WHERE iu.Id = sv.UserId AND sv.IsInstallUser = 1
			
				UNION

				SELECT TOP 1 u.Id,u.Username AS Username, u.FirstName AS FirstName, u.LastName, u.Email
				FROM tblUsers u
				WHERE u.Id = sv.UserId AND sv.IsInstallUser = 0
			) AS LastUser
	WHERE s.TaskId = @TaskId AND sv.[Status] = @Status
	ORDER BY sv.DateCreated DESC

	-- working copy (last working copy).
    SELECT TOP 1
			
			s.Id AS Id,
			sv.[Status] AS [Status],
			sv.Content,
			sv.IsInstallUser,
			sv.DateCreated,
			CurrentUser.Id AS CurrentUserId,
			CurrentUser.Username AS CurrentUsername,
			CurrentUser.FirstName AS CurrentFirstName,
			CurrentUser.LastName AS CurrentLastName,
			CurrentUser.Email AS CurrentEmail

	FROM tblTaskWorkSpecification s
			INNER JOIN tblTaskWorkSpecificationVersions sv ON s.Id= sv.TaskWorkSpecificationId
			OUTER APPLY
			(
				SELECT TOP 1 iu.Id,iu.FristName AS Username, iu.FristName AS FirstName, iu.LastName, iu.Email
				FROM tblInstallUsers iu
				WHERE iu.Id = sv.UserId AND sv.IsInstallUser = 1
			
				UNION

				SELECT TOP 1 u.Id,u.Username AS Username, u.FirstName AS FirstName, u.LastName, u.Email
				FROM tblUsers u
				WHERE u.Id = sv.UserId AND sv.IsInstallUser = 0
			) AS CurrentUser
	WHERE s.TaskId = @TaskId
	ORDER BY sv.DateCreated DESC

END
GO

/*------------------------------------------------------------------------------------------------------*/
-- 7 OCT
/*------------------------------------------------------------------------------------------------------*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 07 Oct 16
-- Description:	Get all Task specifications related to a task, 
--				with optional status filter.
-- =============================================
-- EXEC GetTaskWorkSpecifications 115, 0
CREATE PROCEDURE [dbo].[GetTaskWorkSpecifications]
	@TaskId int,
	@Status bit = NULL,
	@PageIndex INT = NULL, 
	@PageSize INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @StartIndex INT  = 0

	IF @PageIndex IS NULL
	BEGIN
		SET @PageIndex = 0
	END

	IF @PageSize IS NULL
	BEGIN
		SET @PageSize = 0
	END

	SET @StartIndex = (@PageIndex * @PageSize) + 1

	;WITH TaskWorkSpecifications
	AS
	(
		-- working copies (last working copies for each specification).
		SELECT
				s.Id AS Id,
				sv.Id AS VersionId,
				sv.[Status] AS [Status],
				sv.Content AS Content,
				sv.IsInstallUser AS IsInstallUser,
				sv.DateCreated AS DateCreated,
				CurrentUser.Id AS CurrentUserId,
				CurrentUser.Username AS CurrentUsername,
				CurrentUser.FirstName AS CurrentFirstName,
				CurrentUser.LastName AS CurrentLastName,
				CurrentUser.Email AS CurrentEmail,
				ROW_NUMBER() OVER(ORDER BY s.ID ASC) AS RowNumber

		FROM tblTaskWorkSpecification s
				OUTER APPLY
				(
					SELECT TOP 1 *, ROW_NUMBER() OVER(ORDER BY ID DESC) AS RowNo
					FROM tblTaskWorkSpecificationVersions
					WHERE TaskWorkSpecificationId = s.Id
				) AS sv 
				OUTER APPLY
				(
					SELECT TOP 1 iu.Id,iu.FristName AS Username, iu.FristName AS FirstName, iu.LastName, iu.Email
					FROM tblInstallUsers iu
					WHERE iu.Id = sv.UserId AND sv.IsInstallUser = 1
			
					UNION

					SELECT TOP 1 u.Id,u.Username AS Username, u.FirstName AS FirstName, u.LastName, u.Email
					FROM tblUsers u
					WHERE u.Id = sv.UserId AND sv.IsInstallUser = 0
				) AS CurrentUser
		WHERE s.TaskId = @TaskId AND sv.[Status] = ISNULL(@Status,sv.[Status])
	)

			
	-- get records
	SELECT *
	FROM TaskWorkSpecifications
	WHERE 
		RowNumber >= @StartIndex AND 
		(
			@PageSize = 0 OR 
			RowNumber < (@StartIndex + @PageSize)
		)

	-- get record count
	SELECT COUNT(*) AS TotalRecordCount
	FROM tblTaskWorkSpecification s
				OUTER APPLY
				(
					SELECT TOP 1 *, ROW_NUMBER() OVER(ORDER BY ID DESC) AS RowNo
					FROM tblTaskWorkSpecificationVersions
					WHERE TaskWorkSpecificationId = s.Id
				) AS sv 
	WHERE s.TaskId = @TaskId AND sv.[Status] = ISNULL(@Status,sv.[Status])

END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 13 Sep 16
-- Description:	Get last checked-in Task specification from history.
-- =============================================
ALTER PROCEDURE [dbo].[GetLatestTaskWorkSpecification]
	@Id		INT,
	@TaskId INT,
	@Status BIT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- freezed copy (copy with given status).
	SELECT TOP 1
			
			s.Id AS Id,
			sv.[Status] AS [Status],
			sv.Content,
			sv.IsInstallUser,
			sv.DateCreated,
			LastUser.Id AS LastUserId,
			LastUser.Username AS LastUsername,
			LastUser.FirstName AS LastUserFirstName,
			LastUser.LastName AS LastUserLastName,
			LastUser.Email AS LastUserEmail

	FROM tblTaskWorkSpecification s
			INNER JOIN tblTaskWorkSpecificationVersions sv ON s.Id= sv.TaskWorkSpecificationId
			OUTER APPLY
			(
				SELECT TOP 1 iu.Id,iu.FristName AS Username, iu.FristName AS FirstName, iu.LastName, iu.Email
				FROM tblInstallUsers iu
				WHERE iu.Id = sv.UserId AND sv.IsInstallUser = 1
			
				UNION

				SELECT TOP 1 u.Id,u.Username AS Username, u.FirstName AS FirstName, u.LastName, u.Email
				FROM tblUsers u
				WHERE u.Id = sv.UserId AND sv.IsInstallUser = 0
			) AS LastUser

	WHERE 
			s.Id = @Id AND 
			s.TaskId = @TaskId AND 
			sv.[Status] = @Status

	ORDER BY sv.DateCreated DESC

	-- working copy (last working copy).
    SELECT TOP 2
			
			s.Id AS Id,
			sv.[Status] AS [Status],
			sv.Content,
			sv.IsInstallUser,
			sv.DateCreated,
			CurrentUser.Id AS CurrentUserId,
			CurrentUser.Username AS CurrentUsername,
			CurrentUser.FirstName AS CurrentFirstName,
			CurrentUser.LastName AS CurrentLastName,
			CurrentUser.Email AS CurrentEmail

	FROM tblTaskWorkSpecification s
			INNER JOIN tblTaskWorkSpecificationVersions sv ON s.Id= sv.TaskWorkSpecificationId
			OUTER APPLY
			(
				SELECT TOP 1 iu.Id,iu.FristName AS Username, iu.FristName AS FirstName, iu.LastName, iu.Email
				FROM tblInstallUsers iu
				WHERE iu.Id = sv.UserId AND sv.IsInstallUser = 1
			
				UNION

				SELECT TOP 1 u.Id,u.Username AS Username, u.FirstName AS FirstName, u.LastName, u.Email
				FROM tblUsers u
				WHERE u.Id = sv.UserId AND sv.IsInstallUser = 0
			) AS CurrentUser
	
	WHERE 
			s.Id = @Id AND 
			s.TaskId = @TaskId 

	ORDER BY sv.DateCreated DESC

END
GO


/*------------------------------------------------------------------------------------------------------*/
-- 8 OCT
/*------------------------------------------------------------------------------------------------------*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 13 Sep 16
-- Description:	Get last checked-in Task specification from history.
-- =============================================
ALTER PROCEDURE [dbo].[GetLatestTaskWorkSpecification]
	@Id		INT,
	@TaskId INT,
	@Status BIT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- last copy with given status.
	SELECT TOP 1
			
			s.Id AS Id,
			sv.[Status] AS [Status],
			sv.Content,
			sv.IsInstallUser,
			sv.DateCreated,
			LastUser.Id AS LastUserId,
			LastUser.Username AS LastUsername,
			LastUser.FirstName AS LastUserFirstName,
			LastUser.LastName AS LastUserLastName,
			LastUser.Email AS LastUserEmail

	FROM tblTaskWorkSpecification s
			INNER JOIN tblTaskWorkSpecificationVersions sv ON s.Id= sv.TaskWorkSpecificationId
			OUTER APPLY
			(
				SELECT TOP 1 iu.Id,iu.FristName AS Username, iu.FristName AS FirstName, iu.LastName, iu.Email
				FROM tblInstallUsers iu
				WHERE iu.Id = sv.UserId AND sv.IsInstallUser = 1
			
				UNION

				SELECT TOP 1 u.Id,u.Username AS Username, u.FirstName AS FirstName, u.LastName, u.Email
				FROM tblUsers u
				WHERE u.Id = sv.UserId AND sv.IsInstallUser = 0
			) AS LastUser

	WHERE 
			s.Id = @Id AND 
			s.TaskId = @TaskId AND 
			sv.[Status] = @Status

	ORDER BY sv.DateCreated DESC

	-- last 2 working copies with any status.
    SELECT TOP 2
			
			s.Id AS Id,
			sv.[Status] AS [Status],
			sv.Content,
			sv.IsInstallUser,
			sv.DateCreated,
			CurrentUser.Id AS CurrentUserId,
			CurrentUser.Username AS CurrentUsername,
			CurrentUser.FirstName AS CurrentFirstName,
			CurrentUser.LastName AS CurrentLastName,
			CurrentUser.Email AS CurrentEmail

	FROM tblTaskWorkSpecification s
			INNER JOIN tblTaskWorkSpecificationVersions sv ON s.Id= sv.TaskWorkSpecificationId
			OUTER APPLY
			(
				SELECT TOP 1 iu.Id,iu.FristName AS Username, iu.FristName AS FirstName, iu.LastName, iu.Email
				FROM tblInstallUsers iu
				WHERE iu.Id = sv.UserId AND sv.IsInstallUser = 1
			
				UNION

				SELECT TOP 1 u.Id,u.Username AS Username, u.FirstName AS FirstName, u.LastName, u.Email
				FROM tblUsers u
				WHERE u.Id = sv.UserId AND sv.IsInstallUser = 0
			) AS CurrentUser
	
	WHERE 
			s.Id = @Id AND 
			s.TaskId = @TaskId 

	ORDER BY sv.DateCreated DESC

END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 07 Oct 16
-- Description:	Get all Task specifications related to a task, 
--				with optional status filter.
-- =============================================
-- EXEC GetTaskWorkSpecifications 115, 0, 1
ALTER PROCEDURE [dbo].[GetTaskWorkSpecifications]
	@TaskId int,
	@Status bit,
	@Admin bit,
	@PageIndex INT = NULL, 
	@PageSize INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @StartIndex INT  = 0

	IF @PageIndex IS NULL
	BEGIN
		SET @PageIndex = 0
	END

	IF @PageSize IS NULL
	BEGIN
		SET @PageSize = 0
	END

	SET @StartIndex = (@PageIndex * @PageSize) + 1

	;WITH TaskWorkSpecifications
	AS
	(
		-- working copies (last working copies for each specification).
		SELECT
				s.Id AS Id,
				ISNULL(sv.Id,svDefault.Id) AS VersionId,
				ISNULL(sv.[Status],svDefault.[Status]) AS [Status],
				ISNULL(sv.Content,svDefault.Content) AS Content,
				ISNULL(sv.IsInstallUser,svDefault.IsInstallUser) AS IsInstallUser,
				ISNULL(sv.DateCreated,svDefault.DateCreated) AS DateCreated,
				CurrentUser.Id AS CurrentUserId,
				CurrentUser.Username AS CurrentUsername,
				CurrentUser.FirstName AS CurrentFirstName,
				CurrentUser.LastName AS CurrentLastName,
				CurrentUser.Email AS CurrentEmail,
				ROW_NUMBER() OVER(ORDER BY s.ID ASC) AS RowNumber

		FROM tblTaskWorkSpecification s
				OUTER APPLY
				(
					SELECT TOP 1 *, ROW_NUMBER() OVER(ORDER BY ID DESC) AS RowNo
					FROM tblTaskWorkSpecificationVersions
					WHERE TaskWorkSpecificationId = s.Id AND [Status] = ISNULL(@Status,[Status])
				) AS sv 
				OUTER APPLY
				(
					SELECT TOP 1 *, ROW_NUMBER() OVER(ORDER BY ID DESC) AS RowNo
					FROM tblTaskWorkSpecificationVersions
					WHERE TaskWorkSpecificationId = s.Id
				) AS svDefault
				OUTER APPLY
				(
					SELECT TOP 1 iu.Id,iu.FristName AS Username, iu.FristName AS FirstName, iu.LastName, iu.Email
					FROM tblInstallUsers iu
					WHERE iu.Id = ISNULL(sv.UserId,svDefault.UserId) AND ISNULL(sv.IsInstallUser,svDefault.IsInstallUser) = 1
			
					UNION

					SELECT TOP 1 u.Id,u.Username AS Username, u.FirstName AS FirstName, u.LastName, u.Email
					FROM tblUsers u
					WHERE u.Id = ISNULL(sv.UserId,svDefault.UserId) AND ISNULL(sv.IsInstallUser,svDefault.IsInstallUser) = 0
				) AS CurrentUser
		WHERE s.TaskId = @TaskId AND 
				(@Admin = 1 OR (@Admin = 0 AND sv.Id IS NOT NULL))
	)

			
	-- get records
	SELECT *
	FROM TaskWorkSpecifications
	WHERE 
		RowNumber >= @StartIndex AND 
		(
			@PageSize = 0 OR 
			RowNumber < (@StartIndex + @PageSize)
		)

	-- get record count
	SELECT COUNT(*) AS TotalRecordCount
	FROM tblTaskWorkSpecification s
				OUTER APPLY
				(
					SELECT TOP 1 *, ROW_NUMBER() OVER(ORDER BY ID DESC) AS RowNo
					FROM tblTaskWorkSpecificationVersions
					WHERE TaskWorkSpecificationId = s.Id
				) AS sv 
	WHERE s.TaskId = @TaskId AND sv.[Status] = ISNULL(@Status,sv.[Status])

END
GO


/*------------------------------------------------------------------------------------------------------*/
-- 10 OCT
/*------------------------------------------------------------------------------------------------------*/

ALTER TABLE tblTaskWorkSpecificationVersions
ADD FreezedByCount INT NULL
GO

UPDATE tblTaskWorkSpecificationVersions
SET
	FreezedByCount = 0
WHERE [Status] = 0

UPDATE tblTaskWorkSpecificationVersions
SET
	FreezedByCount = 1
WHERE [Status] = 1

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 13 Sep 16
-- Description:	Insert Task specification and also record history.
-- =============================================
ALTER PROCEDURE [dbo].[InsertTaskWorkSpecification]
	@TaskId int,
	@Content text,
	@UserId	int,
	@IsInstallUser bit,
	@Status Bit,
	@FreezedByCount INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    INSERT INTO tblTaskWorkSpecification
		(
			TaskId
		)
	VALUES
		(
			@TaskId
		)
	
	DECLARE @TaskWorkSpecificationId INT = SCOPE_IDENTITY()

	INSERT INTO tblTaskWorkSpecificationVersions
		(
			TaskWorkSpecificationId,
			Content,
			UserId,
			IsInstallUser,
			[Status],
			FreezedByCount,
			DateCreated
		)
	VALUES
		(
			@TaskWorkSpecificationId,
			@Content,
			@UserId,
			@IsInstallUser,
			@Status,
			@FreezedByCount,
			GETDATE()
		)
END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 13 Sep 16
-- Description:	Update Task specification and also record history.
-- =============================================
ALTER PROCEDURE [dbo].[UpdateTaskWorkSpecification]
	@TaskWorkSpecificationId int,
	@Content text,
	@UserId	int,
	@IsInstallUser bit,
	@Status Bit,
	@FreezedByCount INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO tblTaskWorkSpecificationVersions
		(
			TaskWorkSpecificationId,
			Content,
			UserId,
			IsInstallUser,
			[Status],
			FreezedByCount,
			DateCreated
		)
	VALUES
		(
			@TaskWorkSpecificationId,
			@Content,
			@UserId,
			@IsInstallUser,
			@Status,
			@FreezedByCount,
			GETDATE()
		)
END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 13 Sep 16
-- Description:	Get last checked-in Task specification from history.
-- =============================================
ALTER PROCEDURE [dbo].[GetLatestTaskWorkSpecification]
	@Id		INT,
	@TaskId INT,
	@Status BIT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- last copy with given status.
	SELECT TOP 1
			
			s.Id AS Id,
			sv.Id As VersionId,
			sv.[Status] AS [Status],
			sv.Content,
			sv.IsInstallUser,
			sv.DateCreated,
			LastUser.Id AS LastUserId,
			LastUser.Username AS LastUsername,
			LastUser.FirstName AS LastUserFirstName,
			LastUser.LastName AS LastUserLastName,
			LastUser.Email AS LastUserEmail

	FROM tblTaskWorkSpecification s
			INNER JOIN tblTaskWorkSpecificationVersions sv ON s.Id= sv.TaskWorkSpecificationId
			OUTER APPLY
			(
				SELECT TOP 1 iu.Id,iu.FristName AS Username, iu.FristName AS FirstName, iu.LastName, iu.Email
				FROM tblInstallUsers iu
				WHERE iu.Id = sv.UserId AND sv.IsInstallUser = 1
			
				UNION

				SELECT TOP 1 u.Id,u.Username AS Username, u.FirstName AS FirstName, u.LastName, u.Email
				FROM tblUsers u
				WHERE u.Id = sv.UserId AND sv.IsInstallUser = 0
			) AS LastUser

	WHERE 
			s.Id = @Id AND 
			s.TaskId = @TaskId AND 
			sv.[Status] = @Status

	ORDER BY sv.DateCreated DESC

	-- last 2 working copies with any status.
    SELECT TOP 2
			
			s.Id AS Id,
			sv.Id As VersionId,
			sv.[Status] AS [Status],
			sv.Content,
			sv.IsInstallUser,
			sv.DateCreated,
			CurrentUser.Id AS CurrentUserId,
			CurrentUser.Username AS CurrentUsername,
			CurrentUser.FirstName AS CurrentFirstName,
			CurrentUser.LastName AS CurrentLastName,
			CurrentUser.Email AS CurrentEmail

	FROM tblTaskWorkSpecification s
			INNER JOIN tblTaskWorkSpecificationVersions sv ON s.Id= sv.TaskWorkSpecificationId
			OUTER APPLY
			(
				SELECT TOP 1 iu.Id,iu.FristName AS Username, iu.FristName AS FirstName, iu.LastName, iu.Email
				FROM tblInstallUsers iu
				WHERE iu.Id = sv.UserId AND sv.IsInstallUser = 1
			
				UNION

				SELECT TOP 1 u.Id,u.Username AS Username, u.FirstName AS FirstName, u.LastName, u.Email
				FROM tblUsers u
				WHERE u.Id = sv.UserId AND sv.IsInstallUser = 0
			) AS CurrentUser
	
	WHERE 
			s.Id = @Id AND 
			s.TaskId = @TaskId 

	ORDER BY sv.DateCreated DESC

END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 07 Oct 16
-- Description:	Get all Task specifications related to a task, 
--				with optional status filter.
-- =============================================
-- EXEC GetTaskWorkSpecifications 151, NULL, 1
ALTER PROCEDURE [dbo].[GetTaskWorkSpecifications]
	@TaskId int,
	@Status bit = NULL,
	@Admin bit,
	@PageIndex INT = NULL, 
	@PageSize INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @StartIndex INT  = 0

	IF @PageIndex IS NULL
	BEGIN
		SET @PageIndex = 0
	END

	IF @PageSize IS NULL
	BEGIN
		SET @PageSize = 0
	END

	SET @StartIndex = (@PageIndex * @PageSize) + 1

	;WITH TaskWorkSpecifications
	AS
	(
		-- working copies (last working copies for each specification).
		SELECT
				sv.*,
				sv.Id as TaskWorkSpecificationVersionId,
				CurrentUser.Id AS CurrentUserId,
				CurrentUser.Username AS CurrentUsername,
				CurrentUser.FirstName AS CurrentFirstName,
				CurrentUser.LastName AS CurrentLastName,
				CurrentUser.Email AS CurrentEmail,
				ROW_NUMBER() OVER(ORDER BY s.ID ASC) AS RowNumber

		FROM tblTaskWorkSpecification s
				OUTER APPLY
				(
					SELECT TOP 1 *, ROW_NUMBER() OVER(ORDER BY ID DESC) AS RowNo
					FROM tblTaskWorkSpecificationVersions
					WHERE TaskWorkSpecificationId = s.Id AND [Status] = ISNULL(@Status,[Status])
				) AS sv 
				OUTER APPLY
				(
					SELECT TOP 1 iu.Id,iu.FristName AS Username, iu.FristName AS FirstName, iu.LastName, iu.Email
					FROM tblInstallUsers iu
					WHERE iu.Id = sv.UserId AND sv.IsInstallUser = 1
			
					UNION

					SELECT TOP 1 u.Id,u.Username AS Username, u.FirstName AS FirstName, u.LastName, u.Email
					FROM tblUsers u
					WHERE u.Id = sv.UserId AND sv.IsInstallUser = 0

				) AS CurrentUser
		WHERE 
			s.TaskId = @TaskId AND 
			sv.[Status] = ISNULL(@Status,[Status]) AND
			(
				@Admin = 1 OR 
				(
					@Admin = 0 AND 
					sv.FreezedByCount = 2
				)
			)
	)

			
	-- get records
	SELECT *
	FROM TaskWorkSpecifications
	WHERE 
		RowNumber >= @StartIndex AND 
		(
			@PageSize = 0 OR 
			RowNumber < (@StartIndex + @PageSize)
		)

	-- get record count
	SELECT COUNT(*) AS TotalRecordCount
	FROM tblTaskWorkSpecification s
				OUTER APPLY
				(
					SELECT TOP 1 *, ROW_NUMBER() OVER(ORDER BY ID DESC) AS RowNo
					FROM tblTaskWorkSpecificationVersions
					WHERE TaskWorkSpecificationId = s.Id AND [Status] = ISNULL(@Status,[Status])
				) AS sv 
	WHERE 
		s.TaskId = @TaskId AND 
		[Status] = ISNULL(@Status,[Status]) AND
		(
			@Admin = 1 OR 
			(
				@Admin = 0 AND 
				sv.FreezedByCount = 2
			)
		)

END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 07 Oct 16
-- Description:	Gets number of pending Task specifications related to a task.
-- =============================================
-- EXEC GetPendingTaskWorkSpecificationCount 0
CREATE PROCEDURE [dbo].[GetPendingTaskWorkSpecificationCount]
	@TaskId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT COUNT(DISTINCT s.id) AS TotalRecordCount
	FROM tblTaskWorkSpecification s
	WHERE 
		s.TaskId = @TaskId AND 
		s.Id NOT IN (
						SELECT TaskWorkSpecificationId
						FROM tblTaskWorkSpecificationVersions sv
						WHERE sv.TaskWorkSpecificationId = s.Id AND sv.FreezedByCount = 2
					)

END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh Keraliya
-- Create date: 8/25/16
-- Description:	This procedure is used to search tasks by different parameters.
-- =============================================
ALTER PROCEDURE [dbo].[uspSearchTasks]
	@Designations	VARCHAR(4000) = '0',
	@UserId			INT = NULL,
	@Status			TINYINT = NULL,
	@CreatedFrom	DATETIME = NULL,
	@CreatedTo		DATETIME = NULL,
	@SearchTerm		VARCHAR(250) = NULL,
	@SortExpression	VARCHAR(250) = 'CreatedOn DESC',
	@ExcludeStatus	TINYINT = NULL,
	@Admin			BIT,
	@PageIndex		INT = 0,
	@PageSize		INT = 10
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET @PageIndex = @PageIndex + 1

	;WITH Tasklist
	AS
	(	
		SELECT 
			--TaskUserMatch.IsMatch AS TaskUserMatch,
			--TaskUserRequestsMatch.IsMatch AS TaskUserRequestsMatch,
			--TaskDesignationMatch.IsMatch AS TaskDesignationMatch,
			Tasks.TaskId, 
			Tasks.Title, 
			Tasks.InstallId, 
			Tasks.[Status], 
			Tasks.[CreatedOn],
			Tasks.[DueDate], 
			Tasks.IsDeleted,
			Tasks.CreatedBy,
			Tasks.TaskPriority,
			STUFF
			(
				(SELECT  CAST(', ' + td.Designation as VARCHAR) AS Designation
				FROM tblTaskDesignations td
				WHERE td.TaskId = Tasks.TaskId
				FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)')
				,1
				,2
				,' '
			) AS TaskDesignations,
			STUFF
			(
				(SELECT  CAST(', ' + u.FristName as VARCHAR) AS Name
				FROM tblTaskAssignedUsers tu
					INNER JOIN tblInstallUsers u ON tu.UserId = u.Id
				WHERE tu.TaskId = Tasks.TaskId
				FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)')
				,1
				,2
				,' '
			) AS TaskAssignedUsers,
			STUFF
			(
				(SELECT  CAST(', ' + CAST(tu.UserId AS VARCHAR) + ':' + u.FristName as VARCHAR) AS Name
				FROM tblTaskAssignmentRequests tu
					INNER JOIN tblInstallUsers u ON tu.UserId = u.Id
				WHERE tu.TaskId = Tasks.TaskId
				FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)')
				,1
				,2
				,' '
			) AS TaskAssignmentRequestUsers
		FROM          
			tblTask AS Tasks 
			OUTER APPLY
			(
				SELECT TOP 1 
						1 AS IsMatch,
						TaskUsers.UserId AS UserId,
						UsersMaster.FristName AS FristName
				FROM tblTaskAssignedUsers TaskUsers
						LEFT JOIN tblInstallUsers AS UsersMaster ON TaskUsers.UserId = UsersMaster.Id
				WHERE 
					TaskUsers.TaskId = Tasks.TaskId AND
					TaskUsers.[UserId] = ISNULL(@UserId, TaskUsers.[UserId]) AND
					1 = CASE
							WHEN @UserId IS NOT NULL THEN 1 -- set true, when user id is provided. so that join will handle record filtering and search term will have no effect on user.
							WHEN @SearchTerm IS NULL THEN 1 -- set true, when search term is null. so that join will handle record filtering and search term will have no effect on user.
							WHEN UsersMaster.FristName LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if users with given search terms are available. 
							ELSE 0
						END
			) As TaskUserMatch
			OUTER APPLY
			(
				SELECT TOP 1 
						1 AS IsMatch,
						TaskUsers.UserId AS UserId,
						UsersMaster.FristName AS FristName
				FROM tblTaskAssignmentRequests TaskUsers
						LEFT JOIN tblInstallUsers AS UsersMaster ON TaskUsers.UserId = UsersMaster.Id
				WHERE 
					TaskUsers.TaskId = Tasks.TaskId AND
					TaskUsers.[UserId] = ISNULL(@UserId, TaskUsers.[UserId]) AND
					1 = CASE
							WHEN @UserId IS NOT NULL THEN 1 -- set true, when user id is provided. so that join will handle record filtering and search term will have no effect on user.
							WHEN @SearchTerm IS NULL THEN 1 -- set true, when search term is null. so that join will handle record filtering and search term will have no effect on user.
							WHEN UsersMaster.FristName LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if users with given search terms are available. 
							ELSE 0
						END
			) As TaskUserRequestsMatch
			OUTER APPLY
			(
				SELECT TOP 1 
						CASE
						WHEN @SearchTerm IS NULL THEN
							CASE
								WHEN @Designations = '0' THEN 1
								WHEN EXISTS (SELECT ss.Item  FROM dbo.SplitString(@Designations,',') ss WHERE ss.Item = TaskDesignations.Designation) THEN 1
								ELSE 0 
							END
						ELSE 
							CASE
								WHEN @Designations = '0' AND TaskDesignations.Designation LIKE '%' + @SearchTerm + '%' THEN 1
								WHEN (Tasks.[InstallId] LIKE '%' + @SearchTerm + '%'  OR Tasks.[Title] LIKE '%' + @SearchTerm + '%') THEN 1
								ELSE 0
							END
						END AS IsMatch,
						TaskDesignations.Designation AS Designation
				FROM tblTaskDesignations AS TaskDesignations
				WHERE 
					TaskDesignations.TaskId = Tasks.TaskId AND
					1 = CASE
							WHEN @Designations = '0' AND @SearchTerm IS NULL THEN 1 -- set true, when '0' (all designations) is provided with no search term.
							WHEN @Designations = '0' AND @SearchTerm IS NOT NULL AND TaskDesignations.Designation LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if designations found by search term.
							WHEN EXISTS (SELECT ss.Item  FROM dbo.SplitString(@Designations,',') ss WHERE ss.Item = TaskDesignations.Designation) THEN 1 -- filter based on provided designations.
							ELSE 0
						END
			)  AS TaskDesignationMatch
		WHERE
			Tasks.ParentTaskId IS NULL 
			AND
			1 = CASE
					WHEN @Admin = 1 THEN 1
					ELSE
						CASE
							WHEN Tasks.[Status] = @ExcludeStatus THEN 0
							ELSE 1
					END
				END
			AND 
			1 = CASE 
					-- filter records only by user, when search term is not provided.
					WHEN @SearchTerm IS NULL THEN
						CASE
							WHEN TaskUserMatch.IsMatch = 1 OR TaskDesignationMatch.IsMatch = 1 THEN 1
							WHEN TaskUserRequestsMatch.IsMatch = 1 OR TaskDesignationMatch.IsMatch = 1 THEN 1
							ELSE 0
						END
					-- filter records by installid, title, users when search term is provided.
					ELSE
						CASE
							WHEN Tasks.[InstallId] LIKE '%' + @SearchTerm + '%' THEN 1
							WHEN Tasks.[Title] LIKE '%' + @SearchTerm + '%' THEN 1
							WHEN TaskUserMatch.IsMatch = 1 THEN 1
							WHEN TaskUserRequestsMatch.IsMatch = 1 THEN 1
							ELSE 0
						END
				END
			--AND
			--1 = CASE 
			--	WHEN @SearchTerm IS NULL THEN 
			--		CASE
			--			WHEN TaskDesignationMatch.IsMatch = 1 THEN 1
			--			ELSE 0
			--		END
			--	ELSE
			--		CASE
			--			WHEN Tasks.[InstallId] LIKE '%' + @SearchTerm + '%' THEN 1
			--			WHEN Tasks.[Title] LIKE '%' + @SearchTerm + '%' THEN 1
			--			WHEN TaskDesignationMatch.IsMatch = 1 THEN 1
			--			ELSE 0
			--		END
			--END
			AND
			Tasks.[Status] = ISNULL(@Status,Tasks.[Status]) 
			AND
			CONVERT(VARCHAR,Tasks.[CreatedOn],101)  >= ISNULL(@CreatedFrom,CONVERT(VARCHAR,Tasks.[CreatedOn],101)) AND
			CONVERT(VARCHAR,Tasks.[CreatedOn],101)  <= ISNULL(@CreatedTo,CONVERT(VARCHAR,Tasks.[CreatedOn],101))
	),

FinalData AS( 
	SELECT * ,
			Row_number() OVER
			(
				ORDER BY
					CASE WHEN @SortExpression = 'UserID DESC' THEN Tasklist.TaskAssignedUsers END DESC,
					CASE WHEN @SortExpression = 'CreatedOn DESC' THEN Tasklist.CreatedOn END DESC,
					CASE WHEN @SortExpression = 'Status ASC' THEN Tasklist.[Status] END ASC
			) AS RowNo
	FROM Tasklist )
	
	SELECT * FROM FinalData 
	WHERE  
		RowNo BETWEEN (@PageIndex - 1) * @PageSize + 1 AND 
		@PageIndex * @PageSize

	SELECT 
		COUNT(DISTINCT Tasks.TaskId) AS VirtualCount
	FROM          
		tblTask AS Tasks 
		OUTER APPLY
		(
			SELECT TOP 1 
					1 AS IsMatch,
					TaskUsers.UserId AS UserId,
					UsersMaster.FristName AS FristName
			FROM tblTaskAssignedUsers TaskUsers
					LEFT JOIN tblInstallUsers AS UsersMaster ON TaskUsers.UserId = UsersMaster.Id
			WHERE 
				TaskUsers.TaskId = Tasks.TaskId AND
				TaskUsers.[UserId] = ISNULL(@UserId, TaskUsers.[UserId]) AND
				1 = CASE
						WHEN @UserId IS NOT NULL THEN 1 -- set true, when user id is provided. so that join will handle record filtering and search term will have no effect on user.
						WHEN @SearchTerm IS NULL THEN 1 -- set true, when search term is null. so that join will handle record filtering and search term will have no effect on user.
						WHEN UsersMaster.FristName LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if users with given search terms are available. 
						ELSE 0
					END
		) As TaskUserMatch
		OUTER APPLY
		(
			SELECT TOP 1 
					1 AS IsMatch,
					TaskUsers.UserId AS UserId,
					UsersMaster.FristName AS FristName
			FROM tblTaskAssignmentRequests TaskUsers
					LEFT JOIN tblInstallUsers AS UsersMaster ON TaskUsers.UserId = UsersMaster.Id
			WHERE 
				TaskUsers.TaskId = Tasks.TaskId AND
				TaskUsers.[UserId] = ISNULL(@UserId, TaskUsers.[UserId]) AND
				1 = CASE
						WHEN @UserId IS NOT NULL THEN 1 -- set true, when user id is provided. so that join will handle record filtering and search term will have no effect on user.
						WHEN @SearchTerm IS NULL THEN 1 -- set true, when search term is null. so that join will handle record filtering and search term will have no effect on user.
						WHEN UsersMaster.FristName LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if users with given search terms are available. 
						ELSE 0
					END
		) As TaskUserRequestsMatch
		OUTER APPLY
		(
			SELECT TOP 1 
					1 AS IsMatch,
					TaskDesignations.Designation AS Designation
			FROM tblTaskDesignations AS TaskDesignations
			WHERE 
				TaskDesignations.TaskId = Tasks.TaskId AND
				1 = CASE
						WHEN @Designations = '0' AND @SearchTerm IS NULL THEN 1 -- set true, when '0' (all designations) is provided with no search term.
						WHEN @Designations = '0' AND @SearchTerm IS NOT NULL AND TaskDesignations.Designation LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if designations found by search term.
						WHEN EXISTS (SELECT ss.Item  FROM dbo.SplitString(@Designations,',') ss WHERE ss.Item = TaskDesignations.Designation) THEN 1 -- filter based on provided designations.
						ELSE 0
					END
		)  AS TaskDesignationMatch
	WHERE
		Tasks.ParentTaskId IS NULL 
		AND 
		1 = CASE 
				-- filter records only by user, when search term is not provided.
				WHEN @SearchTerm IS NULL THEN
					CASE
						WHEN TaskUserMatch.IsMatch = 1 OR TaskDesignationMatch.IsMatch = 1 THEN 1
						WHEN TaskUserRequestsMatch.IsMatch = 1 OR TaskDesignationMatch.IsMatch = 1THEN 1
						ELSE 0
					END
				-- filter records by installid, title, users when search term is provided.
				ELSE
					CASE
						WHEN Tasks.[InstallId] LIKE '%' + @SearchTerm + '%' THEN 1
						WHEN Tasks.[Title] LIKE '%' + @SearchTerm + '%' THEN 1
						WHEN TaskUserMatch.IsMatch = 1 THEN 1
						WHEN TaskUserRequestsMatch.IsMatch = 1 THEN 1
						ELSE 0
					END
			END
		--AND
		--1 = CASE 
		--		WHEN @SearchTerm IS NULL THEN 
		--			CASE
		--				WHEN TaskDesignationMatch.IsMatch = 1 THEN 1
		--				ELSE 0
		--			END
		--		ELSE
		--			CASE
		--				WHEN Tasks.[InstallId] LIKE '%' + @SearchTerm + '%' THEN 1
		--				WHEN Tasks.[Title] LIKE '%' + @SearchTerm + '%' THEN 1
		--				WHEN TaskDesignationMatch.IsMatch = 1 THEN 1
		--				ELSE 0
		--			END
		--	END 
		AND
		Tasks.[Status] = ISNULL(@Status,Tasks.[Status]) 
		AND
		CONVERT(VARCHAR,Tasks.[CreatedOn],101)  >= ISNULL(@CreatedFrom,CONVERT(VARCHAR,Tasks.[CreatedOn],101)) AND
		CONVERT(VARCHAR,Tasks.[CreatedOn],101)  <= ISNULL(@CreatedTo,CONVERT(VARCHAR,Tasks.[CreatedOn],101))

END
GO

--==========================================================================================================================================================================================

-- Uploaded on live 10 Oct 2016

--==========================================================================================================================================================================================

/*------------------------------------------------------------------------------------------------------*/
-- 11 OCT
/*------------------------------------------------------------------------------------------------------*/

DROP TABLE tblTaskWorkSpecificationVersions
GO

DROP TABLE tblTaskWorkSpecificationFreez
GO

DROP TABLE tblTaskWorkSpecification
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTaskWorkSpecifications](
	[Id] [bigint] IDENTITY(1,1) PRIMARY KEY,
	[CustomId] varchar(10) NOT NULL,
	[TaskId] [bigint] NOT NULL REFERENCES tblTask,
	[Description] [text] NULL,
	[Links] varchar(1000) NULL,
	[WireFrame] varchar(300) NULL,
	[UserId] [int] NOT NULL,
	[IsInstallUser] [bit] NOT NULL,
	[AdminStatus] [bit] NULL,
	[TechLeadStatus] [bit] NULL,
	[DateCreated] [datetime] NOT NULL,
	[DateUpdated] [datetime] NOT NULL)
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 13 Sep 16
-- Description:	Insert Task specification and also record history.
-- =============================================
ALTER PROCEDURE [dbo].[InsertTaskWorkSpecification]
	@CustomId varchar(10),
	@TaskId bigint,
	@Description text,
	@Links varchar(1000),
	@WireFrame varchar(300),
	@UserId int,
	@IsInstallUser bit,
	@AdminStatus bit,
	@TechLeadStatus bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [dbo].[tblTaskWorkSpecifications]
		([CustomId]
		,[TaskId]
		,[Description]
		,[Links]
		,[WireFrame]
		,[UserId]
		,[IsInstallUser]
		,[AdminStatus]
		,[TechLeadStatus]
		,[DateCreated]
		,[DateUpdated])
	VALUES
		(@CustomId
		,@TaskId
		,@Description
		,@Links
		,@WireFrame
		,@UserId
		,@IsInstallUser
		,@AdminStatus
		,@TechLeadStatus
		,GETDATE()
		,GETDATE())
END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 13 Sep 16
-- Description:	Update Task specification and also record history.
-- =============================================
ALTER PROCEDURE [dbo].[UpdateTaskWorkSpecification]
	@Id bigint,
	@CustomId varchar(10),
	@TaskId bigint,
	@Description text,
	@Links varchar(1000),
	@WireFrame varchar(300),
	@UserId int,
	@IsInstallUser bit,
	@AdminStatus bit,
	@TechLeadStatus bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[tblTaskWorkSpecifications]
	SET 
		[CustomId] = @CustomId
		,[TaskId] = @TaskId
		,[Description] = @Description
		,[Links] = @Links
		,[WireFrame] = @WireFrame
		,[UserId] = @UserId
		,[IsInstallUser] = @IsInstallUser
		,[AdminStatus] = @AdminStatus
		,[TechLeadStatus] = @TechLeadStatus
		,[DateUpdated] = GETDATE()
	WHERE Id = @Id

END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 07 Oct 16
-- Description:	Get all Task specifications related to a task, 
--				with optional status filter.
-- =============================================
-- EXEC GetTaskWorkSpecifications 151, NULL, 1
ALTER PROCEDURE [dbo].[GetTaskWorkSpecifications]
	@TaskId bigint,
	@Admin bit,
	@PageIndex INT = NULL, 
	@PageSize INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @StartIndex INT  = 0

	IF @PageIndex IS NULL
	BEGIN
		SET @PageIndex = 0
	END

	IF @PageSize IS NULL
	BEGIN
		SET @PageSize = 0
	END

	SET @StartIndex = (@PageIndex * @PageSize) + 1

	;WITH TaskWorkSpecifications
	AS
	(
		SELECT
				s.*,
				CurrentUser.Id AS CurrentUserId,
				CurrentUser.Username AS CurrentUsername,
				CurrentUser.FirstName AS CurrentFirstName,
				CurrentUser.LastName AS CurrentLastName,
				CurrentUser.Email AS CurrentEmail,
				ROW_NUMBER() OVER(ORDER BY s.ID ASC) AS RowNumber

		FROM tblTaskWorkSpecifications s
				OUTER APPLY
				(
					SELECT TOP 1 iu.Id,iu.FristName AS Username, iu.FristName AS FirstName, iu.LastName, iu.Email
					FROM tblInstallUsers iu
					WHERE iu.Id = s.UserId AND s.IsInstallUser = 1
			
					UNION

					SELECT TOP 1 u.Id,u.Username AS Username, u.FirstName AS FirstName, u.LastName, u.Email
					FROM tblUsers u
					WHERE u.Id = s.UserId AND s.IsInstallUser = 0

				) AS CurrentUser
		WHERE
			s.TaskId = @TaskId AND 
			1 = CASE
					-- load records with all status for admin users.
					WHEN @Admin = 1 THEN
						1
					-- load only approved records for non-admin users.
					ELSE
						CASE
							WHEN s.[AdminStatus] = 1 AND s.[TechLeadStatus] = 1 THEN 1
							ELSE 0
						END
				END
	)

			
	-- get records
	SELECT *
	FROM TaskWorkSpecifications
	WHERE 
		RowNumber >= @StartIndex AND 
		(
			@PageSize = 0 OR 
			RowNumber < (@StartIndex + @PageSize)
		)

	-- get record count
	SELECT COUNT(*) AS TotalRecordCount
	FROM tblTaskWorkSpecifications s
	WHERE
		s.TaskId = @TaskId AND 
		1 = CASE
				-- load records with all status for admin users.
				WHEN @Admin = 1 THEN
					1
				-- load only approved records for non-admin users.
				ELSE
					CASE
						WHEN s.[AdminStatus] = 1 AND s.[TechLeadStatus] = 1 THEN 1
						ELSE 0
					END
			END

END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 13 Sep 16
-- Description:	Get Task specification by Id.
-- =============================================
CREATE PROCEDURE [dbo].[GetTaskWorkSpecificationById]
	@Id		INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
			s.*,
			LastUser.Id AS LastUserId,
			LastUser.Username AS LastUsername,
			LastUser.FirstName AS LastUserFirstName,
			LastUser.LastName AS LastUserLastName,
			LastUser.Email AS LastUserEmail

	FROM tblTaskWorkSpecifications s
			OUTER APPLY
			(
				SELECT TOP 1 iu.Id,iu.FristName AS Username, iu.FristName AS FirstName, iu.LastName, iu.Email
				FROM tblInstallUsers iu
				WHERE iu.Id = s.UserId AND s.IsInstallUser = 1
			
				UNION

				SELECT TOP 1 u.Id,u.Username AS Username, u.FirstName AS FirstName, u.LastName, u.Email
				FROM tblUsers u
				WHERE u.Id = s.UserId AND s.IsInstallUser = 0
			) AS LastUser

	WHERE s.Id = @Id 

END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 13 Sep 16
-- Description:	Updates status of Task specifications by task Id.
-- =============================================

CREATE PROCEDURE [dbo].[UpdateTaskWorkSpecificationStatusByTaskId]
	@TaskId		BIGINT,
	@AdminStatus BIT = NULL,
	@TechLeadStatus BIT = NULL,
	@UserId int,
	@IsInstallUser bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE tblTaskWorkSpecifications
	SET
		AdminStatus = ISNULL(@AdminStatus,AdminStatus),
		TechLeadStatus = ISNULL(@TechLeadStatus,TechLeadStatus),
		UserId= @UserId,
		IsInstallUser = @IsInstallUser,
		DateUpdated = GETDATE()
	WHERE TaskId = @TaskId

END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 07 Oct 16
-- Description:	Gets number of pending Task specifications related to a task.
-- =============================================
-- EXEC GetPendingTaskWorkSpecificationCount 0
ALTER PROCEDURE [dbo].[GetPendingTaskWorkSpecificationCount]
	@TaskId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT COUNT(DISTINCT s.id) AS TotalRecordCount
	FROM tblTaskWorkSpecifications s
	WHERE 
		s.TaskId = @TaskId AND 
		(
			ISNULL(s.AdminStatus ,0) = 0 OR
			ISNULL(s.TechLeadStatus ,0) = 0
		)

END
GO

--==========================================================================================================================================================================================

-- Uploaded on live 12 Oct 2016

--==========================================================================================================================================================================================

/*------------------------------------------------------------------------------------------------------*/
-- 14 OCT
/*------------------------------------------------------------------------------------------------------*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 07 Oct 16
-- Description:	Gets number of pending Task specifications related to a task.
-- =============================================
-- EXEC GetPendingTaskWorkSpecificationCount 152
ALTER PROCEDURE [dbo].[GetPendingTaskWorkSpecificationCount]
	@TaskId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT COUNT(DISTINCT s.id) AS TotalRecordCount
	FROM tblTaskWorkSpecifications s
	WHERE 
		s.TaskId = @TaskId AND 
		(
			ISNULL(s.AdminStatus ,0) = 0 OR
			ISNULL(s.TechLeadStatus ,0) = 0
		)

	SELECT TOP 1
			s.*,
			LastUser.Id AS LastUserId,
			LastUser.Username AS LastUsername,
			LastUser.FirstName AS LastUserFirstName,
			LastUser.LastName AS LastUserLastName,
			LastUser.Email AS LastUserEmail

	FROM tblTaskWorkSpecifications s
			OUTER APPLY
			(
				SELECT TOP 1 iu.Id,iu.FristName AS Username, iu.FristName AS FirstName, iu.LastName, iu.Email
				FROM tblInstallUsers iu
				WHERE iu.Id = s.UserId AND s.IsInstallUser = 1
			
				UNION

				SELECT TOP 1 u.Id,u.Username AS Username, u.FirstName AS FirstName, u.LastName, u.Email
				FROM tblUsers u
				WHERE u.Id = s.UserId AND s.IsInstallUser = 0
			) AS LastUser

	WHERE s.TaskId = @TaskId AND (s.AdminStatus = 1 OR s.TechLeadStatus = 1)

END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 13 Sep 16
-- Description:	Insert Task specification and also record history.
-- =============================================
ALTER PROCEDURE [dbo].[InsertTaskWorkSpecification]
	@CustomId varchar(10),
	@TaskId bigint,
	@Description text,
	@Links varchar(1000),
	@WireFrame varchar(300),
	@UserId int,
	@IsInstallUser bit,
	@AdminStatus bit,
	@TechLeadStatus bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [dbo].[tblTaskWorkSpecifications]
		([CustomId]
		,[TaskId]
		,[Description]
		,[Links]
		,[WireFrame]
		,[UserId]
		,[IsInstallUser]
		,[AdminStatus]
		,[TechLeadStatus]
		,[DateCreated]
		,[DateUpdated])
	VALUES
		(@CustomId
		,@TaskId
		,@Description
		,@Links
		,@WireFrame
		,@UserId
		,@IsInstallUser
		,@AdminStatus
		,@TechLeadStatus
		,GETDATE()
		,GETDATE())

		
	-- reset status for all, as any change requires 2 level freezing.
	UPDATE [dbo].[tblTaskWorkSpecifications]
	SET 
		[AdminStatus] = 0
		,[TechLeadStatus] = 0
		,[DateUpdated] = GETDATE()
	WHERE [TaskId] = @TaskId

END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 13 Sep 16
-- Description:	Update Task specification and also record history.
-- =============================================
ALTER PROCEDURE [dbo].[UpdateTaskWorkSpecification]
	@Id bigint,
	@CustomId varchar(10),
	@TaskId bigint,
	@Description text,
	@Links varchar(1000),
	@WireFrame varchar(300),
	@UserId int,
	@IsInstallUser bit,
	@AdminStatus bit,
	@TechLeadStatus bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[tblTaskWorkSpecifications]
	SET 
		[CustomId] = @CustomId
		,[TaskId] = @TaskId
		,[Description] = @Description
		,[Links] = @Links
		,[WireFrame] = @WireFrame
		,[UserId] = @UserId
		,[IsInstallUser] = @IsInstallUser
		,[AdminStatus] = @AdminStatus
		,[TechLeadStatus] = @TechLeadStatus
		,[DateUpdated] = GETDATE()
	WHERE Id = @Id

	-- reset status for all, as any change requires 2 level freezing.
	UPDATE [dbo].[tblTaskWorkSpecifications]
	SET 
		[AdminStatus] = 0
		,[TechLeadStatus] = 0
		,[DateUpdated] = GETDATE()
	WHERE [TaskId] = @TaskId

END
GO



/*------------------------------------------------------------------------------------------------------*/
-- 14 OCT Evening Updates
/*------------------------------------------------------------------------------------------------------*/



ALTER TABLE [tblTaskWorkSpecifications]
DROP COLUMN UserId, IsInstallUser
GO


ALTER TABLE [tblTaskWorkSpecifications]
ADD
	[TechLeadStatusUpdated] DATETIME NULL,
	[AdminStatusUpdated] DATETIME NULL,
	[TechLeadUserId] INT NULL,
	[AdminUserId] INT NULL,
	[IsTechLeadInstallUser] BIT NULL,
	[IsAdminInstallUser] BIT NULL
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 13 Sep 16
-- Description:	Insert Task specification and also record history.
-- =============================================
ALTER PROCEDURE [dbo].[InsertTaskWorkSpecification]
	@CustomId varchar(10),
	@TaskId bigint,
	@Description text,
	@Links varchar(1000),
	@WireFrame varchar(300)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [dbo].[tblTaskWorkSpecifications]
		([CustomId]
		,[TaskId]
		,[Description]
		,[Links]
		,[WireFrame]
		,[AdminStatus]
		,[TechLeadStatus]
		,[DateCreated]
		,[DateUpdated]
		,[AdminStatusUpdated]
		,[TechLeadStatusUpdated]
		,[AdminUserId]
		,[TechLeadUserId]
		,[IsAdminInstallUser]
		,[IsTechLeadInstallUser])
	VALUES
		(@CustomId
		,@TaskId
		,@Description
		,@Links
		,@WireFrame
		,0
		,0
		,GETDATE()
		,GETDATE()
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL)

		
	-- reset status for all, as any change requires 2 level freezing.
	UPDATE [dbo].[tblTaskWorkSpecifications]
	SET 
		[AdminStatus] = 0
		,[TechLeadStatus] = 0
		,[DateUpdated] = GETDATE()
		,[AdminStatusUpdated] = NULL
		,[TechLeadStatusUpdated] = NULL
		,[AdminUserId] = NULL
		,[TechLeadUserId] = NULL
		,[IsAdminInstallUser] = NULL
		,[IsTechLeadInstallUser] = NULL
	WHERE [TaskId] = @TaskId

END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 13 Sep 16
-- Description:	Update Task specification and also record history.
-- =============================================
ALTER PROCEDURE [dbo].[UpdateTaskWorkSpecification]
	@Id bigint,
	@CustomId varchar(10),
	@TaskId bigint,
	@Description text,
	@Links varchar(1000),
	@WireFrame varchar(300)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[tblTaskWorkSpecifications]
	SET 
		[CustomId] = @CustomId
		,[TaskId] = @TaskId
		,[Description] = @Description
		,[Links] = @Links
		,[WireFrame] = @WireFrame
		,[DateUpdated] = GETDATE()
	WHERE Id = @Id

	-- reset status for all, as any change requires 2 level freezing.
	UPDATE [dbo].[tblTaskWorkSpecifications]
	SET 
		[AdminStatus] = 0
		,[TechLeadStatus] = 0
		,[DateUpdated] = GETDATE()
		,[AdminStatusUpdated] = NULL
		,[TechLeadStatusUpdated] = NULL
		,[AdminUserId] = NULL
		,[TechLeadUserId] = NULL
		,[IsAdminInstallUser] = NULL
		,[IsTechLeadInstallUser] = NULL
	WHERE [TaskId] = @TaskId

END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 13 Sep 16
-- Description:	Updates status of Task specifications by task Id.
-- =============================================

ALTER PROCEDURE [dbo].[UpdateTaskWorkSpecificationStatusByTaskId]
	@TaskId		BIGINT,
	@AdminStatus BIT = NULL,
	@TechLeadStatus BIT = NULL,
	@UserId int,
	@IsInstallUser bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF @AdminStatus IS NOT NULL
	BEGIN
		UPDATE tblTaskWorkSpecifications
		SET
			AdminStatus = @AdminStatus,
			AdminUserId= @UserId,
			IsAdminInstallUser = @IsInstallUser,
			AdminStatusUpdated = GETDATE(),
			DateUpdated = GETDATE()
		WHERE TaskId = @TaskId
	END
	ELSE IF @TechLeadStatus IS NOT NULL
	BEGIN
		UPDATE tblTaskWorkSpecifications
		SET
			TechLeadStatus = @TechLeadStatus,
			TechLeadUserId= @UserId,
			IsTechLeadInstallUser = @IsInstallUser,
			TechLeadStatusUpdated = GETDATE(),
			DateUpdated = GETDATE()
		WHERE TaskId = @TaskId
	END

END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 13 Sep 16
-- Description:	Get Task specification by Id.
-- =============================================
-- EXEC [GetTaskWorkSpecificationById] 1
ALTER PROCEDURE [dbo].[GetTaskWorkSpecificationById]
	@Id		INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT
			s.*,
			
			AdminUser.Id AS AdminUserId,
			AdminUser.Username AS AdminUsername,
			AdminUser.FirstName AS AdminUserFirstName,
			AdminUser.LastName AS AdminUserLastName,
			AdminUser.Email AS AdminUserEmail,
			
			TechLeadUser.Id AS TechLeadUserId,
			TechLeadUser.Username AS TechLeadUsername,
			TechLeadUser.FirstName AS TechLeadUserFirstName,
			TechLeadUser.LastName AS TechLeadUserLastName,
			TechLeadUser.Email AS TechLeadUserEmail

	FROM tblTaskWorkSpecifications s
			OUTER APPLY
			(
				SELECT TOP 1 iu.Id,iu.FristName AS Username, iu.FristName AS FirstName, iu.LastName, iu.Email
				FROM tblInstallUsers iu
				WHERE iu.Id = s.AdminUserId AND s.IsAdminInstallUser = 1
			
				UNION

				SELECT TOP 1 u.Id,u.Username AS Username, u.FirstName AS FirstName, u.LastName, u.Email
				FROM tblUsers u
				WHERE u.Id = s.AdminUserId AND s.IsAdminInstallUser = 0
			) AS AdminUser
			OUTER APPLY
			(
				SELECT TOP 1 iu.Id,iu.FristName AS Username, iu.FristName AS FirstName, iu.LastName, iu.Email
				FROM tblInstallUsers iu
				WHERE iu.Id = s.TechLeadUserId AND s.IsTechLeadInstallUser = 1
			
				UNION

				SELECT TOP 1 u.Id,u.Username AS Username, u.FirstName AS FirstName, u.LastName, u.Email
				FROM tblUsers u
				WHERE u.Id = s.TechLeadUserId AND s.IsTechLeadInstallUser = 0
			) AS TechLeadUser

	WHERE s.Id = @Id
END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 07 Oct 16
-- Description:	Get all Task specifications related to a task, 
--				with optional status filter.
-- =============================================
-- EXEC GetTaskWorkSpecifications 151, NULL, 1
ALTER PROCEDURE [dbo].[GetTaskWorkSpecifications]
	@TaskId bigint,
	@Admin bit,
	@PageIndex INT = NULL, 
	@PageSize INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @StartIndex INT  = 0

	IF @PageIndex IS NULL
	BEGIN
		SET @PageIndex = 0
	END

	IF @PageSize IS NULL
	BEGIN
		SET @PageSize = 0
	END

	SET @StartIndex = (@PageIndex * @PageSize) + 1

	;WITH TaskWorkSpecifications
	AS
	(
		SELECT
				s.*,
				ROW_NUMBER() OVER(ORDER BY s.ID ASC) AS RowNumber

		FROM tblTaskWorkSpecifications s
		WHERE
			s.TaskId = @TaskId AND 
			1 = CASE
					-- load records with all status for admin users.
					WHEN @Admin = 1 THEN
						1
					-- load only approved records for non-admin users.
					ELSE
						CASE
							WHEN s.[AdminStatus] = 1 AND s.[TechLeadStatus] = 1 THEN 1
							ELSE 0
						END
				END
	)

			
	-- get records
	SELECT *
	FROM TaskWorkSpecifications
	WHERE 
		RowNumber >= @StartIndex AND 
		(
			@PageSize = 0 OR 
			RowNumber < (@StartIndex + @PageSize)
		)

	-- get record count
	SELECT COUNT(*) AS TotalRecordCount
	FROM tblTaskWorkSpecifications s
	WHERE
		s.TaskId = @TaskId AND 
		1 = CASE
				-- load records with all status for admin users.
				WHEN @Admin = 1 THEN
					1
				-- load only approved records for non-admin users.
				ELSE
					CASE
						WHEN s.[AdminStatus] = 1 AND s.[TechLeadStatus] = 1 THEN 1
						ELSE 0
					END
			END

END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 07 Oct 16
-- Description:	Gets number of pending Task specifications related to a task.
--				Get Task specification by Id, if admin or techlead status is freezed.
-- =============================================
-- EXEC GetPendingTaskWorkSpecificationCount 151
ALTER PROCEDURE [dbo].[GetPendingTaskWorkSpecificationCount]
	@TaskId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT COUNT(DISTINCT s.id) AS TotalRecordCount
	FROM tblTaskWorkSpecifications s
	WHERE 
		s.TaskId = @TaskId

	SELECT COUNT(DISTINCT s.id) AS PendingRecordCount
	FROM tblTaskWorkSpecifications s
	WHERE 
		s.TaskId = @TaskId AND 
		(
			ISNULL(s.AdminStatus ,0) = 0 OR
			ISNULL(s.TechLeadStatus ,0) = 0
		)

	SELECT TOP 1
			
			s.*,
			
			AdminUser.Id AS AdminUserId,
			AdminUser.Username AS AdminUsername,
			AdminUser.FirstName AS AdminUserFirstName,
			AdminUser.LastName AS AdminUserLastName,
			AdminUser.Email AS AdminUserEmail,
			
			TechLeadUser.Id AS TechLeadUserId,
			TechLeadUser.Username AS TechLeadUsername,
			TechLeadUser.FirstName AS TechLeadUserFirstName,
			TechLeadUser.LastName AS TechLeadUserLastName,
			TechLeadUser.Email AS TechLeadUserEmail

	FROM tblTaskWorkSpecifications s
			OUTER APPLY
			(
				SELECT TOP 1 iu.Id,iu.FristName AS Username, iu.FristName AS FirstName, iu.LastName, iu.Email
				FROM tblInstallUsers iu
				WHERE iu.Id = s.AdminUserId AND s.IsAdminInstallUser = 1
			
				UNION

				SELECT TOP 1 u.Id,u.Username AS Username, u.FirstName AS FirstName, u.LastName, u.Email
				FROM tblUsers u
				WHERE u.Id = s.AdminUserId AND s.IsAdminInstallUser = 0
			) AS AdminUser
			OUTER APPLY
			(
				SELECT TOP 1 iu.Id,iu.FristName AS Username, iu.FristName AS FirstName, iu.LastName, iu.Email
				FROM tblInstallUsers iu
				WHERE iu.Id = s.TechLeadUserId AND s.IsTechLeadInstallUser = 1
			
				UNION

				SELECT TOP 1 u.Id,u.Username AS Username, u.FirstName AS FirstName, u.LastName, u.Email
				FROM tblUsers u
				WHERE u.Id = s.TechLeadUserId AND s.IsTechLeadInstallUser = 0
			) AS TechLeadUser

	WHERE s.TaskId = @TaskId AND (s.AdminStatus = 1 OR s.TechLeadStatus = 1)

END
GO



/*------------------------------------------------------------------------------------------------------*/
-- 24 OCT Evening Updates
/*------------------------------------------------------------------------------------------------------*/


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh Keraliya
-- Create date: 8/25/16
-- Description:	This procedure is used to search tasks by different parameters.
-- =============================================
ALTER PROCEDURE [dbo].[uspSearchTasks]
	@Designations	VARCHAR(4000) = '0',
	@UserId			INT = NULL,
	@Status			TINYINT = NULL,
	@CreatedFrom	DATETIME = NULL,
	@CreatedTo		DATETIME = NULL,
	@SearchTerm		VARCHAR(250) = NULL,
	@SortExpression	VARCHAR(250) = 'CreatedOn DESC',
	@ExcludeStatus	TINYINT = NULL,
	@Admin			BIT,
	@PageIndex		INT = 0,
	@PageSize		INT = 10
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET @PageIndex = @PageIndex + 1

	;WITH Tasklist
	AS
	(	
		SELECT 
			--TaskUserMatch.IsMatch AS TaskUserMatch,
			--TaskUserRequestsMatch.IsMatch AS TaskUserRequestsMatch,
			--TaskDesignationMatch.IsMatch AS TaskDesignationMatch,
			Tasks.TaskId, 
			Tasks.Title, 
			Tasks.InstallId, 
			Tasks.[Status], 
			Tasks.[CreatedOn],
			Tasks.[DueDate], 
			Tasks.IsDeleted,
			Tasks.CreatedBy,
			Tasks.TaskPriority,
			STUFF
			(
				(SELECT  CAST(', ' + td.Designation as VARCHAR) AS Designation
				FROM tblTaskDesignations td
				WHERE td.TaskId = Tasks.TaskId
				FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)')
				,1
				,2
				,' '
			) AS TaskDesignations,
			STUFF
			(
				(SELECT  CAST(', ' + u.FristName as VARCHAR) AS Name
				FROM tblTaskAssignedUsers tu
					INNER JOIN tblInstallUsers u ON tu.UserId = u.Id
				WHERE tu.TaskId = Tasks.TaskId
				FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)')
				,1
				,2
				,' '
			) AS TaskAssignedUsers,
			STUFF
			(
				(SELECT  ',' + CAST(tu.UserId as VARCHAR) AS Id
				FROM tblTaskAssignedUsers tu
				WHERE tu.TaskId = Tasks.TaskId
				FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)')
				,1
				,1
				,''
			) AS TaskAssignedUserIds,
			STUFF
			(
				(SELECT  CAST(', ' + CAST(tu.UserId AS VARCHAR) + ':' + u.FristName as VARCHAR) AS Name
				FROM tblTaskAssignmentRequests tu
					INNER JOIN tblInstallUsers u ON tu.UserId = u.Id
				WHERE tu.TaskId = Tasks.TaskId
				FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)')
				,1
				,2
				,' '
			) AS TaskAssignmentRequestUsers
		FROM          
			tblTask AS Tasks 
			OUTER APPLY
			(
				SELECT TOP 1 
						1 AS IsMatch,
						TaskUsers.UserId AS UserId,
						UsersMaster.FristName AS FristName
				FROM tblTaskAssignedUsers TaskUsers
						LEFT JOIN tblInstallUsers AS UsersMaster ON TaskUsers.UserId = UsersMaster.Id
				WHERE 
					TaskUsers.TaskId = Tasks.TaskId AND
					TaskUsers.[UserId] = ISNULL(@UserId, TaskUsers.[UserId]) AND
					1 = CASE
							WHEN @UserId IS NOT NULL THEN 1 -- set true, when user id is provided. so that join will handle record filtering and search term will have no effect on user.
							WHEN @SearchTerm IS NULL THEN 1 -- set true, when search term is null. so that join will handle record filtering and search term will have no effect on user.
							WHEN UsersMaster.FristName LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if users with given search terms are available. 
							ELSE 0
						END
			) As TaskUserMatch
			OUTER APPLY
			(
				SELECT TOP 1 
						1 AS IsMatch,
						TaskUsers.UserId AS UserId,
						UsersMaster.FristName AS FristName
				FROM tblTaskAssignmentRequests TaskUsers
						LEFT JOIN tblInstallUsers AS UsersMaster ON TaskUsers.UserId = UsersMaster.Id
				WHERE 
					TaskUsers.TaskId = Tasks.TaskId AND
					TaskUsers.[UserId] = ISNULL(@UserId, TaskUsers.[UserId]) AND
					1 = CASE
							WHEN @UserId IS NOT NULL THEN 1 -- set true, when user id is provided. so that join will handle record filtering and search term will have no effect on user.
							WHEN @SearchTerm IS NULL THEN 1 -- set true, when search term is null. so that join will handle record filtering and search term will have no effect on user.
							WHEN UsersMaster.FristName LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if users with given search terms are available. 
							ELSE 0
						END
			) As TaskUserRequestsMatch
			OUTER APPLY
			(
				SELECT TOP 1 
						CASE
						WHEN @SearchTerm IS NULL THEN
							CASE
								WHEN @Designations = '0' THEN 1
								WHEN EXISTS (SELECT ss.Item  FROM dbo.SplitString(@Designations,',') ss WHERE ss.Item = TaskDesignations.Designation) THEN 1
								ELSE 0 
							END
						ELSE 
							CASE
								WHEN @Designations = '0' AND TaskDesignations.Designation LIKE '%' + @SearchTerm + '%' THEN 1
								WHEN (Tasks.[InstallId] LIKE '%' + @SearchTerm + '%'  OR Tasks.[Title] LIKE '%' + @SearchTerm + '%') THEN 1
								ELSE 0
							END
						END AS IsMatch,
						TaskDesignations.Designation AS Designation
				FROM tblTaskDesignations AS TaskDesignations
				WHERE 
					TaskDesignations.TaskId = Tasks.TaskId AND
					1 = CASE
							WHEN @Designations = '0' AND @SearchTerm IS NULL THEN 1 -- set true, when '0' (all designations) is provided with no search term.
							WHEN @Designations = '0' AND @SearchTerm IS NOT NULL AND TaskDesignations.Designation LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if designations found by search term.
							WHEN EXISTS (SELECT ss.Item  FROM dbo.SplitString(@Designations,',') ss WHERE ss.Item = TaskDesignations.Designation) THEN 1 -- filter based on provided designations.
							ELSE 0
						END
			)  AS TaskDesignationMatch
		WHERE
			Tasks.ParentTaskId IS NULL 
			AND
			1 = CASE
					WHEN @Admin = 1 THEN 1
					ELSE
						CASE
							WHEN Tasks.[Status] = @ExcludeStatus THEN 0
							ELSE 1
					END
				END
			AND 
			1 = CASE 
					-- filter records only by user, when search term is not provided.
					WHEN @SearchTerm IS NULL THEN
						CASE
							WHEN TaskUserMatch.IsMatch = 1 OR TaskDesignationMatch.IsMatch = 1 THEN 1
							WHEN TaskUserRequestsMatch.IsMatch = 1 OR TaskDesignationMatch.IsMatch = 1 THEN 1
							ELSE 0
						END
					-- filter records by installid, title, users when search term is provided.
					ELSE
						CASE
							WHEN Tasks.[InstallId] LIKE '%' + @SearchTerm + '%' THEN 1
							WHEN Tasks.[Title] LIKE '%' + @SearchTerm + '%' THEN 1
							WHEN TaskUserMatch.IsMatch = 1 THEN 1
							WHEN TaskUserRequestsMatch.IsMatch = 1 THEN 1
							ELSE 0
						END
				END
			--AND
			--1 = CASE 
			--	WHEN @SearchTerm IS NULL THEN 
			--		CASE
			--			WHEN TaskDesignationMatch.IsMatch = 1 THEN 1
			--			ELSE 0
			--		END
			--	ELSE
			--		CASE
			--			WHEN Tasks.[InstallId] LIKE '%' + @SearchTerm + '%' THEN 1
			--			WHEN Tasks.[Title] LIKE '%' + @SearchTerm + '%' THEN 1
			--			WHEN TaskDesignationMatch.IsMatch = 1 THEN 1
			--			ELSE 0
			--		END
			--END
			AND
			Tasks.[Status] = ISNULL(@Status,Tasks.[Status]) 
			AND
			CONVERT(VARCHAR,Tasks.[CreatedOn],101)  >= ISNULL(@CreatedFrom,CONVERT(VARCHAR,Tasks.[CreatedOn],101)) AND
			CONVERT(VARCHAR,Tasks.[CreatedOn],101)  <= ISNULL(@CreatedTo,CONVERT(VARCHAR,Tasks.[CreatedOn],101))
	),

FinalData AS( 
	SELECT * ,
			Row_number() OVER
			(
				ORDER BY
					CASE WHEN @SortExpression = 'UserID DESC' THEN Tasklist.TaskAssignedUsers END DESC,
					CASE WHEN @SortExpression = 'CreatedOn DESC' THEN Tasklist.CreatedOn END DESC,
					CASE WHEN @SortExpression = 'Status ASC' THEN Tasklist.[Status] END ASC
			) AS RowNo
	FROM Tasklist )
	
	SELECT * FROM FinalData 
	WHERE  
		RowNo BETWEEN (@PageIndex - 1) * @PageSize + 1 AND 
		@PageIndex * @PageSize

	SELECT 
		COUNT(DISTINCT Tasks.TaskId) AS VirtualCount
	FROM          
		tblTask AS Tasks 
		OUTER APPLY
		(
			SELECT TOP 1 
					1 AS IsMatch,
					TaskUsers.UserId AS UserId,
					UsersMaster.FristName AS FristName
			FROM tblTaskAssignedUsers TaskUsers
					LEFT JOIN tblInstallUsers AS UsersMaster ON TaskUsers.UserId = UsersMaster.Id
			WHERE 
				TaskUsers.TaskId = Tasks.TaskId AND
				TaskUsers.[UserId] = ISNULL(@UserId, TaskUsers.[UserId]) AND
				1 = CASE
						WHEN @UserId IS NOT NULL THEN 1 -- set true, when user id is provided. so that join will handle record filtering and search term will have no effect on user.
						WHEN @SearchTerm IS NULL THEN 1 -- set true, when search term is null. so that join will handle record filtering and search term will have no effect on user.
						WHEN UsersMaster.FristName LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if users with given search terms are available. 
						ELSE 0
					END
		) As TaskUserMatch
		OUTER APPLY
		(
			SELECT TOP 1 
					1 AS IsMatch,
					TaskUsers.UserId AS UserId,
					UsersMaster.FristName AS FristName
			FROM tblTaskAssignmentRequests TaskUsers
					LEFT JOIN tblInstallUsers AS UsersMaster ON TaskUsers.UserId = UsersMaster.Id
			WHERE 
				TaskUsers.TaskId = Tasks.TaskId AND
				TaskUsers.[UserId] = ISNULL(@UserId, TaskUsers.[UserId]) AND
				1 = CASE
						WHEN @UserId IS NOT NULL THEN 1 -- set true, when user id is provided. so that join will handle record filtering and search term will have no effect on user.
						WHEN @SearchTerm IS NULL THEN 1 -- set true, when search term is null. so that join will handle record filtering and search term will have no effect on user.
						WHEN UsersMaster.FristName LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if users with given search terms are available. 
						ELSE 0
					END
		) As TaskUserRequestsMatch
		OUTER APPLY
		(
			SELECT TOP 1 
					1 AS IsMatch,
					TaskDesignations.Designation AS Designation
			FROM tblTaskDesignations AS TaskDesignations
			WHERE 
				TaskDesignations.TaskId = Tasks.TaskId AND
				1 = CASE
						WHEN @Designations = '0' AND @SearchTerm IS NULL THEN 1 -- set true, when '0' (all designations) is provided with no search term.
						WHEN @Designations = '0' AND @SearchTerm IS NOT NULL AND TaskDesignations.Designation LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if designations found by search term.
						WHEN EXISTS (SELECT ss.Item  FROM dbo.SplitString(@Designations,',') ss WHERE ss.Item = TaskDesignations.Designation) THEN 1 -- filter based on provided designations.
						ELSE 0
					END
		)  AS TaskDesignationMatch
	WHERE
		Tasks.ParentTaskId IS NULL 
		AND 
		1 = CASE 
				-- filter records only by user, when search term is not provided.
				WHEN @SearchTerm IS NULL THEN
					CASE
						WHEN TaskUserMatch.IsMatch = 1 OR TaskDesignationMatch.IsMatch = 1 THEN 1
						WHEN TaskUserRequestsMatch.IsMatch = 1 OR TaskDesignationMatch.IsMatch = 1THEN 1
						ELSE 0
					END
				-- filter records by installid, title, users when search term is provided.
				ELSE
					CASE
						WHEN Tasks.[InstallId] LIKE '%' + @SearchTerm + '%' THEN 1
						WHEN Tasks.[Title] LIKE '%' + @SearchTerm + '%' THEN 1
						WHEN TaskUserMatch.IsMatch = 1 THEN 1
						WHEN TaskUserRequestsMatch.IsMatch = 1 THEN 1
						ELSE 0
					END
			END
		--AND
		--1 = CASE 
		--		WHEN @SearchTerm IS NULL THEN 
		--			CASE
		--				WHEN TaskDesignationMatch.IsMatch = 1 THEN 1
		--				ELSE 0
		--			END
		--		ELSE
		--			CASE
		--				WHEN Tasks.[InstallId] LIKE '%' + @SearchTerm + '%' THEN 1
		--				WHEN Tasks.[Title] LIKE '%' + @SearchTerm + '%' THEN 1
		--				WHEN TaskDesignationMatch.IsMatch = 1 THEN 1
		--				ELSE 0
		--			END
		--	END 
		AND
		Tasks.[Status] = ISNULL(@Status,Tasks.[Status]) 
		AND
		CONVERT(VARCHAR,Tasks.[CreatedOn],101)  >= ISNULL(@CreatedFrom,CONVERT(VARCHAR,Tasks.[CreatedOn],101)) AND
		CONVERT(VARCHAR,Tasks.[CreatedOn],101)  <= ISNULL(@CreatedTo,CONVERT(VARCHAR,Tasks.[CreatedOn],101))

END
GO

/*
   Tuesday, October 25, 20164:45:32 PM
   User: jgrovesa
   Server: jgdbserver001.cdgdaha6zllk.us-west-2.rds.amazonaws.com,1433
   Database: JGBS_Dev
   Application: 
*/

/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.tblTaskUserFiles ADD
	UpdatedOn datetime NULL
GO
ALTER TABLE dbo.tblTaskUserFiles ADD CONSTRAINT
	DF_tblTaskUserFiles_UpdatedOn DEFAULT getdate() FOR UpdatedOn
GO
ALTER TABLE dbo.tblTaskUserFiles SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

UPDATE tblTaskUserFiles SET UpdatedOn = GETDATE()

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/****** Object:  StoredProcedure [dbo].[usp_GetTaskUserFiles]    Script Date: 10/25/2016 4:55:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh Keraliya
-- Create date: 04/07/2016
-- Description:	Load all files of a task.
-- =============================================
-- usp_GetTaskUserFiles 115
ALTER PROCEDURE [dbo].[usp_GetTaskUserFiles] 
(
	@TaskId INT,
	@PageIndex INT = NULL, 
	@PageSize INT = NULL
)	
AS
BEGIN
	
	SET NOCOUNT ON;
	
	DECLARE @StartIndex INT  = 0

	IF @PageIndex IS NULL
	BEGIN
		SET @PageIndex = 0
	END

	IF @PageSize IS NULL
	BEGIN
		SET @PageSize = 0
	END

	SET @StartIndex = (@PageIndex * @PageSize) + 1

	;WITH TaskUserFiles
	AS
		(
		SELECT 
			tuf.Id,
			CAST(
					tuf.[Attachment] + '@' + tuf.[AttachmentOriginal] 
					AS VARCHAR(MAX)
				) AS attachment,
			ISNULL(u.FirstName,iu.FristName) AS FirstName,
			UpdatedOn,
			ROW_NUMBER() OVER(ORDER BY tuf.ID ASC) AS RowNumber
		FROM dbo.tblTaskUserFiles tuf
				LEFT JOIN tblUsers u ON tuf.UserId = u.Id --AND tuf.UserType = u.Usertype
				LEFT JOIN tblInstallUsers iu ON tuf.UserId = iu.Id --AND tuf.UserType = u.UserType
		WHERE tuf.TaskId = @TaskId
		
	)
    
	-- get records
	SELECT *
	FROM TaskUserFiles
	WHERE 
		RowNumber >= @StartIndex AND 
		(
			@PageSize = 0 OR 
			RowNumber < (@StartIndex + @PageSize)
		)
    Order BY UpdatedOn DESC
	-- get record count
	SELECT COUNT(*) AS TotalRecordCount
	FROM dbo.tblTaskUserFiles tuf
			LEFT JOIN tblUsers u ON tuf.UserId = u.Id --AND tuf.UserType = u.Usertype
			LEFT JOIN tblInstallUsers iu ON tuf.UserId = iu.Id --AND tuf.UserType = u.UserType
	WHERE tuf.TaskId = @TaskId

END

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh Keraliya
-- Create date: 10/25/2016
-- Description:	Delete file attachment
-- =============================================
CREATE PROCEDURE usp_DeleteTaskAttachmentFile 
(	
	@Id bigint
)
AS
BEGIN

DELETE FROM  tblTaskUserFiles WHERE Id = @Id

END
GO

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 26 Oct
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 07 Oct 16
-- Description:	Get all Task specifications related to a task, 
--				with optional status filter.
-- =============================================
-- EXEC GetTaskWorkSpecifications 151, NULL, 1
ALTER PROCEDURE [dbo].[GetTaskWorkSpecifications]
	@TaskId bigint,
	@Admin bit,
	@PageIndex INT = NULL, 
	@PageSize INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @StartIndex INT  = 0

	IF @PageIndex IS NULL
	BEGIN
		SET @PageIndex = 0
	END

	IF @PageSize IS NULL
	BEGIN
		SET @PageSize = 0
	END

	SET @StartIndex = (@PageIndex * @PageSize) + 1

	;WITH TaskWorkSpecifications
	AS
	(
		SELECT
				s.*,
				ROW_NUMBER() OVER(ORDER BY s.ID ASC) AS RowNumber

		FROM tblTaskWorkSpecifications s
		WHERE
			s.TaskId = @TaskId AND 
			1 = CASE
					-- load records with all status for admin users.
					WHEN @Admin = 1 THEN
						1
					-- load only approved records for non-admin users.
					ELSE
						CASE
							WHEN s.[AdminStatus] = 1 AND s.[TechLeadStatus] = 1 THEN 1
							ELSE 0
						END
				END
	)

			
	-- get records
	SELECT 
			TaskWorkSpecifications.*,
			-- get last custom id
			(
				SELECT TOP 1 CustomId
				FROM tblTaskWorkSpecifications s
				WHERE
					s.TaskId = @TaskId 
				ORDER By Id DESC
			) AS LastCustomId
	FROM TaskWorkSpecifications
	WHERE 
		RowNumber >= @StartIndex AND 
		(
			@PageSize = 0 OR 
			RowNumber < (@StartIndex + @PageSize)
		)

	-- get record count
	SELECT COUNT(*) AS TotalRecordCount
	FROM tblTaskWorkSpecifications s
	WHERE
		s.TaskId = @TaskId AND 
		1 = CASE
				-- load records with all status for admin users.
				WHEN @Admin = 1 THEN
					1
				-- load only approved records for non-admin users.
				ELSE
					CASE
						WHEN s.[AdminStatus] = 1 AND s.[TechLeadStatus] = 1 THEN 1
						ELSE 0
					END
			END

END
GO



-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 27 Oct
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------



ALTER TABLE tblTaskWorkSpecifications
ADD ParentTaskWorkSpecificationId BIGINT NULL REFERENCES tblTaskWorkSpecifications
GO

ALTER TABLE tblTaskUserFiles
ADD FileDestination TINYINT NULL
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh Keraliya
-- Create date: 04/07/2016
-- Description:	Load all files of a task.
-- =============================================
-- usp_GetTaskUserFiles 115
ALTER PROCEDURE [dbo].[usp_GetTaskUserFiles] 
(
	@TaskId INT,
	@FileDestination TINYINT = NULL,
	@PageIndex INT = NULL, 
	@PageSize INT = NULL
)	
AS
BEGIN
	
	SET NOCOUNT ON;
	
	DECLARE @StartIndex INT  = 0

	IF @PageIndex IS NULL
	BEGIN
		SET @PageIndex = 0
	END

	IF @PageSize IS NULL
	BEGIN
		SET @PageSize = 0
	END

	SET @StartIndex = (@PageIndex * @PageSize) + 1

	;WITH TaskUserFiles
	AS
		(
		SELECT 
			tuf.Id,
			CAST(
					tuf.[Attachment] + '@' + tuf.[AttachmentOriginal] 
					AS VARCHAR(MAX)
				) AS attachment,
			ISNULL(u.FirstName,iu.FristName) AS FirstName,
			UpdatedOn,
			ROW_NUMBER() OVER(ORDER BY tuf.ID ASC) AS RowNumber
		FROM dbo.tblTaskUserFiles tuf
				LEFT JOIN tblUsers u ON tuf.UserId = u.Id --AND tuf.UserType = u.Usertype
				LEFT JOIN tblInstallUsers iu ON tuf.UserId = iu.Id --AND tuf.UserType = u.UserType
		WHERE 
			tuf.TaskId = @TaskId AND 
			tuf.FileDestination = ISNULL(@FileDestination,FileDestination)
		
	)
    
	-- get records
	SELECT *
	FROM TaskUserFiles
	WHERE 
		RowNumber >= @StartIndex AND 
		(
			@PageSize = 0 OR 
			RowNumber < (@StartIndex + @PageSize)
		)
    Order BY UpdatedOn DESC
	
	-- get record count
	SELECT COUNT(*) AS TotalRecordCount
	FROM dbo.tblTaskUserFiles tuf
			LEFT JOIN tblUsers u ON tuf.UserId = u.Id --AND tuf.UserType = u.Usertype
			LEFT JOIN tblInstallUsers iu ON tuf.UserId = iu.Id --AND tuf.UserType = u.UserType
	WHERE 
		tuf.TaskId = @TaskId AND 
		tuf.FileDestination = ISNULL(@FileDestination,FileDestination)

END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SP_SaveOrDeleteTaskUserFiles]  
(   
	@Mode tinyint, -- 0:Insert, 1: Update 2: Delete  
	@TaskUpDateId bigint= NULL,  
	@TaskId bigint,  
	@FileDestination TINYINT = NULL,
	@UserId int,  
	@Attachment varchar(MAX),
	@OriginalFileName varchar(MAX),
	@UserType BIT  
) 
AS  
BEGIN  
  
	IF @Mode=0 
	BEGIN  
		INSERT INTO tblTaskUserFiles (TaskId,UserId,Attachment,TaskUpdateID,IsDeleted, AttachmentOriginal, UserType,FileDestination)   
		VALUES(@TaskId,@UserId,@Attachment,@TaskUpDateId,0, @OriginalFileName, @UserType,@FileDestination)  
	END  
	ELSE IF @Mode=1  
	BEGIN  
		UPDATE tblTaskUserFiles  
		SET 
			Attachment=@Attachment  
		WHERE TaskUpdateID = @TaskUpDateId
	END  
	ELSE IF @Mode=2 --DELETE  
	BEGIN  
		UPDATE tblTaskUserFiles  
		SET 
			IsDeleted =1  
		WHERE TaskUpdateID = @TaskUpDateId 
	END  
  
END  
GO
--=========================================================================================================================================================================

-- Live publish on 10/27/2016

--=========================================================================================================================================================================

/****** Object:  StoredProcedure [dbo].[InsertTaskWorkSpecification]    Script Date: 27-Oct-16 10:47:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 13 Sep 16
-- Description:	Insert Task specification and also record history.
-- =============================================
ALTER PROCEDURE [dbo].[InsertTaskWorkSpecification]
	@ParentTaskWorkSpecificationId bigint = null,
	@CustomId varchar(10),
	@TaskId bigint,
	@Description text,
	@Links varchar(1000),
	@WireFrame varchar(300)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [dbo].[tblTaskWorkSpecifications]
		([CustomId]
		,[TaskId]
		,[Description]
		,[Links]
		,[WireFrame]
		,[AdminStatus]
		,[TechLeadStatus]
		,[DateCreated]
		,[DateUpdated]
		,[AdminStatusUpdated]
		,[TechLeadStatusUpdated]
		,[AdminUserId]
		,[TechLeadUserId]
		,[IsAdminInstallUser]
		,[IsTechLeadInstallUser]
		,[ParentTaskWorkSpecificationId])
	VALUES
		(@CustomId
		,@TaskId
		,@Description
		,@Links
		,@WireFrame
		,0
		,0
		,GETDATE()
		,GETDATE()
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,@ParentTaskWorkSpecificationId)

		
	-- reset status for all, as any change requires 2 level freezing.
	UPDATE [dbo].[tblTaskWorkSpecifications]
	SET 
		[AdminStatus] = 0
		,[TechLeadStatus] = 0
		,[DateUpdated] = GETDATE()
		,[AdminStatusUpdated] = NULL
		,[TechLeadStatusUpdated] = NULL
		,[AdminUserId] = NULL
		,[TechLeadUserId] = NULL
		,[IsAdminInstallUser] = NULL
		,[IsTechLeadInstallUser] = NULL
	WHERE [TaskId] = @TaskId

END
GO


/****** Object:  StoredProcedure [dbo].[UpdateTaskWorkSpecification]    Script Date: 27-Oct-16 10:48:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 13 Sep 16
-- Description:	Update Task specification and also record history.
-- =============================================
ALTER PROCEDURE [dbo].[UpdateTaskWorkSpecification]
	@Id bigint,
	@ParentTaskWorkSpecificationId bigint = null,
	@CustomId varchar(10),
	@TaskId bigint,
	@Description text,
	@Links varchar(1000),
	@WireFrame varchar(300)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[tblTaskWorkSpecifications]
	SET 
		[CustomId] = @CustomId
		,[TaskId] = @TaskId
		,[Description] = @Description
		,[Links] = @Links
		,[WireFrame] = @WireFrame
		,[DateUpdated] = GETDATE()
		,[ParentTaskWorkSpecificationId] = @ParentTaskWorkSpecificationId
	WHERE Id = @Id

	-- reset status for all, as any change requires 2 level freezing.
	UPDATE [dbo].[tblTaskWorkSpecifications]
	SET 
		[AdminStatus] = 0
		,[TechLeadStatus] = 0
		,[DateUpdated] = GETDATE()
		,[AdminStatusUpdated] = NULL
		,[TechLeadStatusUpdated] = NULL
		,[AdminUserId] = NULL
		,[TechLeadUserId] = NULL
		,[IsAdminInstallUser] = NULL
		,[IsTechLeadInstallUser] = NULL
	WHERE [TaskId] = @TaskId

END
GO


/****** Object:  StoredProcedure [dbo].[GetTaskWorkSpecifications]    Script Date: 29-Oct-16 6:58:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 07 Oct 16
-- Description:	Get all Task specifications related to a task, 
--				with optional status filter.
-- =============================================
-- EXEC GetTaskWorkSpecifications 115, 1,NULL
ALTER PROCEDURE [dbo].[GetTaskWorkSpecifications]
	@TaskId bigint,
	@Admin bit,
	@ParentTaskWorkSpecificationId bigint = NULL,
	@PageIndex INT = NULL, 
	@PageSize INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @StartIndex INT  = 0

	IF @PageIndex IS NULL
	BEGIN
		SET @PageIndex = 0
	END

	IF @PageSize IS NULL
	BEGIN
		SET @PageSize = 0
	END

	SET @StartIndex = (@PageIndex * @PageSize) + 1

	;WITH TaskWorkSpecifications
	AS
	(
		SELECT
				s.*,
				ROW_NUMBER() OVER(ORDER BY s.ID ASC) AS RowNumber
		FROM tblTaskWorkSpecifications s
		WHERE
			s.TaskId = @TaskId AND 
			1 = CASE
					WHEN @ParentTaskWorkSpecificationId IS NULL THEN
						CASE
							WHEN s.ParentTaskWorkSpecificationId IS NULL THEN 1
							ELSE 0
						END
					ELSE
						CASE
							WHEN s.ParentTaskWorkSpecificationId = @ParentTaskWorkSpecificationId THEN 1
							ELSE 0
						END 
				END AND
			1 = CASE
					-- load records with all status for admin users.
					WHEN @Admin = 1 THEN
						1
					-- load only approved records for non-admin users.
					ELSE
						CASE
							WHEN s.[AdminStatus] = 1 AND s.[TechLeadStatus] = 1 THEN 1
							ELSE 0
						END
				END
	)
		
	-- get records
	SELECT 
			TaskWorkSpecifications.*,
			-- get sub task work specifications count
			(
				SELECT COUNT(Id) AS SubTaskWorkSpecificationCount
				FROM tblTaskWorkSpecifications s
				WHERE
					s.ParentTaskWorkSpecificationId = TaskWorkSpecifications.Id 
			) AS SubTaskWorkSpecificationCount
	FROM TaskWorkSpecifications
	WHERE 
		RowNumber >= @StartIndex AND 
		(
			@PageSize = 0 OR 
			RowNumber < (@StartIndex + @PageSize)
		)

	-- get record count
	SELECT COUNT(*) AS TotalRecordCount
	FROM tblTaskWorkSpecifications s
	WHERE
		s.TaskId = @TaskId AND 
		1 = CASE
				WHEN @ParentTaskWorkSpecificationId IS NULL THEN
					CASE
						WHEN s.ParentTaskWorkSpecificationId IS NULL THEN 1
						ELSE 0
					END
				ELSE
					CASE
						WHEN s.ParentTaskWorkSpecificationId = @ParentTaskWorkSpecificationId THEN 1
						ELSE 0
					END 
			END AND
		1 = CASE
				-- load records with all status for admin users.
				WHEN @Admin = 1 THEN
					1
				-- load only approved records for non-admin users.
				ELSE
					CASE
						WHEN s.[AdminStatus] = 1 AND s.[TechLeadStatus] = 1 THEN 1
						ELSE 0
					END
			END


	DECLARE @Temp BIGINT 

	SELECT TOP 1 @Temp = ParentTaskWorkSpecificationId
	FROM tblTaskWorkSpecifications s
	WHERE
		s.TaskId = @TaskId AND Id= @ParentTaskWorkSpecificationId

	-- get first custom id for parent list
	SELECT TOP 1 CustomId AS FirstParentCustomId
	FROM tblTaskWorkSpecifications s
	WHERE
		s.TaskId = @TaskId AND 
		(
			(@Temp IS NULL AND s.ParentTaskWorkSpecificationId IS NULL) OR
			s.ParentTaskWorkSpecificationId = @Temp
		)

	-- get last custom id for current list
	SELECT TOP 1 CustomId AS LastChildCustomId
	FROM tblTaskWorkSpecifications s
	WHERE
		s.TaskId = @TaskId AND
		1 = CASE
				WHEN @ParentTaskWorkSpecificationId IS NULL THEN
					CASE
						WHEN s.ParentTaskWorkSpecificationId IS NULL THEN 1
						ELSE 0
					END
				ELSE
					CASE
						WHEN s.ParentTaskWorkSpecificationId = @ParentTaskWorkSpecificationId THEN 1
						ELSE 0
					END 
			END 
	ORDER By Id DESC
END
GO


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 02 Nov
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh Keraliya
-- Create date: 09/02/2016
-- Description:	Delete task work specifications
-- =============================================
CREATE PROCEDURE [dbo].[DeleteTaskWorkSpecification] 
(	
	@Id bigint
)
AS
BEGIN
	
	-- this performs delete cascade based on ParentTaskWorkSpecificationId column.
	DELETE
	FROM tblTaskWorkSpecifications
	WHERE Id = @Id

END
GO

--==========================================================================================================================================================================================

-- Uploaded on live 03 Nov 2016

--==========================================================================================================================================================================================

ALTER TABLE [tblTaskWorkSpecifications]
DROP COLUMN WireFrame, Links
GO

ALTER TABLE [tblTaskWorkSpecifications]
ADD
	[OtherUserId] INT NULL,
	[IsOtherUserInstallUser] BIT NULL,
	[OtherUserStatus] BIT NULL,
	[OtherUserStatusUpdated] DATETIME NULL
GO

UPDATE [tblTaskWorkSpecifications]
SET [OtherUserStatus] = 0
GO

DROP PROCEDURE GetLatestTaskWorkSpecification
GO

/****** Object:  View [dbo].[TaskWorkSpecificationsView]    Script Date: 04-Nov-16 11:12:23 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TaskWorkSpecificationsView] as

	SELECT
			s.*,
			
			--AdminUser.Id AS AdminUserId,
			AdminUser.Username AS AdminUsername,
			AdminUser.FirstName AS AdminUserFirstName,
			AdminUser.LastName AS AdminUserLastName,
			AdminUser.Email AS AdminUserEmail,
			
			--TechLeadUser.Id AS TechLeadUserId,
			TechLeadUser.Username AS TechLeadUsername,
			TechLeadUser.FirstName AS TechLeadUserFirstName,
			TechLeadUser.LastName AS TechLeadUserLastName,
			TechLeadUser.Email AS TechLeadUserEmail,

			--OtherUser.Id AS OtherUserId,
			OtherUser.Username AS OtherUsername,
			OtherUser.FirstName AS OtherUserFirstName,
			OtherUser.LastName AS OtherUserLastName,
			OtherUser.Email AS OtherUserEmail

	FROM tblTaskWorkSpecifications s
			OUTER APPLY
			(
				SELECT TOP 1 iu.Id,iu.FristName AS Username, iu.FristName AS FirstName, iu.LastName, iu.Email
				FROM tblInstallUsers iu
				WHERE iu.Id = s.AdminUserId AND s.IsAdminInstallUser = 1
			
				UNION

				SELECT TOP 1 u.Id,u.Username AS Username, u.FirstName AS FirstName, u.LastName, u.Email
				FROM tblUsers u
				WHERE u.Id = s.AdminUserId AND s.IsAdminInstallUser = 0
			) AS AdminUser
			OUTER APPLY
			(
				SELECT TOP 1 iu.Id,iu.FristName AS Username, iu.FristName AS FirstName, iu.LastName, iu.Email
				FROM tblInstallUsers iu
				WHERE iu.Id = s.TechLeadUserId AND s.IsTechLeadInstallUser = 1
			
				UNION

				SELECT TOP 1 u.Id,u.Username AS Username, u.FirstName AS FirstName, u.LastName, u.Email
				FROM tblUsers u
				WHERE u.Id = s.TechLeadUserId AND s.IsTechLeadInstallUser = 0
			) AS TechLeadUser
			OUTER APPLY
			(
				SELECT TOP 1 iu.Id,iu.FristName AS Username, iu.FristName AS FirstName, iu.LastName, iu.Email
				FROM tblInstallUsers iu
				WHERE iu.Id = s.OtherUserId AND s.IsOtherUserInstallUser = 1
			
				UNION

				SELECT TOP 1 u.Id,u.Username AS Username, u.FirstName AS FirstName, u.LastName, u.Email
				FROM tblUsers u
				WHERE u.Id = s.OtherUserId AND s.IsOtherUserInstallUser = 0
			) AS OtherUser

GO



/****** Object:  StoredProcedure [dbo].[GetTaskWorkSpecificationById]    Script Date: 04-Nov-16 11:09:35 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 13 Sep 16
-- Description:	Get Task specification by Id.
-- =============================================
-- EXEC [GetTaskWorkSpecificationById] 1
ALTER PROCEDURE [dbo].[GetTaskWorkSpecificationById]
	@Id		INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT *
	FROM [TaskWorkSpecificationsView]
	WHERE Id = @Id

END
GO



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh Keraliya
-- Create date: 09/02/2016
-- Description:	Delete task work specifications
-- =============================================
ALTER PROCEDURE [dbo].[DeleteTaskWorkSpecification] 
(	
	@Id bigint
)
AS
BEGIN
	
	;WITH TWS AS
	(
		SELECT s.*
		FROM tblTaskWorkSpecifications s
		WHERE Id = @Id

		UNION ALL

		SELECT s.*
		FROM tblTaskWorkSpecifications s 
			INNER JOIN TWS t ON s.ParentTaskWorkSpecificationId = t.Id
	)

	-- this performs delete cascade based on ParentTaskWorkSpecificationId column.
	DELETE
	FROM tblTaskWorkSpecifications
	WHERE Id IN (SELECT ID FROM TWS)

END
GO

/****** Object:  StoredProcedure [dbo].[GetPendingTaskWorkSpecificationCount]    Script Date: 04-Nov-16 11:18:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 07 Oct 16
-- Description:	Gets number of pending Task specifications related to a task.
--				Get Task specification by Id, if admin or techlead status is freezed.
-- =============================================
-- EXEC GetPendingTaskWorkSpecificationCount 115
ALTER PROCEDURE [dbo].[GetPendingTaskWorkSpecificationCount]
	@TaskId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT COUNT(DISTINCT s.id) AS TotalRecordCount
	FROM tblTaskWorkSpecifications s
	WHERE 
		s.TaskId = @TaskId

	SELECT COUNT(DISTINCT s.id) AS PendingRecordCount
	FROM tblTaskWorkSpecifications s
	WHERE 
		s.TaskId = @TaskId AND 
		(
			ISNULL(s.AdminStatus ,0) = 0 OR
			ISNULL(s.TechLeadStatus ,0) = 0 OR
			ISNULL(s.OtherUserStatus ,0) = 0
		)

	SELECT TOP 1
			s.*
	FROM [TaskWorkSpecificationsView] s
	WHERE s.TaskId = @TaskId AND (s.AdminStatus = 1 OR s.TechLeadStatus = 1 OR s.OtherUserStatus = 1)

END
GO


/****** Object:  StoredProcedure [dbo].[GetTaskWorkSpecifications]    Script Date: 04-Nov-16 11:20:35 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 07 Oct 16
-- Description:	Get all Task specifications related to a task, 
--				with optional status filter.
-- =============================================
-- EXEC GetTaskWorkSpecifications 115, 1,NULL
ALTER PROCEDURE [dbo].[GetTaskWorkSpecifications]
	@TaskId bigint,
	@Admin bit,
	@ParentTaskWorkSpecificationId bigint = NULL,
	@PageIndex INT = NULL, 
	@PageSize INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @StartIndex INT  = 0

	IF @PageIndex IS NULL
	BEGIN
		SET @PageIndex = 0
	END

	IF @PageSize IS NULL
	BEGIN
		SET @PageSize = 0
	END

	SET @StartIndex = (@PageIndex * @PageSize) + 1

	;WITH TaskWorkSpecifications
	AS
	(
		SELECT
				s.*,
				ROW_NUMBER() OVER(ORDER BY s.ID ASC) AS RowNumber
		FROM [TaskWorkSpecificationsView] s
		WHERE
			s.TaskId = @TaskId AND 
			1 = CASE
					WHEN @ParentTaskWorkSpecificationId IS NULL THEN
						CASE
							WHEN s.ParentTaskWorkSpecificationId IS NULL THEN 1
							ELSE 0
						END
					ELSE
						CASE
							WHEN s.ParentTaskWorkSpecificationId = @ParentTaskWorkSpecificationId THEN 1
							ELSE 0
						END 
				END AND
			1 = CASE
					-- load records with all status for admin users.
					WHEN @Admin = 1 THEN
						1
					-- load only approved records for non-admin users.
					ELSE
						CASE
							WHEN s.[AdminStatus] = 1 AND s.[TechLeadStatus] = 1 THEN 1
							ELSE 0
						END
				END
	)
		
	-- get records
	SELECT 
			TaskWorkSpecifications.*,
			-- get sub task work specifications count
			(
				SELECT COUNT(Id) AS SubTaskWorkSpecificationCount
				FROM tblTaskWorkSpecifications s
				WHERE
					s.ParentTaskWorkSpecificationId = TaskWorkSpecifications.Id 
			) AS SubTaskWorkSpecificationCount
	FROM TaskWorkSpecifications
	WHERE 
		RowNumber >= @StartIndex AND 
		(
			@PageSize = 0 OR 
			RowNumber < (@StartIndex + @PageSize)
		)

	-- get record count
	SELECT COUNT(*) AS TotalRecordCount
	FROM tblTaskWorkSpecifications s
	WHERE
		s.TaskId = @TaskId AND 
		1 = CASE
				WHEN @ParentTaskWorkSpecificationId IS NULL THEN
					CASE
						WHEN s.ParentTaskWorkSpecificationId IS NULL THEN 1
						ELSE 0
					END
				ELSE
					CASE
						WHEN s.ParentTaskWorkSpecificationId = @ParentTaskWorkSpecificationId THEN 1
						ELSE 0
					END 
			END AND
		1 = CASE
				-- load records with all status for admin users.
				WHEN @Admin = 1 THEN
					1
				-- load only approved records for non-admin users.
				ELSE
					CASE
						WHEN s.[AdminStatus] = 1 AND s.[TechLeadStatus] = 1 THEN 1
						ELSE 0
					END
			END


	DECLARE @Temp BIGINT 

	SELECT TOP 1 @Temp = ParentTaskWorkSpecificationId
	FROM tblTaskWorkSpecifications s
	WHERE
		s.TaskId = @TaskId AND Id= @ParentTaskWorkSpecificationId

	-- get first custom id for parent list
	SELECT TOP 1 CustomId AS FirstParentCustomId
	FROM tblTaskWorkSpecifications s
	WHERE
		s.TaskId = @TaskId AND 
		(
			(@Temp IS NULL AND s.ParentTaskWorkSpecificationId IS NULL) OR
			s.ParentTaskWorkSpecificationId = @Temp
		)

	-- get last custom id for current list
	SELECT TOP 1 CustomId AS LastChildCustomId
	FROM tblTaskWorkSpecifications s
	WHERE
		s.TaskId = @TaskId AND
		1 = CASE
				WHEN @ParentTaskWorkSpecificationId IS NULL THEN
					CASE
						WHEN s.ParentTaskWorkSpecificationId IS NULL THEN 1
						ELSE 0
					END
				ELSE
					CASE
						WHEN s.ParentTaskWorkSpecificationId = @ParentTaskWorkSpecificationId THEN 1
						ELSE 0
					END 
			END 
	ORDER By Id DESC
END
GO

/****** Object:  StoredProcedure [dbo].[InsertTaskWorkSpecification]    Script Date: 04-Nov-16 11:24:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 13 Sep 16
-- Description:	Insert Task specification and also record history.
-- =============================================
ALTER PROCEDURE [dbo].[InsertTaskWorkSpecification]
	@ParentTaskWorkSpecificationId bigint = null,
	@CustomId varchar(10),
	@TaskId bigint,
	@Description text
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [dbo].[tblTaskWorkSpecifications]
		([CustomId]
		,[TaskId]
		,[Description]
		,[AdminStatus]
		,[TechLeadStatus]
		,[OtherUserStatus]
		,[DateCreated]
		,[DateUpdated]
		,[AdminStatusUpdated]
		,[TechLeadStatusUpdated]
		,[OtherUserStatusUpdated]
		,[AdminUserId]
		,[TechLeadUserId]
		,[OtherUserId]
		,[IsAdminInstallUser]
		,[IsTechLeadInstallUser]
		,[IsOtherUserInstallUser]
		,[ParentTaskWorkSpecificationId])
	VALUES
		(@CustomId
		,@TaskId
		,@Description
		,0
		,0
		,0
		,GETDATE()
		,GETDATE()
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,@ParentTaskWorkSpecificationId)

END
GO


/****** Object:  StoredProcedure [dbo].[UpdateTaskWorkSpecification]    Script Date: 04-Nov-16 11:38:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 13 Sep 16
-- Description:	Update Task specification and also record history.
-- =============================================
ALTER PROCEDURE [dbo].[UpdateTaskWorkSpecification]
	@Id bigint,
	@ParentTaskWorkSpecificationId bigint = null,
	@CustomId varchar(10),
	@TaskId bigint,
	@Description text
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[tblTaskWorkSpecifications]
	SET 
		[CustomId] = @CustomId
		,[TaskId] = @TaskId
		,[Description] = @Description
		,[ParentTaskWorkSpecificationId] = @ParentTaskWorkSpecificationId
		,[DateUpdated] = GETDATE()

		-- reset status for all, as any change requires 2 level freezing.
		,[AdminStatus] = 0
		,[TechLeadStatus] = 0
		,[OtherUserStatus] = 0
		,[AdminStatusUpdated] = NULL
		,[TechLeadStatusUpdated] = NULL
		,[OtherUserStatusUpdated] = NULL
		,[AdminUserId] = NULL
		,[TechLeadUserId] = NULL
		,[OtherUserId] = NULL
		,[IsAdminInstallUser] = NULL
		,[IsTechLeadInstallUser] = NULL
		,[IsOtherUserInstallUser] = NULL
	WHERE Id = @Id

END
GO

/****** Object:  StoredProcedure [dbo].[UpdateTaskWorkSpecificationStatusByTaskId]    Script Date: 04-Nov-16 11:43:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 13 Sep 16
-- Description:	Updates status of Task specifications by task Id.
-- =============================================

ALTER PROCEDURE [dbo].[UpdateTaskWorkSpecificationStatusByTaskId]
	@TaskId		BIGINT,
	@AdminStatus BIT = NULL,
	@TechLeadStatus BIT = NULL,
	@OtherUserStatus BIT = NULL,
	@UserId int,
	@IsInstallUser bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF @AdminStatus IS NOT NULL
	BEGIN
		UPDATE tblTaskWorkSpecifications
		SET
			AdminStatus = @AdminStatus,
			AdminUserId= @UserId,
			IsAdminInstallUser = @IsInstallUser,
			AdminStatusUpdated = GETDATE(),
			DateUpdated = GETDATE()
		WHERE TaskId = @TaskId
	END
	ELSE IF @TechLeadStatus IS NOT NULL
	BEGIN
		UPDATE tblTaskWorkSpecifications
		SET
			TechLeadStatus = @TechLeadStatus,
			TechLeadUserId= @UserId,
			IsTechLeadInstallUser = @IsInstallUser,
			TechLeadStatusUpdated = GETDATE(),
			DateUpdated = GETDATE()
		WHERE TaskId = @TaskId
	END
	ELSE IF @OtherUserStatus IS NOT NULL
	BEGIN
		UPDATE tblTaskWorkSpecifications
		SET
			OtherUserStatus = @OtherUserStatus,
			OtherUserId= @UserId,
			IsOtherUserInstallUser = @IsInstallUser,
			OtherUserStatusUpdated = GETDATE(),
			DateUpdated = GETDATE()
		WHERE TaskId = @TaskId
	END

END
GO

/****** Object:  StoredProcedure [dbo].[UpdateTaskWorkSpecificationStatusByTaskId]    Script Date: 04-Nov-16 11:43:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 13 Sep 16
-- Description:	Updates status of Task specifications including childs by Id.
-- =============================================

CREATE PROCEDURE [dbo].[UpdateTaskWorkSpecificationStatusById]
	@Id		BIGINT,
	@AdminStatus BIT = NULL,
	@TechLeadStatus BIT = NULL,
	@OtherUserStatus BIT = NULL,
	@UserId int,
	@IsInstallUser bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE	@tblTemp	TABLE(Id BIGINT)

	-- gets current as well as all child specifications.
	;WITH TWS AS
	(
		SELECT s.*
		FROM tblTaskWorkSpecifications s
		WHERE Id = @Id

		UNION ALL

		SELECT s.*
		FROM tblTaskWorkSpecifications s 
			INNER JOIN TWS t ON s.ParentTaskWorkSpecificationId = t.Id
	)

	INSERT INTO @tblTemp
	SELECT ID FROM TWS

	IF @AdminStatus IS NOT NULL
	BEGIN
		UPDATE tblTaskWorkSpecifications
		SET
			AdminStatus = @AdminStatus,
			AdminUserId= @UserId,
			IsAdminInstallUser = @IsInstallUser,
			AdminStatusUpdated = GETDATE(),
			DateUpdated = GETDATE()
		WHERE Id IN (SELECT ID FROM @tblTemp)
	END
	ELSE IF @TechLeadStatus IS NOT NULL
	BEGIN
		UPDATE tblTaskWorkSpecifications
		SET
			TechLeadStatus = @TechLeadStatus,
			TechLeadUserId= @UserId,
			IsTechLeadInstallUser = @IsInstallUser,
			TechLeadStatusUpdated = GETDATE(),
			DateUpdated = GETDATE()
		WHERE Id IN (SELECT ID FROM @tblTemp)
	END
	ELSE IF @OtherUserStatus IS NOT NULL
	BEGIN
		UPDATE tblTaskWorkSpecifications
		SET
			OtherUserStatus = @OtherUserStatus,
			OtherUserId= @UserId,
			IsOtherUserInstallUser = @IsInstallUser,
			OtherUserStatusUpdated = GETDATE(),
			DateUpdated = GETDATE()
		WHERE Id IN (SELECT ID FROM @tblTemp)
	END

END
GO

--==========================================================================================================================================================================================

-- Uploaded on live 08 Nov 2016

--==========================================================================================================================================================================================

/****** Object:  Table [dbo].[tblTaskUserFiles]    Script Date: 10-Nov-16 9:35:00 AM ******/
ALTER TABLE [dbo].[tblTaskUserFiles]
ADD
	[FileType] [varchar](5) NULL,
	[AttachedFileDate] [datetime] NULL DEFAULT (getdate())
GO


/****** Object:  StoredProcedure [dbo].[usp_GetTaskDetails]    Script Date: 10-Nov-16 9:23:32 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh Keraliya
-- Create date: 04/07/2016
-- Description:	Load all details of task for edit.
-- =============================================
-- usp_GetTaskDetails 115
ALTER PROCEDURE [dbo].[usp_GetTaskDetails] 
(
	@TaskId int 
)	  
AS
BEGIN
	
	SET NOCOUNT ON;

	-- task manager detail
	DECLARE @AssigningUser varchar(50) = NULL

	SELECT @AssigningUser = Users.[Username] 
	FROM 
		tblTask AS Task 
		INNER JOIN [dbo].[tblUsers] AS Users  ON Task.[CreatedBy] = Users.Id
	WHERE TaskId = @TaskId

	IF(@AssigningUser IS NULL)
	BEGIN
		SELECT @AssigningUser = Users.FristName + ' ' + Users.LastName 
		FROM 
			tblTask AS Task 
			INNER JOIN [dbo].[tblInstallUsers] AS Users  ON Task.[CreatedBy] = Users.Id
		WHERE TaskId = @TaskId
	END

	-- task's main details
	SELECT Title, [Description], [Status], DueDate,Tasks.[Hours], Tasks.CreatedOn, Tasks.TaskPriority,
		   Tasks.InstallId, Tasks.CreatedBy, @AssigningUser AS AssigningManager ,Tasks.TaskType, Tasks.IsTechTask,
		   STUFF
			(
				(SELECT  CAST(', ' + ttuf.[Attachment] + '@' + ttuf.[AttachmentOriginal] as VARCHAR(max)) AS attachment
				FROM dbo.tblTaskUserFiles ttuf
				WHERE ttuf.TaskId = Tasks.TaskId
				FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)')
				,1
				,2
				,' '
			) AS attachment
	FROM tblTask AS Tasks
	WHERE Tasks.TaskId = @TaskId

	-- task's designation details
	SELECT Designation
	FROM tblTaskDesignations
	WHERE (TaskId = @TaskId)

	-- task's assigned users
	SELECT UserId, TaskId
	FROM tblTaskAssignedUsers
	WHERE (TaskId = @TaskId)

	-- task's notes and attachment information.
	--SELECT	TaskUsers.Id,TaskUsers.UserId, TaskUsers.UserType, TaskUsers.Notes, TaskUsers.UserAcceptance, TaskUsers.UpdatedOn, 
	--	    TaskUsers.[Status], TaskUsers.TaskId, tblInstallUsers.FristName,TaskUsers.UserFirstName, tblInstallUsers.Designation,
	--		(SELECT COUNT(ttuf.[Id]) FROM dbo.tblTaskUserFiles ttuf WHERE ttuf.[TaskUpdateID] = TaskUsers.Id) AS AttachmentCount,
	--		dbo.UDF_GetTaskUpdateAttachments(TaskUsers.Id) AS attachments
	--FROM    
	--	tblTaskUser AS TaskUsers 
	--	LEFT OUTER JOIN tblInstallUsers ON TaskUsers.UserId = tblInstallUsers.Id
	--WHERE (TaskUsers.TaskId = @TaskId) 
	
	-- Description:	Get All Notes along with Attachments.
	-- Modify by :: Aavadesh Patel :: 10.08.2016 23:28
	SELECT	TaskUsers.Id,TaskUsers.UserId, 
		TaskUsers.UserType, TaskUsers.Notes, 
		TaskUsers.UserAcceptance, TaskUsers.UpdatedOn, 
		TaskUsers.[Status], TaskUsers.TaskId, 
		tblInstallUsers.FristName,TaskUsers.UserFirstName, 
		tblInstallUsers.Designation,(SELECT COUNT(ttuf.[Id]) FROM dbo.tblTaskUserFiles ttuf WHERE ttuf.[TaskUpdateID] = TaskUsers.Id) AS AttachmentCount,
		dbo.UDF_GetTaskUpdateAttachments(TaskUsers.Id) AS attachments,
		'' as AttachmentOriginal , 0 as TaskUserFilesID,
		'' as Attachment , '' as FileType
	FROM    
		tblTaskUser AS TaskUsers 
		LEFT OUTER JOIN tblInstallUsers ON TaskUsers.UserId = tblInstallUsers.Id
	WHERE (TaskUsers.TaskId = @TaskId) 
	
	
	Union All 
		
	SELECT	tblTaskUserFiles.Id , tblTaskUserFiles.UserId , 
		'' as UserType , '' as Notes , 
		'' as UserAcceptance , tblTaskUserFiles.AttachedFileDate,
		'' as [Status] , tblTaskUserFiles.TaskId , 
		tblInstallUsers.FristName  , tblInstallUsers.FristName as UserFirstName , 
		'' as Designation , '' as AttachmentCount , 
		'' as attachments,
		 tblTaskUserFiles.AttachmentOriginal,tblTaskUserFiles.Id as  TaskUserFilesID,
		 tblTaskUserFiles.Attachment, tblTaskUserFiles.FileType
	FROM   tblTaskUserFiles   
	LEFT OUTER JOIN tblInstallUsers ON tblInstallUsers.Id = tblTaskUserFiles.UserId
	WHERE (tblTaskUserFiles.TaskId = @TaskId)
	
	-- sub tasks
	SELECT Tasks.TaskId, Title, [Description], Tasks.[Status], DueDate,Tasks.[Hours], Tasks.CreatedOn, Tasks.TaskPriority,
		   Tasks.InstallId, Tasks.CreatedBy, @AssigningUser AS AssigningManager , UsersMaster.FristName,
		   Tasks.TaskType,Tasks.TaskPriority, Tasks.IsTechTask,
		   STUFF
			(
				(SELECT  CAST(', ' + ttuf.[Attachment] + '@' + ttuf.[AttachmentOriginal] as VARCHAR(max)) AS attachment
				FROM dbo.tblTaskUserFiles ttuf
				WHERE ttuf.TaskId = Tasks.TaskId
				FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)')
				,1
				,2
				,' '
			) AS attachment
	FROM 
		tblTask AS Tasks LEFT OUTER JOIN
        tblTaskAssignedUsers AS TaskUsers ON Tasks.TaskId = TaskUsers.TaskId LEFT OUTER JOIN
        tblInstallUsers AS UsersMaster ON TaskUsers.UserId = UsersMaster.Id --LEFT OUTER JOIN
		--tblTaskDesignations AS TaskDesignation ON Tasks.TaskId = TaskDesignation.TaskId
	WHERE Tasks.ParentTaskId = @TaskId
    
	-- main task attachments
	SELECT 
		CAST(
				--tuf.[Attachment] + '@' + tuf.[AttachmentOriginal] 
				ISNULL(tuf.[Attachment],'') + '@' + ISNULL(tuf.[AttachmentOriginal],'') 
				AS VARCHAR(MAX)
			) AS attachment,
		ISNULL(u.FirstName,iu.FristName) AS FirstName
	FROM dbo.tblTaskUserFiles tuf
			LEFT JOIN tblUsers u ON tuf.UserId = u.Id --AND tuf.UserType = u.Usertype
			LEFT JOIN tblInstallUsers iu ON tuf.UserId = iu.Id --AND tuf.UserType = u.UserType
	WHERE tuf.TaskId = @TaskId

END
GO

/****** Object:  StoredProcedure [dbo].[usp_UpadateTaskNotes]    Script Date: 10-Nov-16 9:37:58 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Aavadesh Patel
-- Create date: 10/19/2016
-- Description:	Update task note
-- =============================================
CREATE PROCEDURE [dbo].[usp_UpadateTaskNotes] 
(	
	@Id int , 	
	@Notes varchar(MAX)='' 
)
AS
BEGIN
	
	UPDATE tblTaskUser
	SET Notes = @Notes
	WHERE Id = @Id

END
GO

/****** Object:  StoredProcedure [dbo].[SP_SaveOrDeleteTaskUserFiles]    Script Date: 10-Nov-16 9:37:58 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_SaveOrDeleteTaskUserFiles]  
(   
	@Mode tinyint, -- 0:Insert, 1: Update 2: Delete  
	@TaskUpDateId bigint= NULL,  
	@TaskId bigint,  
	@FileDestination TINYINT = NULL,
	@UserId int,  
	@Attachment varchar(MAX),
	@OriginalFileName varchar(MAX),
	@UserType BIT,
    @FileType varchar(5)
) 
AS  
BEGIN  
  
	IF @Mode=0 
	BEGIN  
		INSERT INTO tblTaskUserFiles (TaskId,UserId,Attachment,TaskUpdateID,IsDeleted, AttachmentOriginal, UserType,FileDestination, FileType, AttachedFileDate)   
		VALUES(@TaskId,@UserId,@Attachment,@TaskUpDateId,0, @OriginalFileName, @UserType,@FileDestination, @FileType ,GETDATE())  
	END  
	ELSE IF @Mode=1  
	BEGIN  
		UPDATE tblTaskUserFiles  
		SET 
			Attachment=@Attachment  
		WHERE TaskUpdateID = @TaskUpDateId
	END  
	ELSE IF @Mode=2 --DELETE  
	BEGIN  
		UPDATE tblTaskUserFiles  
		SET 
			IsDeleted =1  
		WHERE TaskUpdateID = @TaskUpDateId 
	END  
  
END  
GO


--==========================================================================================================================================================================================

-- Uploaded on live 10 Nov 2016

--==========================================================================================================================================================================================


/****** Object:  StoredProcedure [dbo].[GetPendingTaskWorkSpecificationCount]    Script Date: 04-Nov-16 11:18:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 07 Oct 16
-- Description:	Gets number of pending Task specifications related to a task.
--				Get Task specification by Id, if admin or techlead status is freezed.
-- =============================================
-- EXEC GetPendingTaskWorkSpecificationCount 115
ALTER PROCEDURE [dbo].[GetPendingTaskWorkSpecificationCount]
	@TaskId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT COUNT(DISTINCT s.id) AS TotalRecordCount
	FROM tblTaskWorkSpecifications s
	WHERE 
		s.TaskId = @TaskId

	SELECT COUNT(DISTINCT s.id) AS PendingRecordCount
	FROM tblTaskWorkSpecifications s
	WHERE 
		s.TaskId = @TaskId AND 
		(
			ISNULL(s.AdminStatus ,0) = 0 OR
			ISNULL(s.TechLeadStatus ,0) = 0 
			-- OR
			-- ISNULL(s.OtherUserStatus ,0) = 0
		)

	SELECT TOP 1
			s.*
	FROM [TaskWorkSpecificationsView] s
	WHERE s.TaskId = @TaskId AND (s.AdminStatus = 1 OR s.TechLeadStatus = 1 OR s.OtherUserStatus = 1)

END
GO


ALTER TABLE [tblTask]
ADD
	[AdminStatus] BIT NULL,
	[TechLeadStatus] BIT NULL,
	[OtherUserStatus] BIT NULL,
	[AdminStatusUpdated] DATETIME NULL,
	[TechLeadStatusUpdated] DATETIME NULL,
	[OtherUserStatusUpdated] DATETIME NULL,
	[AdminUserId] INT NULL,
	[TechLeadUserId] INT NULL,
	[OtherUserId] INT NULL,
	[IsAdminInstallUser] BIT NULL,
	[IsTechLeadInstallUser] BIT NULL,
	[IsOtherUserInstallUser] BIT NULL
GO

UPDATE [dbo].[tblTask]
SET 
	[AdminStatus] = 0
	,[TechLeadStatus] = 0
	,[OtherUserStatus] = 0
GO

/****** Object:  StoredProcedure [dbo].[SP_SaveOrDeleteTask]    Script Date: 14-Nov-16 10:53:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 14 Nov 16
-- Description:	Inserts, Updates or Deletes a task.
-- =============================================
ALTER PROCEDURE [dbo].[SP_SaveOrDeleteTask]  
	 @Mode tinyint, -- 0:Insert, 1: Update, 2: Delete  
	 @TaskId bigint,  
	 @Title varchar(250),  
	 @Description varchar(MAX),  
	 @Status tinyint,  
	 @DueDate datetime = NULL,  
	 @Hours varchar(25),
	 @CreatedBy int,	
	 @InstallId varchar(50) = NULL,
	 @ParentTaskId bigint = NULL,
	 @TaskType tinyint = NULL,
	 @TaskPriority tinyint = null,
	 @IsTechTask bit = NULL,
	 @Result int output 
AS  
BEGIN  
  
	IF @Mode=0  
	  BEGIN  
		INSERT INTO tblTask 
				(
					Title,
					[Description],
					[Status],
					DueDate,
					[Hours],
					CreatedBy,
					CreatedOn,
					IsDeleted,
					InstallId,
					ParentTaskId,
					TaskType,
					TaskPriority,
					IsTechTask,
					AdminStatus,
					TechLeadStatus,
					OtherUserStatus
				)
		VALUES
				(
					@Title,
					@Description,
					@Status,
					@DueDate,
					@Hours,
					@CreatedBy,
					GETDATE(),
					0,
					@InstallId,
					@ParentTaskId,
					@TaskType,
					@TaskPriority,
					@IsTechTask,
					0,
					0,
					0
				)  
  
		SET @Result=SCOPE_IDENTITY ()  
  
		RETURN @Result  
	END  
	ELSE IF @Mode=1 -- Update  
	BEGIN    
		UPDATE tblTask  
		SET  
			Title=@Title,  
			[Description]=@Description,  
			[Status]=@Status,  
			DueDate=@DueDate,  
			[Hours]=@Hours,
			[TaskType] = @TaskType,
			[TaskPriority] = @TaskPriority,
			[IsTechTask] = @IsTechTask
		WHERE TaskId=@TaskId  

		SET @Result= @TaskId
  
		RETURN @Result  
	END  
	ELSE IF @Mode=2 --Delete  
	BEGIN  
		UPDATE tblTask  
		SET  
			IsDeleted=1  
		WHERE TaskId=@TaskId OR ParentTaskId=@TaskId  
	END  
  
END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 07 Oct 16
-- Description:	Gets number of pending sub Tasks related to a task.
-- =============================================
-- EXEC GetPendingSubTaskCount 115
CREATE PROCEDURE [dbo].[GetPendingSubTaskCount]
	@TaskId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT COUNT(DISTINCT t.TaskId) AS TotalRecordCount
	FROM tblTask t
	WHERE 
		t.ParentTaskId = @TaskId

	SELECT COUNT(DISTINCT t.TaskId) AS PendingRecordCount
	FROM tblTask t
	WHERE 
		t.ParentTaskId = @TaskId AND 
		(
			ISNULL(t.AdminStatus ,0) = 0 OR
			ISNULL(t.TechLeadStatus ,0) = 0 
			-- OR
			-- ISNULL(t.OtherUserStatus ,0) = 0
		)

END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 14 Nov 16
-- Description:	Updates status of sub Task by Id.
-- =============================================
CREATE PROCEDURE [dbo].[UpdateSubTaskStatusById]
	@TaskId		BIGINT,
	@AdminStatus BIT = NULL,
	@TechLeadStatus BIT = NULL,
	@OtherUserStatus BIT = NULL,
	@UserId int,
	@IsInstallUser bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF @AdminStatus IS NOT NULL
	BEGIN
		UPDATE tblTask
		SET
			AdminStatus = @AdminStatus,
			AdminUserId= @UserId,
			IsAdminInstallUser = @IsInstallUser,
			AdminStatusUpdated = GETDATE()
		WHERE TaskId = @TaskId
	END
	ELSE IF @TechLeadStatus IS NOT NULL
	BEGIN
		UPDATE tblTask
		SET
			TechLeadStatus = @TechLeadStatus,
			TechLeadUserId= @UserId,
			IsTechLeadInstallUser = @IsInstallUser,
			TechLeadStatusUpdated = GETDATE()
		WHERE TaskId = @TaskId
	END
	ELSE IF @OtherUserStatus IS NOT NULL
	BEGIN
		UPDATE tblTask
		SET
			OtherUserStatus = @OtherUserStatus,
			OtherUserId= @UserId,
			IsOtherUserInstallUser = @IsInstallUser,
			OtherUserStatusUpdated = GETDATE()
		WHERE TaskId = @TaskId
	END

END
GO

/****** Object:  StoredProcedure [dbo].[usp_GetSubTasks]    Script Date: 14-Nov-16 11:00:02 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Yogesh Keraliya
-- Create date: 04/07/2016
-- Description:	Load all sub tasks of a task.
-- =============================================
-- usp_GetSubTasks 10015
ALTER PROCEDURE [dbo].[usp_GetSubTasks] 
(
	@TaskId int,
	@Admin bit
)	  
AS
BEGIN
	
	SET NOCOUNT ON;

	-- task manager detail
	DECLARE @AssigningUser varchar(50) = NULL

	SELECT @AssigningUser = Users.[Username] 
	FROM 
		tblTask AS Task 
		INNER JOIN [dbo].[tblUsers] AS Users  ON Task.[CreatedBy] = Users.Id
	WHERE TaskId = @TaskId

	IF(@AssigningUser IS NULL)
	BEGIN
		SELECT @AssigningUser = Users.FristName + ' ' + Users.LastName 
		FROM 
			tblTask AS Task 
			INNER JOIN [dbo].[tblInstallUsers] AS Users  ON Task.[CreatedBy] = Users.Id
		WHERE TaskId = @TaskId
	END

	-- sub tasks
	SELECT 
			Tasks.*,
			--Tasks.TaskId, Title, [Description], Tasks.[Status], DueDate,Tasks.[Hours], Tasks.CreatedOn,
			--Tasks.InstallId, Tasks.CreatedBy, Tasks.TaskType,Tasks.TaskPriority,
			@AssigningUser AS AssigningManager,
			UsersMaster.FristName, 
			STUFF
			(
				(SELECT  CAST(', ' + ttuf.[Attachment] + '@' + ttuf.[AttachmentOriginal] as VARCHAR(max)) AS attachment
				FROM dbo.tblTaskUserFiles ttuf
				WHERE ttuf.TaskId = Tasks.TaskId
				FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)')
				,1
				,2
				,' '
			) AS attachment
	FROM 
		tblTask AS Tasks LEFT OUTER JOIN
        tblTaskAssignedUsers AS TaskUsers ON Tasks.TaskId = TaskUsers.TaskId LEFT OUTER JOIN
        tblInstallUsers AS UsersMaster ON TaskUsers.UserId = UsersMaster.Id --LEFT OUTER JOIN
		--tblTaskDesignations AS TaskDesignation ON Tasks.TaskId = TaskDesignation.TaskId
	WHERE 
			Tasks.ParentTaskId = @TaskId AND
			1 = CASE
					-- load records with all status for admin users.
					WHEN @Admin = 1 THEN
						1
					-- load only approved records for non-admin users.
					ELSE
						CASE
							WHEN Tasks.[AdminStatus] = 1 AND Tasks.[TechLeadStatus] = 1 THEN 1
							ELSE 0
						END
				END
    
END
GO


CREATE TABLE tblTaskAcceptance
(
Id BIGINT PRIMARY KEY IDENTITY(1,1),
TaskId BIGINT NOT NULL REFERENCES tblTask,
UserId	BIGINT NOT NULL,
IsInstallUser BIT NOT NULL,
IsAccepted BIT NOT NULL,
DateCreated DATETIME DEFAULT GETDATE()
)
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 15 Nov 16
-- Description:	Insert task acceptance history.
-- =============================================
CREATE PROCEDURE [dbo].[InsertTaskAcceptance]
	@TaskId		BIGINT,
	@UserId int,
	@IsInstallUser bit,
	@IsAccepted BIT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [dbo].[tblTaskAcceptance]
           ([TaskId]
           ,[UserId]
           ,[IsInstallUser]
           ,[IsAccepted]
           ,[DateCreated])
     VALUES
           (@TaskId
           ,@UserId
           ,@IsInstallUser
           ,@IsAccepted
           ,GETDATE())

END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 15 Nov 16
-- Description:	Get task acceptance history.
-- =============================================
CREATE PROCEDURE [dbo].[GetTaskAcceptances]
	@TaskId		BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
			s.*,

			TaskUser.Username AS Username,
			TaskUser.FirstName AS UserFirstName,
			TaskUser.LastName AS UserLastName,
			TaskUser.Email AS UserEmail
	FROM [dbo].[tblTaskAcceptance] s
			OUTER APPLY
			(
				SELECT TOP 1 iu.Id,iu.FristName AS Username, iu.FristName AS FirstName, iu.LastName, iu.Email
				FROM tblInstallUsers iu
				WHERE iu.Id = s.UserId AND s.IsInstallUser = 1
			
				UNION

				SELECT TOP 1 u.Id,u.Username AS Username, u.FirstName AS FirstName, u.LastName, u.Email
				FROM tblUsers u
				WHERE u.Id = s.UserId AND s.IsInstallUser = 0
			) AS TaskUser
	WHERE s.TaskId = @TaskId
	ORDER BY DateCreated ASC

END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh Keraliya
-- Create date: 11092016
-- Description:	
-- =============================================
CREATE PROCEDURE usp_SaveTaskDescription 
(	
	@TaskId int , 
	@Description varchar(4000) 
)
AS
BEGIN
	
UPDATE       tblTask
SET                Description = @Description
WHERE        (TaskId = @TaskId)
	
END
GO

--==========================================================================================================================================================================================

-- Uploaded on live 16 Nov 2016

--==========================================================================================================================================================================================


/****** Object:  StoredProcedure [dbo].[uspSearchTasks]    Script Date: 16-Nov-16 12:06:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh Keraliya
-- Create date: 8/25/16
-- Description:	This procedure is used to search tasks by different parameters.
-- =============================================
ALTER PROCEDURE [dbo].[uspSearchTasks]
	@Designations	VARCHAR(4000) = '0',
	@UserId			INT = NULL,
	@Status			TINYINT = NULL,
	@CreatedFrom	DATETIME = NULL,
	@CreatedTo		DATETIME = NULL,
	@SearchTerm		VARCHAR(250) = NULL,
	@SortExpression	VARCHAR(250) = 'CreatedOn DESC',
	@ExcludeStatus	TINYINT = NULL,
	@Admin			BIT,
	@PageIndex		INT = 0,
	@PageSize		INT = 10
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET @PageIndex = @PageIndex + 1

	;WITH Tasklist
	AS
	(	
		SELECT 
			--TaskUserMatch.IsMatch AS TaskUserMatch,
			--TaskUserRequestsMatch.IsMatch AS TaskUserRequestsMatch,
			--TaskDesignationMatch.IsMatch AS TaskDesignationMatch,
			Tasks.TaskId, 
			Tasks.Title, 
			Tasks.InstallId, 
			Tasks.[Status], 
			Tasks.[CreatedOn],
			Tasks.[DueDate], 
			Tasks.IsDeleted,
			Tasks.CreatedBy,
			Tasks.TaskPriority,
			STUFF
			(
				(SELECT  CAST(', ' + td.Designation as VARCHAR) AS Designation
				FROM tblTaskDesignations td
				WHERE td.TaskId = Tasks.TaskId
				FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)')
				,1
				,2
				,' '
			) AS TaskDesignations,
			STUFF
			(
				(SELECT  CAST(', ' + u.FristName as VARCHAR) AS Name
				FROM tblTaskAssignedUsers tu
					INNER JOIN tblInstallUsers u ON tu.UserId = u.Id
				WHERE tu.TaskId = Tasks.TaskId
				FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)')
				,1
				,2
				,' '
			) AS TaskAssignedUsers,
			STUFF
			(
				(SELECT  ',' + CAST(tu.UserId as VARCHAR) AS Id
				FROM tblTaskAssignedUsers tu
				WHERE tu.TaskId = Tasks.TaskId
				FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)')
				,1
				,1
				,''
			) AS TaskAssignedUserIds,
			STUFF
			(
				(SELECT  CAST(', ' + CAST(tu.UserId AS VARCHAR) + ':' + u.FristName as VARCHAR) AS Name
				FROM tblTaskAssignmentRequests tu
					INNER JOIN tblInstallUsers u ON tu.UserId = u.Id
				WHERE tu.TaskId = Tasks.TaskId
				FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)')
				,1
				,2
				,' '
			) AS TaskAssignmentRequestUsers,
			STUFF
			(
				(SELECT  ', ' + CAST(tu.UserId AS VARCHAR) AS UserId
				FROM tblTaskAcceptance tu
				WHERE tu.TaskId = Tasks.TaskId
				FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)')
				,1
				,2
				,' '
			) AS TaskAcceptanceUsers
		FROM          
			tblTask AS Tasks 
			OUTER APPLY
			(
				SELECT TOP 1 
						1 AS IsMatch,
						TaskUsers.UserId AS UserId,
						UsersMaster.FristName AS FristName
				FROM tblTaskAssignedUsers TaskUsers
						LEFT JOIN tblInstallUsers AS UsersMaster ON TaskUsers.UserId = UsersMaster.Id
				WHERE 
					TaskUsers.TaskId = Tasks.TaskId AND
					TaskUsers.[UserId] = ISNULL(@UserId, TaskUsers.[UserId]) AND
					1 = CASE
							WHEN @UserId IS NOT NULL THEN 1 -- set true, when user id is provided. so that join will handle record filtering and search term will have no effect on user.
							WHEN @SearchTerm IS NULL THEN 1 -- set true, when search term is null. so that join will handle record filtering and search term will have no effect on user.
							WHEN UsersMaster.FristName LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if users with given search terms are available. 
							ELSE 0
						END
			) As TaskUserMatch
			OUTER APPLY
			(
				SELECT TOP 1 
						1 AS IsMatch,
						TaskUsers.UserId AS UserId,
						UsersMaster.FristName AS FristName
				FROM tblTaskAssignmentRequests TaskUsers
						LEFT JOIN tblInstallUsers AS UsersMaster ON TaskUsers.UserId = UsersMaster.Id
				WHERE 
					TaskUsers.TaskId = Tasks.TaskId AND
					TaskUsers.[UserId] = ISNULL(@UserId, TaskUsers.[UserId]) AND
					1 = CASE
							WHEN @UserId IS NOT NULL THEN 1 -- set true, when user id is provided. so that join will handle record filtering and search term will have no effect on user.
							WHEN @SearchTerm IS NULL THEN 1 -- set true, when search term is null. so that join will handle record filtering and search term will have no effect on user.
							WHEN UsersMaster.FristName LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if users with given search terms are available. 
							ELSE 0
						END
			) As TaskUserRequestsMatch
			OUTER APPLY
			(
				SELECT TOP 1 
						CASE
						WHEN @SearchTerm IS NULL THEN
							CASE
								WHEN @Designations = '0' THEN 1
								WHEN EXISTS (SELECT ss.Item  FROM dbo.SplitString(@Designations,',') ss WHERE ss.Item = TaskDesignations.Designation) THEN 1
								ELSE 0 
							END
						ELSE 
							CASE
								WHEN @Designations = '0' AND TaskDesignations.Designation LIKE '%' + @SearchTerm + '%' THEN 1
								WHEN (Tasks.[InstallId] LIKE '%' + @SearchTerm + '%'  OR Tasks.[Title] LIKE '%' + @SearchTerm + '%') THEN 1
								ELSE 0
							END
						END AS IsMatch,
						TaskDesignations.Designation AS Designation
				FROM tblTaskDesignations AS TaskDesignations
				WHERE 
					TaskDesignations.TaskId = Tasks.TaskId AND
					1 = CASE
							WHEN @Designations = '0' AND @SearchTerm IS NULL THEN 1 -- set true, when '0' (all designations) is provided with no search term.
							WHEN @Designations = '0' AND @SearchTerm IS NOT NULL AND TaskDesignations.Designation LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if designations found by search term.
							WHEN EXISTS (SELECT ss.Item  FROM dbo.SplitString(@Designations,',') ss WHERE ss.Item = TaskDesignations.Designation) THEN 1 -- filter based on provided designations.
							ELSE 0
						END
			)  AS TaskDesignationMatch
		WHERE
			Tasks.ParentTaskId IS NULL 
			AND
			1 = CASE
					WHEN @Admin = 1 THEN 1
					ELSE
						CASE
							WHEN Tasks.[Status] = @ExcludeStatus THEN 0
							ELSE 1
					END
				END
			AND 
			1 = CASE 
					-- filter records only by user, when search term is not provided.
					WHEN @SearchTerm IS NULL THEN
						CASE
							WHEN TaskUserMatch.IsMatch = 1 OR TaskDesignationMatch.IsMatch = 1 THEN 1
							WHEN TaskUserRequestsMatch.IsMatch = 1 OR TaskDesignationMatch.IsMatch = 1 THEN 1
							ELSE 0
						END
					-- filter records by installid, title, users when search term is provided.
					ELSE
						CASE
							WHEN Tasks.[InstallId] LIKE '%' + @SearchTerm + '%' THEN 1
							WHEN Tasks.[Title] LIKE '%' + @SearchTerm + '%' THEN 1
							WHEN TaskUserMatch.IsMatch = 1 THEN 1
							WHEN TaskUserRequestsMatch.IsMatch = 1 THEN 1
							ELSE 0
						END
				END
			--AND
			--1 = CASE 
			--	WHEN @SearchTerm IS NULL THEN 
			--		CASE
			--			WHEN TaskDesignationMatch.IsMatch = 1 THEN 1
			--			ELSE 0
			--		END
			--	ELSE
			--		CASE
			--			WHEN Tasks.[InstallId] LIKE '%' + @SearchTerm + '%' THEN 1
			--			WHEN Tasks.[Title] LIKE '%' + @SearchTerm + '%' THEN 1
			--			WHEN TaskDesignationMatch.IsMatch = 1 THEN 1
			--			ELSE 0
			--		END
			--END
			AND
			Tasks.[Status] = ISNULL(@Status,Tasks.[Status]) 
			AND
			CONVERT(VARCHAR,Tasks.[CreatedOn],101)  >= ISNULL(@CreatedFrom,CONVERT(VARCHAR,Tasks.[CreatedOn],101)) AND
			CONVERT(VARCHAR,Tasks.[CreatedOn],101)  <= ISNULL(@CreatedTo,CONVERT(VARCHAR,Tasks.[CreatedOn],101))
	),

FinalData AS( 
	SELECT * ,
			Row_number() OVER
			(
				ORDER BY
					CASE WHEN @SortExpression = 'UserID DESC' THEN Tasklist.TaskAssignedUsers END DESC,
					CASE WHEN @SortExpression = 'CreatedOn DESC' THEN Tasklist.CreatedOn END DESC,
					CASE WHEN @SortExpression = 'Status ASC' THEN Tasklist.[Status] END ASC
			) AS RowNo
	FROM Tasklist )
	
	SELECT * FROM FinalData 
	WHERE  
		RowNo BETWEEN (@PageIndex - 1) * @PageSize + 1 AND 
		@PageIndex * @PageSize

	SELECT 
		COUNT(DISTINCT Tasks.TaskId) AS VirtualCount
	FROM          
		tblTask AS Tasks 
		OUTER APPLY
		(
			SELECT TOP 1 
					1 AS IsMatch,
					TaskUsers.UserId AS UserId,
					UsersMaster.FristName AS FristName
			FROM tblTaskAssignedUsers TaskUsers
					LEFT JOIN tblInstallUsers AS UsersMaster ON TaskUsers.UserId = UsersMaster.Id
			WHERE 
				TaskUsers.TaskId = Tasks.TaskId AND
				TaskUsers.[UserId] = ISNULL(@UserId, TaskUsers.[UserId]) AND
				1 = CASE
						WHEN @UserId IS NOT NULL THEN 1 -- set true, when user id is provided. so that join will handle record filtering and search term will have no effect on user.
						WHEN @SearchTerm IS NULL THEN 1 -- set true, when search term is null. so that join will handle record filtering and search term will have no effect on user.
						WHEN UsersMaster.FristName LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if users with given search terms are available. 
						ELSE 0
					END
		) As TaskUserMatch
		OUTER APPLY
		(
			SELECT TOP 1 
					1 AS IsMatch,
					TaskUsers.UserId AS UserId,
					UsersMaster.FristName AS FristName
			FROM tblTaskAssignmentRequests TaskUsers
					LEFT JOIN tblInstallUsers AS UsersMaster ON TaskUsers.UserId = UsersMaster.Id
			WHERE 
				TaskUsers.TaskId = Tasks.TaskId AND
				TaskUsers.[UserId] = ISNULL(@UserId, TaskUsers.[UserId]) AND
				1 = CASE
						WHEN @UserId IS NOT NULL THEN 1 -- set true, when user id is provided. so that join will handle record filtering and search term will have no effect on user.
						WHEN @SearchTerm IS NULL THEN 1 -- set true, when search term is null. so that join will handle record filtering and search term will have no effect on user.
						WHEN UsersMaster.FristName LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if users with given search terms are available. 
						ELSE 0
					END
		) As TaskUserRequestsMatch
		OUTER APPLY
		(
			SELECT TOP 1 
					1 AS IsMatch,
					TaskDesignations.Designation AS Designation
			FROM tblTaskDesignations AS TaskDesignations
			WHERE 
				TaskDesignations.TaskId = Tasks.TaskId AND
				1 = CASE
						WHEN @Designations = '0' AND @SearchTerm IS NULL THEN 1 -- set true, when '0' (all designations) is provided with no search term.
						WHEN @Designations = '0' AND @SearchTerm IS NOT NULL AND TaskDesignations.Designation LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if designations found by search term.
						WHEN EXISTS (SELECT ss.Item  FROM dbo.SplitString(@Designations,',') ss WHERE ss.Item = TaskDesignations.Designation) THEN 1 -- filter based on provided designations.
						ELSE 0
					END
		)  AS TaskDesignationMatch
	WHERE
		Tasks.ParentTaskId IS NULL 
		AND 
		1 = CASE 
				-- filter records only by user, when search term is not provided.
				WHEN @SearchTerm IS NULL THEN
					CASE
						WHEN TaskUserMatch.IsMatch = 1 OR TaskDesignationMatch.IsMatch = 1 THEN 1
						WHEN TaskUserRequestsMatch.IsMatch = 1 OR TaskDesignationMatch.IsMatch = 1THEN 1
						ELSE 0
					END
				-- filter records by installid, title, users when search term is provided.
				ELSE
					CASE
						WHEN Tasks.[InstallId] LIKE '%' + @SearchTerm + '%' THEN 1
						WHEN Tasks.[Title] LIKE '%' + @SearchTerm + '%' THEN 1
						WHEN TaskUserMatch.IsMatch = 1 THEN 1
						WHEN TaskUserRequestsMatch.IsMatch = 1 THEN 1
						ELSE 0
					END
			END
		--AND
		--1 = CASE 
		--		WHEN @SearchTerm IS NULL THEN 
		--			CASE
		--				WHEN TaskDesignationMatch.IsMatch = 1 THEN 1
		--				ELSE 0
		--			END
		--		ELSE
		--			CASE
		--				WHEN Tasks.[InstallId] LIKE '%' + @SearchTerm + '%' THEN 1
		--				WHEN Tasks.[Title] LIKE '%' + @SearchTerm + '%' THEN 1
		--				WHEN TaskDesignationMatch.IsMatch = 1 THEN 1
		--				ELSE 0
		--			END
		--	END 
		AND
		Tasks.[Status] = ISNULL(@Status,Tasks.[Status]) 
		AND
		CONVERT(VARCHAR,Tasks.[CreatedOn],101)  >= ISNULL(@CreatedFrom,CONVERT(VARCHAR,Tasks.[CreatedOn],101)) AND
		CONVERT(VARCHAR,Tasks.[CreatedOn],101)  <= ISNULL(@CreatedTo,CONVERT(VARCHAR,Tasks.[CreatedOn],101))

END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 15 Nov 16
-- Description:	Insert task acceptance history.
-- =============================================
ALTER PROCEDURE [dbo].[InsertTaskAcceptance]
	@TaskId		BIGINT,
	@UserId int,
	@IsInstallUser bit,
	@IsAccepted BIT
AS
BEGIN

	INSERT INTO [dbo].[tblTaskAcceptance]
           ([TaskId]
           ,[UserId]
           ,[IsInstallUser]
           ,[IsAccepted]
           ,[DateCreated])
     VALUES
           (@TaskId
           ,@UserId
           ,@IsInstallUser
           ,@IsAccepted
           ,GETDATE())

END
GO

-- =============================================
-- Author:		Yogesh Keraliya
-- Create date: 04/07/2016
-- Description:	Load all details of task for edit.
-- =============================================
-- usp_GetTaskDetails 170
ALTER PROCEDURE [dbo].[usp_GetTaskDetails] 
(
	@TaskId int 
)	  
AS
BEGIN
	
	SET NOCOUNT ON;

	-- task manager detail
	DECLARE @AssigningUser varchar(50) = NULL

	SELECT @AssigningUser = Users.[Username] 
	FROM 
		tblTask AS Task 
		INNER JOIN [dbo].[tblUsers] AS Users  ON Task.[CreatedBy] = Users.Id
	WHERE TaskId = @TaskId

	IF(@AssigningUser IS NULL)
	BEGIN
		SELECT @AssigningUser = Users.FristName + ' ' + Users.LastName 
		FROM 
			tblTask AS Task 
			INNER JOIN [dbo].[tblInstallUsers] AS Users  ON Task.[CreatedBy] = Users.Id
		WHERE TaskId = @TaskId
	END

	-- task's main details
	SELECT Title, [Description], [Status], DueDate,Tasks.[Hours], Tasks.CreatedOn, Tasks.TaskPriority,
		   Tasks.InstallId, Tasks.CreatedBy, @AssigningUser AS AssigningManager ,Tasks.TaskType, Tasks.IsTechTask,
		   STUFF
			(
				(SELECT  CAST(', ' + ttuf.[Attachment] + '@' + ttuf.[AttachmentOriginal] as VARCHAR(max)) AS attachment
				FROM dbo.tblTaskUserFiles ttuf
				WHERE ttuf.TaskId = Tasks.TaskId
				FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)')
				,1
				,2
				,' '
			) AS attachment
	FROM tblTask AS Tasks
	WHERE Tasks.TaskId = @TaskId

	-- task's designation details
	SELECT Designation
	FROM tblTaskDesignations
	WHERE (TaskId = @TaskId)

	-- task's assigned users
	SELECT UserId, TaskId
	FROM tblTaskAssignedUsers
	WHERE (TaskId = @TaskId)

	-- task's notes and attachment information.
	--SELECT	TaskUsers.Id,TaskUsers.UserId, TaskUsers.UserType, TaskUsers.Notes, TaskUsers.UserAcceptance, TaskUsers.UpdatedOn, 
	--	    TaskUsers.[Status], TaskUsers.TaskId, tblInstallUsers.FristName,TaskUsers.UserFirstName, tblInstallUsers.Designation,
	--		(SELECT COUNT(ttuf.[Id]) FROM dbo.tblTaskUserFiles ttuf WHERE ttuf.[TaskUpdateID] = TaskUsers.Id) AS AttachmentCount,
	--		dbo.UDF_GetTaskUpdateAttachments(TaskUsers.Id) AS attachments
	--FROM    
	--	tblTaskUser AS TaskUsers 
	--	LEFT OUTER JOIN tblInstallUsers ON TaskUsers.UserId = tblInstallUsers.Id
	--WHERE (TaskUsers.TaskId = @TaskId) 
	
	-- Description:	Get All Notes along with Attachments.
	-- Modify by :: Aavadesh Patel :: 10.08.2016 23:28

;WITH TaskHistory
AS 
(
	SELECT	TaskUsers.Id,TaskUsers.UserId, 
		TaskUsers.UserType, TaskUsers.Notes, 
		TaskUsers.UserAcceptance, TaskUsers.UpdatedOn, 
		TaskUsers.[Status], TaskUsers.TaskId, 
		tblInstallUsers.FristName,TaskUsers.UserFirstName, 
		tblInstallUsers.Designation,(SELECT COUNT(ttuf.[Id]) FROM dbo.tblTaskUserFiles ttuf WHERE ttuf.[TaskUpdateID] = TaskUsers.Id) AS AttachmentCount,
		dbo.UDF_GetTaskUpdateAttachments(TaskUsers.Id) AS attachments,
		'' as AttachmentOriginal , 0 as TaskUserFilesID,
		'' as Attachment , '' as FileType
	FROM    
		tblTaskUser AS TaskUsers 
		LEFT OUTER JOIN tblInstallUsers ON TaskUsers.UserId = tblInstallUsers.Id
	WHERE (TaskUsers.TaskId = @TaskId) AND (TaskUsers.Notes <> '' OR TaskUsers.Notes IS NOT NULL) 
	
	
	Union All 
		
	SELECT	tblTaskUserFiles.Id , tblTaskUserFiles.UserId , 
		'' as UserType , '' as Notes , 
		'' as UserAcceptance , tblTaskUserFiles.AttachedFileDate AS UpdatedOn,
		'' as [Status] , tblTaskUserFiles.TaskId , 
		tblInstallUsers.FristName  , tblInstallUsers.FristName as UserFirstName , 
		'' as Designation , '' as AttachmentCount , 
		'' as attachments,
		 tblTaskUserFiles.AttachmentOriginal,tblTaskUserFiles.Id as  TaskUserFilesID,
		 tblTaskUserFiles.Attachment, tblTaskUserFiles.FileType
	FROM   tblTaskUserFiles   
	LEFT OUTER JOIN tblInstallUsers ON tblInstallUsers.Id = tblTaskUserFiles.UserId
	WHERE (tblTaskUserFiles.TaskId = @TaskId) AND (tblTaskUserFiles.Attachment <> '' OR tblTaskUserFiles.Attachment IS NOT NULL)
)

SELECT * from TaskHistory ORDER BY  UpdatedOn DESC
	
	-- sub tasks
	SELECT Tasks.TaskId, Title, [Description], Tasks.[Status], DueDate,Tasks.[Hours], Tasks.CreatedOn, Tasks.TaskPriority,
		   Tasks.InstallId, Tasks.CreatedBy, @AssigningUser AS AssigningManager , UsersMaster.FristName,
		   Tasks.TaskType,Tasks.TaskPriority, Tasks.IsTechTask,
		   STUFF
			(
				(SELECT  CAST(', ' + ttuf.[Attachment] + '@' + ttuf.[AttachmentOriginal] as VARCHAR(max)) AS attachment
				FROM dbo.tblTaskUserFiles ttuf
				WHERE ttuf.TaskId = Tasks.TaskId
				FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)')
				,1
				,2
				,' '
			) AS attachment
	FROM 
		tblTask AS Tasks LEFT OUTER JOIN
        tblTaskAssignedUsers AS TaskUsers ON Tasks.TaskId = TaskUsers.TaskId LEFT OUTER JOIN
        tblInstallUsers AS UsersMaster ON TaskUsers.UserId = UsersMaster.Id --LEFT OUTER JOIN
		--tblTaskDesignations AS TaskDesignation ON Tasks.TaskId = TaskDesignation.TaskId
	WHERE Tasks.ParentTaskId = @TaskId
    
	-- main task attachments
	SELECT 
		CAST(
				--tuf.[Attachment] + '@' + tuf.[AttachmentOriginal] 
				ISNULL(tuf.[Attachment],'') + '@' + ISNULL(tuf.[AttachmentOriginal],'') 
				AS VARCHAR(MAX)
			) AS attachment,
		ISNULL(u.FirstName,iu.FristName) AS FirstName
	FROM dbo.tblTaskUserFiles tuf
			LEFT JOIN tblUsers u ON tuf.UserId = u.Id --AND tuf.UserType = u.Usertype
			LEFT JOIN tblInstallUsers iu ON tuf.UserId = iu.Id --AND tuf.UserType = u.UserType
	WHERE tuf.TaskId = @TaskId

END

--==========================================================================================================================================================================================

-- Uploaded on live 16 Nov 2016

--==========================================================================================================================================================================================

CREATE TABLE tblContentSettings
(
[Id] BIGINT PRIMARY KEY IDENTITY(1,1),
[Key] VARCHAR(100) NOT NULL UNIQUE,
[Value] TEXT
)
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 17 Nov 16
-- Description:	Insert global settings with large content.
-- =============================================
CREATE PROCEDURE [dbo].[InsertContentSetting]
	@Key VARCHAR(100),
	@Value TEXT
AS
BEGIN

	INSERT INTO [dbo].[tblContentSettings]
           ([Key]
           ,[Value])
     VALUES
           (@Key
           ,@Value)

END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 17 Nov 16
-- Description:	Update global settings with large content.
-- =============================================
CREATE PROCEDURE [dbo].[UpdateContentSetting]
	@Key VARCHAR(100),
	@Value TEXT
AS
BEGIN

	UPDATE [dbo].[tblContentSettings]
	SET
        [Value] = @Value
	WHERE [Key] = @Key

END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 17 Nov 16
-- Description:	Delete global settings with large content.
-- =============================================
CREATE PROCEDURE [dbo].[DeleteContentSetting]
	@Key VARCHAR(100)
AS
BEGIN

	DELETE
	FROM [dbo].[tblContentSettings]
	WHERE [Key] = @Key

END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 17 Nov 16
-- Description:	Get global settings with large content.
-- =============================================
CREATE PROCEDURE [dbo].[GetContentSetting]
	@Key VARCHAR(100)
AS
BEGIN

	SELECT Value
	FROM [dbo].[tblContentSettings]
	WHERE [Key] = @Key

END
GO

EXEC [dbo].[InsertContentSetting] 
'TASK_HELP_TEXT',
'<small><b>Hi, I am justin grove and i am your manager &amp; creator of this task. Yogesh Keraliya is your direct technical manager. Please use below section to collborate on this task.</b></small>'
GO

--==========================================================================================================================================================================================

-- Uploaded on live 18 Nov 2016

--==========================================================================================================================================================================================

/****** Object:  StoredProcedure [dbo].[InsertTaskWorkSpecification]    Script Date: 21-Nov-16 12:13:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 13 Sep 16
-- Description:	Insert Task specification and also record history.
-- =============================================
ALTER PROCEDURE [dbo].[InsertTaskWorkSpecification]
	@ParentTaskWorkSpecificationId bigint = null,
	@CustomId varchar(10),
	@TaskId bigint,
	@Description text,
	@AdminStatus BIT = 0,
	@TechLeadStatus BIT = 0,
	@OtherUserStatus BIT = 0,
	@AdminUserId int = NULL,
	@TechLeadUserId int = NULL,
	@OtherUserId int = NULL,
	@IsAdminInstallUser bit = NULL,
	@IsTechLeadInstallUser bit = NULL,
	@IsOtherUserInstallUser bit = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE 
	@AdminStatusUpdated DATETIME = NULL,
	@TechLeadStatusUpdated DATETIME = NULL,
	@OtherUserStatusUpdated DATETIME = NULL

	IF @AdminUserId IS NOT NULL
	BEGIN
		SET @AdminStatusUpdated = GETDATE()
	END
	ELSE IF @TechLeadUserId IS NOT NULL
	BEGIN
		SET @TechLeadStatusUpdated = GETDATE()
	END
	ELSE IF @OtherUserId IS NOT NULL
	BEGIN
		SET @OtherUserStatusUpdated = GETDATE()
	END

	INSERT INTO [dbo].[tblTaskWorkSpecifications]
		([CustomId]
		,[TaskId]
		,[Description]
		,[AdminStatus]
		,[TechLeadStatus]
		,[OtherUserStatus]
		,[DateCreated]
		,[DateUpdated]
		,[AdminStatusUpdated]
		,[TechLeadStatusUpdated]
		,[OtherUserStatusUpdated]
		,[AdminUserId]
		,[TechLeadUserId]
		,[OtherUserId]
		,[IsAdminInstallUser]
		,[IsTechLeadInstallUser]
		,[IsOtherUserInstallUser]
		,[ParentTaskWorkSpecificationId])
	VALUES
		(@CustomId
		,@TaskId
		,@Description
		,@AdminStatus
		,@TechLeadStatus
		,@OtherUserStatus
		,GETDATE()
		,GETDATE()
		,@AdminStatusUpdated
		,@TechLeadStatusUpdated
		,@OtherUserStatusUpdated
		,@AdminUserId
		,@TechLeadUserId
		,@OtherUserId
		,@IsAdminInstallUser
		,@IsTechLeadInstallUser
		,@IsOtherUserInstallUser
		,@ParentTaskWorkSpecificationId)

END
GO

ALTER TABLE [dbo].[tblTaskWorkSpecifications]
ADD
	Title varchar(300) NULL,
	URL varchar(300) NULL
GO

/****** Object:  StoredProcedure [dbo].[InsertTaskWorkSpecification]    Script Date: 22-Nov-16 12:03:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Yogesh
-- Create date: 13 Sep 16
-- Description:	Insert Task specification and also record history.
-- =============================================
ALTER PROCEDURE [dbo].[InsertTaskWorkSpecification]
	@ParentTaskWorkSpecificationId bigint = null,
	@CustomId varchar(10),
	@TaskId bigint,
	@Description text,
	@Title varchar(300),
	@URL varchar(300),
	@AdminStatus BIT = 0,
	@TechLeadStatus BIT = 0,
	@OtherUserStatus BIT = 0,
	@AdminUserId int = NULL,
	@TechLeadUserId int = NULL,
	@OtherUserId int = NULL,
	@IsAdminInstallUser bit = NULL,
	@IsTechLeadInstallUser bit = NULL,
	@IsOtherUserInstallUser bit = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE 
	@AdminStatusUpdated DATETIME = NULL,
	@TechLeadStatusUpdated DATETIME = NULL,
	@OtherUserStatusUpdated DATETIME = NULL

	IF @AdminUserId IS NOT NULL
	BEGIN
		SET @AdminStatusUpdated = GETDATE()
	END
	ELSE IF @TechLeadUserId IS NOT NULL
	BEGIN
		SET @TechLeadStatusUpdated = GETDATE()
	END
	ELSE IF @OtherUserId IS NOT NULL
	BEGIN
		SET @OtherUserStatusUpdated = GETDATE()
	END

	INSERT INTO [dbo].[tblTaskWorkSpecifications]
		([CustomId]
		,[TaskId]
		,[Description]
		,[Title]
		,[URL]
		,[AdminStatus]
		,[TechLeadStatus]
		,[OtherUserStatus]
		,[DateCreated]
		,[DateUpdated]
		,[AdminStatusUpdated]
		,[TechLeadStatusUpdated]
		,[OtherUserStatusUpdated]
		,[AdminUserId]
		,[TechLeadUserId]
		,[OtherUserId]
		,[IsAdminInstallUser]
		,[IsTechLeadInstallUser]
		,[IsOtherUserInstallUser]
		,[ParentTaskWorkSpecificationId])
	VALUES
		(@CustomId
		,@TaskId
		,@Description
		,@Title
		,@URL
		,@AdminStatus
		,@TechLeadStatus
		,@OtherUserStatus
		,GETDATE()
		,GETDATE()
		,@AdminStatusUpdated
		,@TechLeadStatusUpdated
		,@OtherUserStatusUpdated
		,@AdminUserId
		,@TechLeadUserId
		,@OtherUserId
		,@IsAdminInstallUser
		,@IsTechLeadInstallUser
		,@IsOtherUserInstallUser
		,@ParentTaskWorkSpecificationId)

END

GO


/****** Object:  StoredProcedure [dbo].[UpdateTaskWorkSpecification]    Script Date: 22-Nov-16 12:05:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Yogesh
-- Create date: 13 Sep 16
-- Description:	Update Task specification and also record history.
-- =============================================
ALTER PROCEDURE [dbo].[UpdateTaskWorkSpecification]
	@Id bigint,
	@ParentTaskWorkSpecificationId bigint = null,
	@CustomId varchar(10),
	@TaskId bigint,
	@Description text,
	@Title varchar(300),
	@URL varchar(300)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[tblTaskWorkSpecifications]
	SET 
		[CustomId] = @CustomId
		,[TaskId] = @TaskId
		,[Description] = @Description
		,[Title] = @Title
		,[URL] = @URL
		,[ParentTaskWorkSpecificationId] = @ParentTaskWorkSpecificationId
		,[DateUpdated] = GETDATE()

		-- reset status for all, as any change requires 2 level freezing.
		,[AdminStatus] = 0
		,[TechLeadStatus] = 0
		,[OtherUserStatus] = 0
		,[AdminStatusUpdated] = NULL
		,[TechLeadStatusUpdated] = NULL
		,[OtherUserStatusUpdated] = NULL
		,[AdminUserId] = NULL
		,[TechLeadUserId] = NULL
		,[OtherUserId] = NULL
		,[IsAdminInstallUser] = NULL
		,[IsTechLeadInstallUser] = NULL
		,[IsOtherUserInstallUser] = NULL
	WHERE Id = @Id

END
GO



CREATE VIEW [dbo].[TaskListView] 
AS
SELECT 
	Tasks.*,
	STUFF
	(
		(SELECT  CAST(', ' + td.Designation as VARCHAR) AS Designation
		FROM tblTaskDesignations td
		WHERE td.TaskId = Tasks.TaskId
		FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)')
		,1
		,2
		,' '
	) AS TaskDesignations,
	STUFF
	(
		(SELECT  CAST(', ' + u.FristName as VARCHAR) AS Name
		FROM tblTaskAssignedUsers tu
			INNER JOIN tblInstallUsers u ON tu.UserId = u.Id
		WHERE tu.TaskId = Tasks.TaskId
		FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)')
		,1
		,2
		,' '
	) AS TaskAssignedUsers,
	STUFF
	(
		(SELECT  ',' + CAST(tu.UserId as VARCHAR) AS Id
		FROM tblTaskAssignedUsers tu
		WHERE tu.TaskId = Tasks.TaskId
		FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)')
		,1
		,1
		,''
	) AS TaskAssignedUserIds,
	STUFF
	(
		(SELECT  CAST(', ' + CAST(tu.UserId AS VARCHAR) + ':' + u.FristName as VARCHAR) AS Name
		FROM tblTaskAssignmentRequests tu
			INNER JOIN tblInstallUsers u ON tu.UserId = u.Id
		WHERE tu.TaskId = Tasks.TaskId
		FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)')
		,1
		,2
		,' '
	) AS TaskAssignmentRequestUsers,
	STUFF
	(
		(SELECT  ', ' + CAST(tu.UserId AS VARCHAR) AS UserId
		FROM tblTaskAcceptance tu
		WHERE tu.TaskId = Tasks.TaskId
		FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)')
		,1
		,2
		,' '
	) AS TaskAcceptanceUsers
FROM          
	tblTask AS Tasks 

GO


/****** Object:  StoredProcedure [dbo].[uspSearchTasks]    Script Date: 23-Nov-16 11:19:27 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Yogesh Keraliya
-- Create date: 8/25/16
-- Description:	This procedure is used to search tasks by different parameters.
-- =============================================
ALTER PROCEDURE [dbo].[uspSearchTasks]
	@Designations	VARCHAR(4000) = '0',
	@UserId			INT = NULL,
	@Status			TINYINT = NULL,
	@CreatedFrom	DATETIME = NULL,
	@CreatedTo		DATETIME = NULL,
	@SearchTerm		VARCHAR(250) = NULL,
	@SortExpression	VARCHAR(250) = 'CreatedOn DESC',
	@ExcludeStatus	TINYINT = NULL,
	@Admin			BIT,
	@PageIndex		INT = 0,
	@PageSize		INT = 10
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET @PageIndex = @PageIndex + 1

	;WITH 
	
	Tasklist AS
	(	
		SELECT 
			--TaskUserMatch.IsMatch AS TaskUserMatch,
			--TaskUserRequestsMatch.IsMatch AS TaskUserRequestsMatch,
			--TaskDesignationMatch.IsMatch AS TaskDesignationMatch,
			Tasks.*
		FROM          
			[TaskListView] AS Tasks 
			OUTER APPLY
			(
				SELECT TOP 1 
						1 AS IsMatch,
						TaskUsers.UserId AS UserId,
						UsersMaster.FristName AS FristName
				FROM tblTaskAssignedUsers TaskUsers
						LEFT JOIN tblInstallUsers AS UsersMaster ON TaskUsers.UserId = UsersMaster.Id
				WHERE 
					TaskUsers.TaskId = Tasks.TaskId AND
					TaskUsers.[UserId] = ISNULL(@UserId, TaskUsers.[UserId]) AND
					1 = CASE
							WHEN @UserId IS NOT NULL THEN 1 -- set true, when user id is provided. so that join will handle record filtering and search term will have no effect on user.
							WHEN @SearchTerm IS NULL THEN 1 -- set true, when search term is null. so that join will handle record filtering and search term will have no effect on user.
							WHEN UsersMaster.FristName LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if users with given search terms are available. 
							ELSE 0
						END
			) As TaskUserMatch
			OUTER APPLY
			(
				SELECT TOP 1 
						1 AS IsMatch,
						TaskUsers.UserId AS UserId,
						UsersMaster.FristName AS FristName
				FROM tblTaskAssignmentRequests TaskUsers
						LEFT JOIN tblInstallUsers AS UsersMaster ON TaskUsers.UserId = UsersMaster.Id
				WHERE 
					TaskUsers.TaskId = Tasks.TaskId AND
					TaskUsers.[UserId] = ISNULL(@UserId, TaskUsers.[UserId]) AND
					1 = CASE
							WHEN @UserId IS NOT NULL THEN 1 -- set true, when user id is provided. so that join will handle record filtering and search term will have no effect on user.
							WHEN @SearchTerm IS NULL THEN 1 -- set true, when search term is null. so that join will handle record filtering and search term will have no effect on user.
							WHEN UsersMaster.FristName LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if users with given search terms are available. 
							ELSE 0
						END
			) As TaskUserRequestsMatch
			OUTER APPLY
			(
				SELECT TOP 1 
						CASE
						WHEN @SearchTerm IS NULL THEN
							CASE
								WHEN @Designations = '0' THEN 1
								WHEN EXISTS (SELECT ss.Item  FROM dbo.SplitString(@Designations,',') ss WHERE ss.Item = TaskDesignations.Designation) THEN 1
								ELSE 0 
							END
						ELSE 
							CASE
								WHEN @Designations = '0' AND TaskDesignations.Designation LIKE '%' + @SearchTerm + '%' THEN 1
								WHEN (Tasks.[InstallId] LIKE '%' + @SearchTerm + '%'  OR Tasks.[Title] LIKE '%' + @SearchTerm + '%') THEN 1
								ELSE 0
							END
						END AS IsMatch,
						TaskDesignations.Designation AS Designation
				FROM tblTaskDesignations AS TaskDesignations
				WHERE 
					TaskDesignations.TaskId = Tasks.TaskId AND
					1 = CASE
							WHEN @Designations = '0' AND @SearchTerm IS NULL THEN 1 -- set true, when '0' (all designations) is provided with no search term.
							WHEN @Designations = '0' AND @SearchTerm IS NOT NULL AND TaskDesignations.Designation LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if designations found by search term.
							WHEN EXISTS (SELECT ss.Item  FROM dbo.SplitString(@Designations,',') ss WHERE ss.Item = TaskDesignations.Designation) THEN 1 -- filter based on provided designations.
							ELSE 0
						END
			)  AS TaskDesignationMatch
		WHERE
			Tasks.ParentTaskId IS NULL 
			AND
			1 = CASE
					WHEN @Admin = 1 THEN 1
					ELSE
						CASE
							WHEN Tasks.[Status] = @ExcludeStatus THEN 0
							ELSE 1
					END
				END
			AND 
			1 = CASE 
					-- filter records only by user, when search term is not provided.
					WHEN @SearchTerm IS NULL THEN
						CASE
							WHEN TaskUserMatch.IsMatch = 1 OR TaskDesignationMatch.IsMatch = 1 THEN 1
							WHEN TaskUserRequestsMatch.IsMatch = 1 OR TaskDesignationMatch.IsMatch = 1 THEN 1
							ELSE 0
						END
					-- filter records by installid, title, users when search term is provided.
					ELSE
						CASE
							WHEN Tasks.[InstallId] LIKE '%' + @SearchTerm + '%' THEN 1
							WHEN Tasks.[Title] LIKE '%' + @SearchTerm + '%' THEN 1
							WHEN TaskUserMatch.IsMatch = 1 THEN 1
							WHEN TaskUserRequestsMatch.IsMatch = 1 THEN 1
							ELSE 0
						END
				END
			AND
			Tasks.[Status] = ISNULL(@Status,Tasks.[Status]) 
			AND
			CONVERT(VARCHAR,Tasks.[CreatedOn],101)  >= ISNULL(@CreatedFrom,CONVERT(VARCHAR,Tasks.[CreatedOn],101)) AND
			CONVERT(VARCHAR,Tasks.[CreatedOn],101)  <= ISNULL(@CreatedTo,CONVERT(VARCHAR,Tasks.[CreatedOn],101))
	),

	FinalData AS
	( 
		SELECT * ,
			Row_number() OVER
			(
				ORDER BY
					Tasklist.IsDeleted ASC, CASE WHEN @SortExpression = 'UserID DESC' THEN Tasklist.TaskAssignedUsers END DESC,
					Tasklist.IsDeleted ASC, CASE WHEN @SortExpression = 'CreatedOn DESC' THEN Tasklist.CreatedOn END DESC,
					Tasklist.IsDeleted ASC, CASE WHEN @SortExpression = 'Status ASC' THEN Tasklist.[Status] END ASC
			) AS RowNo
		FROM Tasklist 
	)
	
	-- get records
	SELECT * 
	FROM FinalData 
	WHERE  
		RowNo BETWEEN (@PageIndex - 1) * @PageSize + 1 AND 
		@PageIndex * @PageSize

	-- get record count
	SELECT 
		COUNT(DISTINCT Tasks.TaskId) AS VirtualCount
	FROM          
		tblTask AS Tasks 
		OUTER APPLY
		(
			SELECT TOP 1 
					1 AS IsMatch,
					TaskUsers.UserId AS UserId,
					UsersMaster.FristName AS FristName
			FROM tblTaskAssignedUsers TaskUsers
					LEFT JOIN tblInstallUsers AS UsersMaster ON TaskUsers.UserId = UsersMaster.Id
			WHERE 
				TaskUsers.TaskId = Tasks.TaskId AND
				TaskUsers.[UserId] = ISNULL(@UserId, TaskUsers.[UserId]) AND
				1 = CASE
						WHEN @UserId IS NOT NULL THEN 1 -- set true, when user id is provided. so that join will handle record filtering and search term will have no effect on user.
						WHEN @SearchTerm IS NULL THEN 1 -- set true, when search term is null. so that join will handle record filtering and search term will have no effect on user.
						WHEN UsersMaster.FristName LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if users with given search terms are available. 
						ELSE 0
					END
		) As TaskUserMatch
		OUTER APPLY
		(
			SELECT TOP 1 
					1 AS IsMatch,
					TaskUsers.UserId AS UserId,
					UsersMaster.FristName AS FristName
			FROM tblTaskAssignmentRequests TaskUsers
					LEFT JOIN tblInstallUsers AS UsersMaster ON TaskUsers.UserId = UsersMaster.Id
			WHERE 
				TaskUsers.TaskId = Tasks.TaskId AND
				TaskUsers.[UserId] = ISNULL(@UserId, TaskUsers.[UserId]) AND
				1 = CASE
						WHEN @UserId IS NOT NULL THEN 1 -- set true, when user id is provided. so that join will handle record filtering and search term will have no effect on user.
						WHEN @SearchTerm IS NULL THEN 1 -- set true, when search term is null. so that join will handle record filtering and search term will have no effect on user.
						WHEN UsersMaster.FristName LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if users with given search terms are available. 
						ELSE 0
					END
		) As TaskUserRequestsMatch
		OUTER APPLY
		(
			SELECT TOP 1 
					1 AS IsMatch,
					TaskDesignations.Designation AS Designation
			FROM tblTaskDesignations AS TaskDesignations
			WHERE 
				TaskDesignations.TaskId = Tasks.TaskId AND
				1 = CASE
						WHEN @Designations = '0' AND @SearchTerm IS NULL THEN 1 -- set true, when '0' (all designations) is provided with no search term.
						WHEN @Designations = '0' AND @SearchTerm IS NOT NULL AND TaskDesignations.Designation LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if designations found by search term.
						WHEN EXISTS (SELECT ss.Item  FROM dbo.SplitString(@Designations,',') ss WHERE ss.Item = TaskDesignations.Designation) THEN 1 -- filter based on provided designations.
						ELSE 0
					END
		)  AS TaskDesignationMatch
	WHERE
		Tasks.ParentTaskId IS NULL 
		AND 
		1 = CASE 
				-- filter records only by user, when search term is not provided.
				WHEN @SearchTerm IS NULL THEN
					CASE
						WHEN TaskUserMatch.IsMatch = 1 OR TaskDesignationMatch.IsMatch = 1 THEN 1
						WHEN TaskUserRequestsMatch.IsMatch = 1 OR TaskDesignationMatch.IsMatch = 1THEN 1
						ELSE 0
					END
				-- filter records by installid, title, users when search term is provided.
				ELSE
					CASE
						WHEN Tasks.[InstallId] LIKE '%' + @SearchTerm + '%' THEN 1
						WHEN Tasks.[Title] LIKE '%' + @SearchTerm + '%' THEN 1
						WHEN TaskUserMatch.IsMatch = 1 THEN 1
						WHEN TaskUserRequestsMatch.IsMatch = 1 THEN 1
						ELSE 0
					END
			END
		AND
		Tasks.[Status] = ISNULL(@Status,Tasks.[Status]) 
		AND
		CONVERT(VARCHAR,Tasks.[CreatedOn],101)  >= ISNULL(@CreatedFrom,CONVERT(VARCHAR,Tasks.[CreatedOn],101)) AND
		CONVERT(VARCHAR,Tasks.[CreatedOn],101)  <= ISNULL(@CreatedTo,CONVERT(VARCHAR,Tasks.[CreatedOn],101))

END

GO


USE [JGBS_Dev]
GO

/****** Object:  StoredProcedure [dbo].[uspSearchTasks]    Script Date: 23-Nov-16 11:19:27 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Yogesh Keraliya
-- Create date: 8/25/16
-- Description:	This procedure is used to search tasks by different parameters.
-- =============================================
ALTER PROCEDURE [dbo].[uspSearchTasks]
	@Designations	VARCHAR(4000) = '0',
	@UserId			INT = NULL,
	@Status			TINYINT = NULL,
	@CreatedFrom	DATETIME = NULL,
	@CreatedTo		DATETIME = NULL,
	@SearchTerm		VARCHAR(250) = NULL,
	@SortExpression	VARCHAR(250) = 'CreatedOn DESC',
	@ExcludeStatus	TINYINT = NULL,
	@Admin			BIT,
	@PageIndex		INT = 0,
	@PageSize		INT = 10,
	@ClosedStatus	TINYINT = 7,
	@DeletedStatus	TINYINT = 9
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET @PageIndex = @PageIndex + 1

	;WITH 
	
	Tasklist AS
	(	
	
		SELECT 
			--TaskUserMatch.IsMatch AS TaskUserMatch,
			--TaskUserRequestsMatch.IsMatch AS TaskUserRequestsMatch,
			--TaskDesignationMatch.IsMatch AS TaskDesignationMatch,
			Tasks.*
		FROM
			(
				SELECT 
					Tasks.*,
					1 AS SortOrder,
					Row_number() OVER
					(
						ORDER BY
							CASE WHEN @SortExpression = 'UserID DESC' THEN Tasks.TaskAssignedUsers END DESC,
							CASE WHEN @SortExpression = 'CreatedOn DESC' THEN Tasks.CreatedOn END DESC,
							CASE WHEN @SortExpression = 'Status ASC' THEN Tasks.[Status] END ASC
					) AS RowNo_Order
				FROM          
					[TaskListView] Tasks
				WHERE 
					[Status] NOT IN (@ClosedStatus,@DeletedStatus)

				UNION

				SELECT 
					Tasks.*,
					2 AS SortOrder,
					Row_number() OVER
					(
						ORDER BY
							CASE WHEN @SortExpression = 'UserID DESC' THEN Tasks.TaskAssignedUsers END DESC,
							CASE WHEN @SortExpression = 'CreatedOn DESC' THEN Tasks.CreatedOn END DESC,
							CASE WHEN @SortExpression = 'Status ASC' THEN Tasks.[Status] END ASC
					) AS RowNo_Order
				FROM          
					[TaskListView] Tasks
				WHERE 
					[Status] = @ClosedStatus

				UNION

				SELECT 
					Tasks.*,
					3 AS SortOrder,
					Row_number() OVER
					(
						ORDER BY
							CASE WHEN @SortExpression = 'UserID DESC' THEN Tasks.TaskAssignedUsers END DESC,
							CASE WHEN @SortExpression = 'CreatedOn DESC' THEN Tasks.CreatedOn END DESC,
							CASE WHEN @SortExpression = 'Status ASC' THEN Tasks.[Status] END ASC
					) AS RowNo_Order
				FROM          
					[TaskListView] Tasks
				WHERE 
					[Status] = @DeletedStatus
			) Tasks    
			OUTER APPLY
			(
				SELECT TOP 1 
						1 AS IsMatch,
						TaskUsers.UserId AS UserId,
						UsersMaster.FristName AS FristName
				FROM tblTaskAssignedUsers TaskUsers
						LEFT JOIN tblInstallUsers AS UsersMaster ON TaskUsers.UserId = UsersMaster.Id
				WHERE 
					TaskUsers.TaskId = Tasks.TaskId AND
					TaskUsers.[UserId] = ISNULL(@UserId, TaskUsers.[UserId]) AND
					1 = CASE
							WHEN @UserId IS NOT NULL THEN 1 -- set true, when user id is provided. so that join will handle record filtering and search term will have no effect on user.
							WHEN @SearchTerm IS NULL THEN 1 -- set true, when search term is null. so that join will handle record filtering and search term will have no effect on user.
							WHEN UsersMaster.FristName LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if users with given search terms are available. 
							ELSE 0
						END
			) As TaskUserMatch
			OUTER APPLY
			(
				SELECT TOP 1 
						1 AS IsMatch,
						TaskUsers.UserId AS UserId,
						UsersMaster.FristName AS FristName
				FROM tblTaskAssignmentRequests TaskUsers
						LEFT JOIN tblInstallUsers AS UsersMaster ON TaskUsers.UserId = UsersMaster.Id
				WHERE 
					TaskUsers.TaskId = Tasks.TaskId AND
					TaskUsers.[UserId] = ISNULL(@UserId, TaskUsers.[UserId]) AND
					1 = CASE
							WHEN @UserId IS NOT NULL THEN 1 -- set true, when user id is provided. so that join will handle record filtering and search term will have no effect on user.
							WHEN @SearchTerm IS NULL THEN 1 -- set true, when search term is null. so that join will handle record filtering and search term will have no effect on user.
							WHEN UsersMaster.FristName LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if users with given search terms are available. 
							ELSE 0
						END
			) As TaskUserRequestsMatch
			OUTER APPLY
			(
				SELECT TOP 1 
						CASE
						WHEN @SearchTerm IS NULL THEN
							CASE
								WHEN @Designations = '0' THEN 1
								WHEN EXISTS (SELECT ss.Item  FROM dbo.SplitString(@Designations,',') ss WHERE ss.Item = TaskDesignations.Designation) THEN 1
								ELSE 0 
							END
						ELSE 
							CASE
								WHEN @Designations = '0' AND TaskDesignations.Designation LIKE '%' + @SearchTerm + '%' THEN 1
								WHEN (Tasks.[InstallId] LIKE '%' + @SearchTerm + '%'  OR Tasks.[Title] LIKE '%' + @SearchTerm + '%') THEN 1
								ELSE 0
							END
						END AS IsMatch,
						TaskDesignations.Designation AS Designation
				FROM tblTaskDesignations AS TaskDesignations
				WHERE 
					TaskDesignations.TaskId = Tasks.TaskId AND
					1 = CASE
							WHEN @Designations = '0' AND @SearchTerm IS NULL THEN 1 -- set true, when '0' (all designations) is provided with no search term.
							WHEN @Designations = '0' AND @SearchTerm IS NOT NULL AND TaskDesignations.Designation LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if designations found by search term.
							WHEN EXISTS (SELECT ss.Item  FROM dbo.SplitString(@Designations,',') ss WHERE ss.Item = TaskDesignations.Designation) THEN 1 -- filter based on provided designations.
							ELSE 0
						END
			)  AS TaskDesignationMatch
		WHERE
			Tasks.ParentTaskId IS NULL 
			AND
			1 = CASE
					WHEN @Admin = 1 THEN 1
					ELSE
						CASE
							WHEN Tasks.[Status] = @ExcludeStatus THEN 0
							ELSE 1
					END
				END
			AND 
			1 = CASE 
					-- filter records only by user, when search term is not provided.
					WHEN @SearchTerm IS NULL THEN
						CASE
							WHEN TaskUserMatch.IsMatch = 1 OR TaskDesignationMatch.IsMatch = 1 THEN 1
							WHEN TaskUserRequestsMatch.IsMatch = 1 OR TaskDesignationMatch.IsMatch = 1 THEN 1
							ELSE 0
						END
					-- filter records by installid, title, users when search term is provided.
					ELSE
						CASE
							WHEN Tasks.[InstallId] LIKE '%' + @SearchTerm + '%' THEN 1
							WHEN Tasks.[Title] LIKE '%' + @SearchTerm + '%' THEN 1
							WHEN TaskUserMatch.IsMatch = 1 THEN 1
							WHEN TaskUserRequestsMatch.IsMatch = 1 THEN 1
							ELSE 0
						END
				END
			AND
			Tasks.[Status] = ISNULL(@Status,Tasks.[Status]) 
			AND
			CONVERT(VARCHAR,Tasks.[CreatedOn],101)  >= ISNULL(@CreatedFrom,CONVERT(VARCHAR,Tasks.[CreatedOn],101)) AND
			CONVERT(VARCHAR,Tasks.[CreatedOn],101)  <= ISNULL(@CreatedTo,CONVERT(VARCHAR,Tasks.[CreatedOn],101))
	),

	FinalData AS
	( 
		SELECT * ,
			Row_number() OVER(ORDER BY SortOrder ASC) AS RowNo
		FROM Tasklist 
	)
	
	-- get records
	SELECT * 
	FROM FinalData 
	WHERE  
		RowNo BETWEEN (@PageIndex - 1) * @PageSize + 1 AND 
		@PageIndex * @PageSize

	-- get record count
	SELECT 
		COUNT(DISTINCT Tasks.TaskId) AS VirtualCount
	FROM          
		tblTask AS Tasks 
		OUTER APPLY
		(
			SELECT TOP 1 
					1 AS IsMatch,
					TaskUsers.UserId AS UserId,
					UsersMaster.FristName AS FristName
			FROM tblTaskAssignedUsers TaskUsers
					LEFT JOIN tblInstallUsers AS UsersMaster ON TaskUsers.UserId = UsersMaster.Id
			WHERE 
				TaskUsers.TaskId = Tasks.TaskId AND
				TaskUsers.[UserId] = ISNULL(@UserId, TaskUsers.[UserId]) AND
				1 = CASE
						WHEN @UserId IS NOT NULL THEN 1 -- set true, when user id is provided. so that join will handle record filtering and search term will have no effect on user.
						WHEN @SearchTerm IS NULL THEN 1 -- set true, when search term is null. so that join will handle record filtering and search term will have no effect on user.
						WHEN UsersMaster.FristName LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if users with given search terms are available. 
						ELSE 0
					END
		) As TaskUserMatch
		OUTER APPLY
		(
			SELECT TOP 1 
					1 AS IsMatch,
					TaskUsers.UserId AS UserId,
					UsersMaster.FristName AS FristName
			FROM tblTaskAssignmentRequests TaskUsers
					LEFT JOIN tblInstallUsers AS UsersMaster ON TaskUsers.UserId = UsersMaster.Id
			WHERE 
				TaskUsers.TaskId = Tasks.TaskId AND
				TaskUsers.[UserId] = ISNULL(@UserId, TaskUsers.[UserId]) AND
				1 = CASE
						WHEN @UserId IS NOT NULL THEN 1 -- set true, when user id is provided. so that join will handle record filtering and search term will have no effect on user.
						WHEN @SearchTerm IS NULL THEN 1 -- set true, when search term is null. so that join will handle record filtering and search term will have no effect on user.
						WHEN UsersMaster.FristName LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if users with given search terms are available. 
						ELSE 0
					END
		) As TaskUserRequestsMatch
		OUTER APPLY
		(
			SELECT TOP 1 
					1 AS IsMatch,
					TaskDesignations.Designation AS Designation
			FROM tblTaskDesignations AS TaskDesignations
			WHERE 
				TaskDesignations.TaskId = Tasks.TaskId AND
				1 = CASE
						WHEN @Designations = '0' AND @SearchTerm IS NULL THEN 1 -- set true, when '0' (all designations) is provided with no search term.
						WHEN @Designations = '0' AND @SearchTerm IS NOT NULL AND TaskDesignations.Designation LIKE '%' + @SearchTerm + '%' THEN 1 -- set true if designations found by search term.
						WHEN EXISTS (SELECT ss.Item  FROM dbo.SplitString(@Designations,',') ss WHERE ss.Item = TaskDesignations.Designation) THEN 1 -- filter based on provided designations.
						ELSE 0
					END
		)  AS TaskDesignationMatch
	WHERE
		Tasks.ParentTaskId IS NULL 
		AND 
		1 = CASE 
				-- filter records only by user, when search term is not provided.
				WHEN @SearchTerm IS NULL THEN
					CASE
						WHEN TaskUserMatch.IsMatch = 1 OR TaskDesignationMatch.IsMatch = 1 THEN 1
						WHEN TaskUserRequestsMatch.IsMatch = 1 OR TaskDesignationMatch.IsMatch = 1THEN 1
						ELSE 0
					END
				-- filter records by installid, title, users when search term is provided.
				ELSE
					CASE
						WHEN Tasks.[InstallId] LIKE '%' + @SearchTerm + '%' THEN 1
						WHEN Tasks.[Title] LIKE '%' + @SearchTerm + '%' THEN 1
						WHEN TaskUserMatch.IsMatch = 1 THEN 1
						WHEN TaskUserRequestsMatch.IsMatch = 1 THEN 1
						ELSE 0
					END
			END
		AND
		Tasks.[Status] = ISNULL(@Status,Tasks.[Status]) 
		AND
		CONVERT(VARCHAR,Tasks.[CreatedOn],101)  >= ISNULL(@CreatedFrom,CONVERT(VARCHAR,Tasks.[CreatedOn],101)) AND
		CONVERT(VARCHAR,Tasks.[CreatedOn],101)  <= ISNULL(@CreatedTo,CONVERT(VARCHAR,Tasks.[CreatedOn],101))

END

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh Keraliya
-- Create date: 07/22/2016
-- Description:	Soft delete task from task id.
-- =============================================
ALTER PROCEDURE [dbo].[usp_DeleteTask] 
(	
	@TaskId int,
	@DeletedStatus	TINYINT = 9
)
AS
BEGIN
	
	UPDATE tblTask
	SET
		IsDeleted = 1,
		[Status] = @DeletedStatus
	WHERE
		(TaskId = @TaskId) OR (ParentTaskId = @TaskId)

END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 14 Nov 16
-- Description:	Inserts, Updates or Deletes a task.
-- =============================================
ALTER PROCEDURE [dbo].[SP_SaveOrDeleteTask]  
	 @Mode tinyint, -- 0:Insert, 1: Update, 2: Delete  
	 @TaskId bigint,  
	 @Title varchar(250),  
	 @Description varchar(MAX),  
	 @Status tinyint,  
	 @DueDate datetime = NULL,  
	 @Hours varchar(25),
	 @CreatedBy int,	
	 @InstallId varchar(50) = NULL,
	 @ParentTaskId bigint = NULL,
	 @TaskType tinyint = NULL,
	 @TaskPriority tinyint = null,
	 @IsTechTask bit = NULL,
	 @DeletedStatus	TINYINT = 9,
	 @Result int output 
AS  
BEGIN  
  
	IF @Mode=0  
	  BEGIN  
		INSERT INTO tblTask 
				(
					Title,
					[Description],
					[Status],
					DueDate,
					[Hours],
					CreatedBy,
					CreatedOn,
					IsDeleted,
					InstallId,
					ParentTaskId,
					TaskType,
					TaskPriority,
					IsTechTask,
					AdminStatus,
					TechLeadStatus,
					OtherUserStatus
				)
		VALUES
				(
					@Title,
					@Description,
					@Status,
					@DueDate,
					@Hours,
					@CreatedBy,
					GETDATE(),
					0,
					@InstallId,
					@ParentTaskId,
					@TaskType,
					@TaskPriority,
					@IsTechTask,
					0,
					0,
					0
				)  
  
		SET @Result=SCOPE_IDENTITY ()  
  
		RETURN @Result  
	END  
	ELSE IF @Mode=1 -- Update  
	BEGIN    
		UPDATE tblTask  
		SET  
			Title=@Title,  
			[Description]=@Description,  
			[Status]=@Status,  
			DueDate=@DueDate,  
			[Hours]=@Hours,
			[TaskType] = @TaskType,
			[TaskPriority] = @TaskPriority,
			[IsTechTask] = @IsTechTask
		WHERE TaskId=@TaskId  

		SET @Result= @TaskId
  
		RETURN @Result  
	END  
	ELSE IF @Mode=2 --Delete  
	BEGIN  
		UPDATE tblTask  
		SET  
			IsDeleted=1,
			[Status] = @DeletedStatus
		WHERE TaskId=@TaskId OR ParentTaskId=@TaskId  
	END  
  
END
GO
--==========================================================================================================================================================================================

-- Uploaded on live 24 Nov 2016

--==========================================================================================================================================================================================

/****** Object:  StoredProcedure [dbo].[usp_GetTaskDetails]    Script Date: 29-Nov-16 12:10:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh Keraliya
-- Create date: 04/07/2016
-- Description:	Load all details of task for edit.
-- =============================================
-- usp_GetTaskDetails 170
ALTER PROCEDURE [dbo].[usp_GetTaskDetails] 
(
	@TaskId int 
)	  
AS
BEGIN
	
	SET NOCOUNT ON;

	-- task manager detail
	DECLARE @AssigningUser varchar(50) = NULL

	SELECT @AssigningUser = Users.[Username] 
	FROM 
		tblTask AS Task 
		INNER JOIN [dbo].[tblUsers] AS Users  ON Task.[CreatedBy] = Users.Id
	WHERE TaskId = @TaskId

	IF(@AssigningUser IS NULL)
	BEGIN
		SELECT @AssigningUser = Users.FristName + ' ' + Users.LastName 
		FROM 
			tblTask AS Task 
			INNER JOIN [dbo].[tblInstallUsers] AS Users  ON Task.[CreatedBy] = Users.Id
		WHERE TaskId = @TaskId
	END

	-- task's main details
	SELECT Title, [Description], [Status], DueDate,Tasks.[Hours], Tasks.CreatedOn, Tasks.TaskPriority,
		   Tasks.InstallId, Tasks.CreatedBy, @AssigningUser AS AssigningManager ,Tasks.TaskType, Tasks.IsTechTask,
		   STUFF
			(
				(SELECT  CAST(', ' + ttuf.[Attachment] + '@' + ttuf.[AttachmentOriginal] as VARCHAR(max)) AS attachment
				FROM dbo.tblTaskUserFiles ttuf
				WHERE ttuf.TaskId = Tasks.TaskId
				FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)')
				,1
				,2
				,' '
			) AS attachment
	FROM tblTask AS Tasks
	WHERE Tasks.TaskId = @TaskId

	-- task's designation details
	SELECT Designation
	FROM tblTaskDesignations
	WHERE (TaskId = @TaskId)

	-- task's assigned users
	SELECT UserId, TaskId
	FROM tblTaskAssignedUsers
	WHERE (TaskId = @TaskId)

	-- task's notes and attachment information.
	--SELECT	TaskUsers.Id,TaskUsers.UserId, TaskUsers.UserType, TaskUsers.Notes, TaskUsers.UserAcceptance, TaskUsers.UpdatedOn, 
	--	    TaskUsers.[Status], TaskUsers.TaskId, tblInstallUsers.FristName,TaskUsers.UserFirstName, tblInstallUsers.Designation,
	--		(SELECT COUNT(ttuf.[Id]) FROM dbo.tblTaskUserFiles ttuf WHERE ttuf.[TaskUpdateID] = TaskUsers.Id) AS AttachmentCount,
	--		dbo.UDF_GetTaskUpdateAttachments(TaskUsers.Id) AS attachments
	--FROM    
	--	tblTaskUser AS TaskUsers 
	--	LEFT OUTER JOIN tblInstallUsers ON TaskUsers.UserId = tblInstallUsers.Id
	--WHERE (TaskUsers.TaskId = @TaskId) 
	
	-- Description:	Get All Notes along with Attachments.
	-- Modify by :: Aavadesh Patel :: 10.08.2016 23:28

;WITH TaskHistory
AS 
(
	SELECT	
		TaskUsers.Id,
		TaskUsers.UserId, 
		TaskUsers.UserType, 
		TaskUsers.Notes, 
		TaskUsers.UserAcceptance, 
		TaskUsers.UpdatedOn, 
		TaskUsers.[Status], 
		TaskUsers.TaskId, 
		tblInstallUsers.FristName,
		tblInstallUsers.LastName,
		TaskUsers.UserFirstName, 
		tblInstallUsers.Designation,
		tblInstallUsers.Picture,
		(SELECT COUNT(ttuf.[Id]) FROM dbo.tblTaskUserFiles ttuf WHERE ttuf.[TaskUpdateID] = TaskUsers.Id) AS AttachmentCount,
		dbo.UDF_GetTaskUpdateAttachments(TaskUsers.Id) AS attachments,
		'' as AttachmentOriginal , 0 as TaskUserFilesID,
		'' as Attachment , '' as FileType
	FROM    
		tblTaskUser AS TaskUsers 
		LEFT OUTER JOIN tblInstallUsers ON TaskUsers.UserId = tblInstallUsers.Id
	WHERE (TaskUsers.TaskId = @TaskId) AND (TaskUsers.Notes <> '' OR TaskUsers.Notes IS NOT NULL) 
	
	
	Union All 
		
	SELECT	
		tblTaskUserFiles.Id , 
		tblTaskUserFiles.UserId , 
		'' as UserType , 
		'' as Notes , 
		'' as UserAcceptance , 
		tblTaskUserFiles.AttachedFileDate AS UpdatedOn,
		'' as [Status] , 
		tblTaskUserFiles.TaskId , 
		tblInstallUsers.FristName  ,
		tblInstallUsers.LastName,
		tblInstallUsers.FristName as UserFirstName , 
		'' as Designation , 
		tblInstallUsers.Picture,
		'' as AttachmentCount , 
		'' as attachments,
		 tblTaskUserFiles.AttachmentOriginal,
		 tblTaskUserFiles.Id as  TaskUserFilesID,
		 tblTaskUserFiles.Attachment, 
		 tblTaskUserFiles.FileType
	FROM   tblTaskUserFiles   
	LEFT OUTER JOIN tblInstallUsers ON tblInstallUsers.Id = tblTaskUserFiles.UserId
	WHERE (tblTaskUserFiles.TaskId = @TaskId) AND (tblTaskUserFiles.Attachment <> '' OR tblTaskUserFiles.Attachment IS NOT NULL)
)

SELECT * from TaskHistory ORDER BY  UpdatedOn DESC
	
	-- sub tasks
	SELECT Tasks.TaskId, Title, [Description], Tasks.[Status], DueDate,Tasks.[Hours], Tasks.CreatedOn, Tasks.TaskPriority,
		   Tasks.InstallId, Tasks.CreatedBy, @AssigningUser AS AssigningManager , UsersMaster.FristName,
		   Tasks.TaskType,Tasks.TaskPriority, Tasks.IsTechTask,
		   STUFF
			(
				(SELECT  CAST(', ' + ttuf.[Attachment] + '@' + ttuf.[AttachmentOriginal] as VARCHAR(max)) AS attachment
				FROM dbo.tblTaskUserFiles ttuf
				WHERE ttuf.TaskId = Tasks.TaskId
				FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)')
				,1
				,2
				,' '
			) AS attachment
	FROM 
		tblTask AS Tasks LEFT OUTER JOIN
        tblTaskAssignedUsers AS TaskUsers ON Tasks.TaskId = TaskUsers.TaskId LEFT OUTER JOIN
        tblInstallUsers AS UsersMaster ON TaskUsers.UserId = UsersMaster.Id --LEFT OUTER JOIN
		--tblTaskDesignations AS TaskDesignation ON Tasks.TaskId = TaskDesignation.TaskId
	WHERE Tasks.ParentTaskId = @TaskId
    
	-- main task attachments
	SELECT 
		CAST(
				--tuf.[Attachment] + '@' + tuf.[AttachmentOriginal] 
				ISNULL(tuf.[Attachment],'') + '@' + ISNULL(tuf.[AttachmentOriginal],'') 
				AS VARCHAR(MAX)
			) AS attachment,
		ISNULL(u.FirstName,iu.FristName) AS FirstName
	FROM dbo.tblTaskUserFiles tuf
			LEFT JOIN tblUsers u ON tuf.UserId = u.Id --AND tuf.UserType = u.Usertype
			LEFT JOIN tblInstallUsers iu ON tuf.UserId = iu.Id --AND tuf.UserType = u.UserType
	WHERE tuf.TaskId = @TaskId

END
GO

--==========================================================================================================================================================================================

-- Uploaded on live 29 Nov 2016

--==========================================================================================================================================================================================

