/****** Object:  StoredProcedure [dbo].[usp_GetTaskDetails]    Script Date: 30-Nov-16 10:37:04 AM ******/
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
		tblInstallUsers.UserInstallId,
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
		tblInstallUsers.UserInstallId,
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

ALTER PROCEDURE [dbo].[UpdateTaskWorkSpecificationStatusById]
	@Id		BIGINT,
	@AdminStatus BIT = NULL,
	@TechLeadStatus BIT = NULL,
	@OtherUserStatus BIT = NULL,
	@UserId int,
	@IsInstallUser bit
AS
BEGIN
	
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

--=================================================================================================================================================================================================

-- Published on live 12012016 

--=================================================================================================================================================================================================


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
			Tasks.ParentTaskId = @TaskId 
			--AND
			--1 = CASE
			--		-- load records with all status for admin users.
			--		WHEN @Admin = 1 THEN
			--			1
			--		-- load only approved records for non-admin users.
			--		ELSE
			--			CASE
			--				WHEN Tasks.[AdminStatus] = 1 AND Tasks.[TechLeadStatus] = 1 THEN 1
			--				ELSE 0
			--			END
			--	END
    
END
GO

/****** Object:  StoredProcedure [dbo].[uspSearchTasks]    Script Date: 02-Dec-16 8:44:17 AM ******/
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
	@OpenStatus		TINYINT = 1,
    @RequestedStatus	TINYINT = 2,
    @AssignedStatus	TINYINT = 3,
    @InProgressStatus	TINYINT = 4,
    @PendingStatus	TINYINT = 5,
    @ReOpenedStatus	TINYINT = 6,
    @ClosedStatus	TINYINT = 7,
    @SpecsInProgressStatus	TINYINT = 8,
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
						ORDER BY [Status],
							CASE WHEN @SortExpression = 'UserID DESC' THEN Tasks.TaskAssignedUsers END DESC,
							CASE WHEN @SortExpression = 'CreatedOn DESC' THEN Tasks.CreatedOn END DESC,
							CASE WHEN @SortExpression = 'Status ASC' THEN Tasks.[Status] END ASC
					) AS RowNo_Order
				FROM          
					[TaskListView] Tasks
				WHERE 
					[Status] IN (@AssignedStatus,@RequestedStatus)
					
				UNION

				SELECT 
					Tasks.*,
					2 AS SortOrder,
					Row_number() OVER
					(
						ORDER BY [Status], [TaskPriority],
							CASE WHEN @SortExpression = 'UserID DESC' THEN Tasks.TaskAssignedUsers END DESC,
							CASE WHEN @SortExpression = 'CreatedOn DESC' THEN Tasks.CreatedOn END DESC,
							CASE WHEN @SortExpression = 'Status ASC' THEN Tasks.[Status] END ASC
					) AS RowNo_Order
				FROM          
					[TaskListView] Tasks
				WHERE 
					[Status] IN (@OpenStatus) AND ISNULL([TaskPriority],'') <> ''

				UNION

				SELECT 
					Tasks.*,
					3 AS SortOrder,
					Row_number() OVER
					(
						ORDER BY [Status], [TaskPriority],
							CASE WHEN @SortExpression = 'UserID DESC' THEN Tasks.TaskAssignedUsers END DESC,
							CASE WHEN @SortExpression = 'CreatedOn DESC' THEN Tasks.CreatedOn END DESC,
							CASE WHEN @SortExpression = 'Status ASC' THEN Tasks.[Status] END ASC
					) AS RowNo_Order
				FROM          
					[TaskListView] Tasks
				WHERE 
					[Status] IN (@OpenStatus)

				UNION

				SELECT 
					Tasks.*,
					4 AS SortOrder,
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
					5 AS SortOrder,
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


-- =============================================
-- Author:		Yogesh Keraliya
-- Create date: 04/07/2016
-- Description:	Load all sub tasks of a task.
-- =============================================
-- usp_GetSubTasks 10015
ALTER PROCEDURE [dbo].[usp_GetSubTasks] 
(
	@TaskId INT,
	@Admin BIT,
	@SortExpression	VARCHAR(250) = 'Status DESC',
	@OpenStatus		TINYINT = 1,
    @RequestedStatus	TINYINT = 2,
    @AssignedStatus	TINYINT = 3,
    @InProgressStatus	TINYINT = 4,
    @PendingStatus	TINYINT = 5,
    @ReOpenedStatus	TINYINT = 6,
    @ClosedStatus	TINYINT = 7,
    @SpecsInProgressStatus	TINYINT = 8,
    @DeletedStatus	TINYINT = 9
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

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
							CASE WHEN @SortExpression = 'InstallId DESC' THEN Tasks.InstallId END DESC,
							CASE WHEN @SortExpression = 'InstallId ASC' THEN Tasks.InstallId END ASC,
							CASE WHEN @SortExpression = 'TaskId DESC' THEN Tasks.TaskId END DESC,
							CASE WHEN @SortExpression = 'TaskId ASC' THEN Tasks.TaskId END ASC,
							CASE WHEN @SortExpression = 'Title DESC' THEN Tasks.Title END DESC,
							CASE WHEN @SortExpression = 'Title ASC' THEN Tasks.Title END ASC,
							CASE WHEN @SortExpression = 'Description DESC' THEN Tasks.Description END DESC,
							CASE WHEN @SortExpression = 'Description ASC' THEN Tasks.Description END ASC,
							CASE WHEN @SortExpression = 'TaskDesignations DESC' THEN Tasks.TaskDesignations END DESC,
							CASE WHEN @SortExpression = 'TaskDesignations ASC' THEN Tasks.TaskDesignations END ASC,
							CASE WHEN @SortExpression = 'TaskAssignedUsers DESC' THEN Tasks.TaskAssignedUsers END DESC,
							CASE WHEN @SortExpression = 'TaskAssignedUsers ASC' THEN Tasks.TaskAssignedUsers END ASC,
							CASE WHEN @SortExpression = 'Status ASC' THEN Tasks.[Status] END ASC,
							CASE WHEN @SortExpression = 'Status DESC' THEN Tasks.[Status] END DESC
					) AS RowNo_Order
				FROM          
					[TaskListView] Tasks
				WHERE 
					[Status] IN (@AssignedStatus,@RequestedStatus)
					
				UNION

				SELECT 
					Tasks.*,
					2 AS SortOrder,
					Row_number() OVER
					(
						ORDER BY
							CASE WHEN @SortExpression = 'InstallId DESC' THEN Tasks.InstallId END DESC,
							CASE WHEN @SortExpression = 'InstallId ASC' THEN Tasks.InstallId END ASC,
							CASE WHEN @SortExpression = 'TaskId DESC' THEN Tasks.TaskId END DESC,
							CASE WHEN @SortExpression = 'TaskId ASC' THEN Tasks.TaskId END ASC,
							CASE WHEN @SortExpression = 'Title DESC' THEN Tasks.Title END DESC,
							CASE WHEN @SortExpression = 'Title ASC' THEN Tasks.Title END ASC,
							CASE WHEN @SortExpression = 'Description DESC' THEN Tasks.Description END DESC,
							CASE WHEN @SortExpression = 'Description ASC' THEN Tasks.Description END ASC,
							CASE WHEN @SortExpression = 'TaskDesignations DESC' THEN Tasks.TaskDesignations END DESC,
							CASE WHEN @SortExpression = 'TaskDesignations ASC' THEN Tasks.TaskDesignations END ASC,
							CASE WHEN @SortExpression = 'TaskAssignedUsers DESC' THEN Tasks.TaskAssignedUsers END DESC,
							CASE WHEN @SortExpression = 'TaskAssignedUsers ASC' THEN Tasks.TaskAssignedUsers END ASC,
							CASE WHEN @SortExpression = 'Status ASC' THEN Tasks.[Status] END ASC,
							CASE WHEN @SortExpression = 'Status DESC' THEN Tasks.[Status] END DESC
					) AS RowNo_Order
				FROM          
					[TaskListView] Tasks
				WHERE 
					[Status] IN (@InProgressStatus,@PendingStatus,@ReOpenedStatus)
					
				UNION

				SELECT 
					Tasks.*,
					3 AS SortOrder,
					Row_number() OVER
					(
						ORDER BY 
							CASE WHEN @SortExpression = 'InstallId DESC' THEN Tasks.InstallId END DESC,
							CASE WHEN @SortExpression = 'InstallId ASC' THEN Tasks.InstallId END ASC,
							CASE WHEN @SortExpression = 'TaskId DESC' THEN Tasks.TaskId END DESC,
							CASE WHEN @SortExpression = 'TaskId ASC' THEN Tasks.TaskId END ASC,
							CASE WHEN @SortExpression = 'Title DESC' THEN Tasks.Title END DESC,
							CASE WHEN @SortExpression = 'Title ASC' THEN Tasks.Title END ASC,
							CASE WHEN @SortExpression = 'Description DESC' THEN Tasks.Description END DESC,
							CASE WHEN @SortExpression = 'Description ASC' THEN Tasks.Description END ASC,
							CASE WHEN @SortExpression = 'TaskDesignations DESC' THEN Tasks.TaskDesignations END DESC,
							CASE WHEN @SortExpression = 'TaskDesignations ASC' THEN Tasks.TaskDesignations END ASC,
							CASE WHEN @SortExpression = 'TaskAssignedUsers DESC' THEN Tasks.TaskAssignedUsers END DESC,
							CASE WHEN @SortExpression = 'TaskAssignedUsers ASC' THEN Tasks.TaskAssignedUsers END ASC,
							CASE WHEN @SortExpression = 'Status ASC' THEN Tasks.[Status] END ASC,
							CASE WHEN @SortExpression = 'Status DESC' THEN Tasks.[Status] END DESC
					) AS RowNo_Order
				FROM          
					[TaskListView] Tasks
				WHERE 
					[Status] IN (@OpenStatus) AND ISNULL([TaskPriority],'') <> ''

				UNION

				SELECT 
					Tasks.*,
					4 AS SortOrder,
					Row_number() OVER
					(
						ORDER BY 
							CASE WHEN @SortExpression = 'InstallId DESC' THEN Tasks.InstallId END DESC,
							CASE WHEN @SortExpression = 'InstallId ASC' THEN Tasks.InstallId END ASC,
							CASE WHEN @SortExpression = 'TaskId DESC' THEN Tasks.TaskId END DESC,
							CASE WHEN @SortExpression = 'TaskId ASC' THEN Tasks.TaskId END ASC,
							CASE WHEN @SortExpression = 'Title DESC' THEN Tasks.Title END DESC,
							CASE WHEN @SortExpression = 'Title ASC' THEN Tasks.Title END ASC,
							CASE WHEN @SortExpression = 'Description DESC' THEN Tasks.Description END DESC,
							CASE WHEN @SortExpression = 'Description ASC' THEN Tasks.Description END ASC,
							CASE WHEN @SortExpression = 'TaskDesignations DESC' THEN Tasks.TaskDesignations END DESC,
							CASE WHEN @SortExpression = 'TaskDesignations ASC' THEN Tasks.TaskDesignations END ASC,
							CASE WHEN @SortExpression = 'TaskAssignedUsers DESC' THEN Tasks.TaskAssignedUsers END DESC,
							CASE WHEN @SortExpression = 'TaskAssignedUsers ASC' THEN Tasks.TaskAssignedUsers END ASC,
							CASE WHEN @SortExpression = 'Status ASC' THEN Tasks.[Status] END ASC,
							CASE WHEN @SortExpression = 'Status DESC' THEN Tasks.[Status] END DESC
					) AS RowNo_Order
				FROM          
					[TaskListView] Tasks
				WHERE 
					[Status] IN (@OpenStatus, @SpecsInProgressStatus)

				UNION

				SELECT 
					Tasks.*,
					5 AS SortOrder,
					Row_number() OVER
					(
						ORDER BY
							CASE WHEN @SortExpression = 'InstallId DESC' THEN Tasks.InstallId END DESC,
							CASE WHEN @SortExpression = 'InstallId ASC' THEN Tasks.InstallId END ASC,
							CASE WHEN @SortExpression = 'TaskId DESC' THEN Tasks.TaskId END DESC,
							CASE WHEN @SortExpression = 'TaskId ASC' THEN Tasks.TaskId END ASC,
							CASE WHEN @SortExpression = 'Title DESC' THEN Tasks.Title END DESC,
							CASE WHEN @SortExpression = 'Title ASC' THEN Tasks.Title END ASC,
							CASE WHEN @SortExpression = 'Description DESC' THEN Tasks.Description END DESC,
							CASE WHEN @SortExpression = 'Description ASC' THEN Tasks.Description END ASC,
							CASE WHEN @SortExpression = 'TaskDesignations DESC' THEN Tasks.TaskDesignations END DESC,
							CASE WHEN @SortExpression = 'TaskDesignations ASC' THEN Tasks.TaskDesignations END ASC,
							CASE WHEN @SortExpression = 'TaskAssignedUsers DESC' THEN Tasks.TaskAssignedUsers END DESC,
							CASE WHEN @SortExpression = 'TaskAssignedUsers ASC' THEN Tasks.TaskAssignedUsers END ASC,
							CASE WHEN @SortExpression = 'Status ASC' THEN Tasks.[Status] END ASC,
							CASE WHEN @SortExpression = 'Status DESC' THEN Tasks.[Status] END DESC
					) AS RowNo_Order
				FROM          
					[TaskListView] Tasks
				WHERE 
					[Status] = @ClosedStatus

				UNION

				SELECT 
					Tasks.*,
					6 AS SortOrder,
					Row_number() OVER
					(
						ORDER BY
							CASE WHEN @SortExpression = 'InstallId DESC' THEN Tasks.InstallId END DESC,
							CASE WHEN @SortExpression = 'InstallId ASC' THEN Tasks.InstallId END ASC,
							CASE WHEN @SortExpression = 'TaskId DESC' THEN Tasks.TaskId END DESC,
							CASE WHEN @SortExpression = 'TaskId ASC' THEN Tasks.TaskId END ASC,
							CASE WHEN @SortExpression = 'Title DESC' THEN Tasks.Title END DESC,
							CASE WHEN @SortExpression = 'Title ASC' THEN Tasks.Title END ASC,
							CASE WHEN @SortExpression = 'TaskDesignations DESC' THEN Tasks.TaskDesignations END DESC,
							CASE WHEN @SortExpression = 'TaskDesignations ASC' THEN Tasks.TaskDesignations END ASC,
							CASE WHEN @SortExpression = 'TaskAssignedUsers DESC' THEN Tasks.TaskAssignedUsers END DESC,
							CASE WHEN @SortExpression = 'TaskAssignedUsers ASC' THEN Tasks.TaskAssignedUsers END ASC,
							CASE WHEN @SortExpression = 'Status ASC' THEN Tasks.[Status] END ASC,
							CASE WHEN @SortExpression = 'Status DESC' THEN Tasks.[Status] END DESC
					) AS RowNo_Order
				FROM          
					[TaskListView] Tasks
				WHERE 
					[Status] = @DeletedStatus
			) Tasks
		WHERE
			Tasks.ParentTaskId = @TaskId
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

END
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
	@OpenStatus		TINYINT = 1,
    @RequestedStatus	TINYINT = 2,
    @AssignedStatus	TINYINT = 3,
    @InProgressStatus	TINYINT = 4,
    @PendingStatus	TINYINT = 5,
    @ReOpenedStatus	TINYINT = 6,
    @ClosedStatus	TINYINT = 7,
    @SpecsInProgressStatus	TINYINT = 8,
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
							CASE WHEN @SortExpression = 'InstallId DESC' THEN Tasks.InstallId END DESC,
							CASE WHEN @SortExpression = 'InstallId ASC' THEN Tasks.InstallId END ASC,
							CASE WHEN @SortExpression = 'TaskId DESC' THEN Tasks.TaskId END DESC,
							CASE WHEN @SortExpression = 'TaskId ASC' THEN Tasks.TaskId END ASC,
							CASE WHEN @SortExpression = 'Title DESC' THEN Tasks.Title END DESC,
							CASE WHEN @SortExpression = 'Title ASC' THEN Tasks.Title END ASC,
							CASE WHEN @SortExpression = 'Description DESC' THEN Tasks.Description END DESC,
							CASE WHEN @SortExpression = 'Description ASC' THEN Tasks.Description END ASC,
							CASE WHEN @SortExpression = 'TaskDesignations DESC' THEN Tasks.TaskDesignations END DESC,
							CASE WHEN @SortExpression = 'TaskDesignations ASC' THEN Tasks.TaskDesignations END ASC,
							CASE WHEN @SortExpression = 'TaskAssignedUsers DESC' THEN Tasks.TaskAssignedUsers END DESC,
							CASE WHEN @SortExpression = 'TaskAssignedUsers ASC' THEN Tasks.TaskAssignedUsers END ASC,
							CASE WHEN @SortExpression = 'Status ASC' THEN Tasks.[Status] END ASC,
							CASE WHEN @SortExpression = 'Status DESC' THEN Tasks.[Status] END DESC
					) AS RowNo_Order
				FROM          
					[TaskListView] Tasks
				WHERE 
					[Status] IN (@AssignedStatus,@RequestedStatus)
					
				UNION

				SELECT 
					Tasks.*,
					2 AS SortOrder,
					Row_number() OVER
					(
						ORDER BY
							CASE WHEN @SortExpression = 'InstallId DESC' THEN Tasks.InstallId END DESC,
							CASE WHEN @SortExpression = 'InstallId ASC' THEN Tasks.InstallId END ASC,
							CASE WHEN @SortExpression = 'TaskId DESC' THEN Tasks.TaskId END DESC,
							CASE WHEN @SortExpression = 'TaskId ASC' THEN Tasks.TaskId END ASC,
							CASE WHEN @SortExpression = 'Title DESC' THEN Tasks.Title END DESC,
							CASE WHEN @SortExpression = 'Title ASC' THEN Tasks.Title END ASC,
							CASE WHEN @SortExpression = 'Description DESC' THEN Tasks.Description END DESC,
							CASE WHEN @SortExpression = 'Description ASC' THEN Tasks.Description END ASC,
							CASE WHEN @SortExpression = 'TaskDesignations DESC' THEN Tasks.TaskDesignations END DESC,
							CASE WHEN @SortExpression = 'TaskDesignations ASC' THEN Tasks.TaskDesignations END ASC,
							CASE WHEN @SortExpression = 'TaskAssignedUsers DESC' THEN Tasks.TaskAssignedUsers END DESC,
							CASE WHEN @SortExpression = 'TaskAssignedUsers ASC' THEN Tasks.TaskAssignedUsers END ASC,
							CASE WHEN @SortExpression = 'Status ASC' THEN Tasks.[Status] END ASC,
							CASE WHEN @SortExpression = 'Status DESC' THEN Tasks.[Status] END DESC
					) AS RowNo_Order
				FROM          
					[TaskListView] Tasks
				WHERE 
					[Status] IN (@InProgressStatus,@PendingStatus,@ReOpenedStatus)
					
				UNION

				SELECT 
					Tasks.*,
					3 AS SortOrder,
					Row_number() OVER
					(
						ORDER BY 
							CASE WHEN @SortExpression = 'InstallId DESC' THEN Tasks.InstallId END DESC,
							CASE WHEN @SortExpression = 'InstallId ASC' THEN Tasks.InstallId END ASC,
							CASE WHEN @SortExpression = 'TaskId DESC' THEN Tasks.TaskId END DESC,
							CASE WHEN @SortExpression = 'TaskId ASC' THEN Tasks.TaskId END ASC,
							CASE WHEN @SortExpression = 'Title DESC' THEN Tasks.Title END DESC,
							CASE WHEN @SortExpression = 'Title ASC' THEN Tasks.Title END ASC,
							CASE WHEN @SortExpression = 'Description DESC' THEN Tasks.Description END DESC,
							CASE WHEN @SortExpression = 'Description ASC' THEN Tasks.Description END ASC,
							CASE WHEN @SortExpression = 'TaskDesignations DESC' THEN Tasks.TaskDesignations END DESC,
							CASE WHEN @SortExpression = 'TaskDesignations ASC' THEN Tasks.TaskDesignations END ASC,
							CASE WHEN @SortExpression = 'TaskAssignedUsers DESC' THEN Tasks.TaskAssignedUsers END DESC,
							CASE WHEN @SortExpression = 'TaskAssignedUsers ASC' THEN Tasks.TaskAssignedUsers END ASC,
							CASE WHEN @SortExpression = 'Status ASC' THEN Tasks.[Status] END ASC,
							CASE WHEN @SortExpression = 'Status DESC' THEN Tasks.[Status] END DESC
					) AS RowNo_Order
				FROM          
					[TaskListView] Tasks
				WHERE 
					[Status] IN (@OpenStatus) AND ISNULL([TaskPriority],'') <> ''

				UNION

				SELECT 
					Tasks.*,
					4 AS SortOrder,
					Row_number() OVER
					(
						ORDER BY 
							CASE WHEN @SortExpression = 'InstallId DESC' THEN Tasks.InstallId END DESC,
							CASE WHEN @SortExpression = 'InstallId ASC' THEN Tasks.InstallId END ASC,
							CASE WHEN @SortExpression = 'TaskId DESC' THEN Tasks.TaskId END DESC,
							CASE WHEN @SortExpression = 'TaskId ASC' THEN Tasks.TaskId END ASC,
							CASE WHEN @SortExpression = 'Title DESC' THEN Tasks.Title END DESC,
							CASE WHEN @SortExpression = 'Title ASC' THEN Tasks.Title END ASC,
							CASE WHEN @SortExpression = 'Description DESC' THEN Tasks.Description END DESC,
							CASE WHEN @SortExpression = 'Description ASC' THEN Tasks.Description END ASC,
							CASE WHEN @SortExpression = 'TaskDesignations DESC' THEN Tasks.TaskDesignations END DESC,
							CASE WHEN @SortExpression = 'TaskDesignations ASC' THEN Tasks.TaskDesignations END ASC,
							CASE WHEN @SortExpression = 'TaskAssignedUsers DESC' THEN Tasks.TaskAssignedUsers END DESC,
							CASE WHEN @SortExpression = 'TaskAssignedUsers ASC' THEN Tasks.TaskAssignedUsers END ASC,
							CASE WHEN @SortExpression = 'Status ASC' THEN Tasks.[Status] END ASC,
							CASE WHEN @SortExpression = 'Status DESC' THEN Tasks.[Status] END DESC
					) AS RowNo_Order
				FROM          
					[TaskListView] Tasks
				WHERE 
					[Status] IN (@OpenStatus, @SpecsInProgressStatus)

				UNION

				SELECT 
					Tasks.*,
					5 AS SortOrder,
					Row_number() OVER
					(
						ORDER BY
							CASE WHEN @SortExpression = 'InstallId DESC' THEN Tasks.InstallId END DESC,
							CASE WHEN @SortExpression = 'InstallId ASC' THEN Tasks.InstallId END ASC,
							CASE WHEN @SortExpression = 'TaskId DESC' THEN Tasks.TaskId END DESC,
							CASE WHEN @SortExpression = 'TaskId ASC' THEN Tasks.TaskId END ASC,
							CASE WHEN @SortExpression = 'Title DESC' THEN Tasks.Title END DESC,
							CASE WHEN @SortExpression = 'Title ASC' THEN Tasks.Title END ASC,
							CASE WHEN @SortExpression = 'Description DESC' THEN Tasks.Description END DESC,
							CASE WHEN @SortExpression = 'Description ASC' THEN Tasks.Description END ASC,
							CASE WHEN @SortExpression = 'TaskDesignations DESC' THEN Tasks.TaskDesignations END DESC,
							CASE WHEN @SortExpression = 'TaskDesignations ASC' THEN Tasks.TaskDesignations END ASC,
							CASE WHEN @SortExpression = 'TaskAssignedUsers DESC' THEN Tasks.TaskAssignedUsers END DESC,
							CASE WHEN @SortExpression = 'TaskAssignedUsers ASC' THEN Tasks.TaskAssignedUsers END ASC,
							CASE WHEN @SortExpression = 'Status ASC' THEN Tasks.[Status] END ASC,
							CASE WHEN @SortExpression = 'Status DESC' THEN Tasks.[Status] END DESC
					) AS RowNo_Order
				FROM          
					[TaskListView] Tasks
				WHERE 
					[Status] = @ClosedStatus

				UNION

				SELECT 
					Tasks.*,
					6 AS SortOrder,
					Row_number() OVER
					(
						ORDER BY
							CASE WHEN @SortExpression = 'InstallId DESC' THEN Tasks.InstallId END DESC,
							CASE WHEN @SortExpression = 'InstallId ASC' THEN Tasks.InstallId END ASC,
							CASE WHEN @SortExpression = 'TaskId DESC' THEN Tasks.TaskId END DESC,
							CASE WHEN @SortExpression = 'TaskId ASC' THEN Tasks.TaskId END ASC,
							CASE WHEN @SortExpression = 'Title DESC' THEN Tasks.Title END DESC,
							CASE WHEN @SortExpression = 'Title ASC' THEN Tasks.Title END ASC,
							CASE WHEN @SortExpression = 'TaskDesignations DESC' THEN Tasks.TaskDesignations END DESC,
							CASE WHEN @SortExpression = 'TaskDesignations ASC' THEN Tasks.TaskDesignations END ASC,
							CASE WHEN @SortExpression = 'TaskAssignedUsers DESC' THEN Tasks.TaskAssignedUsers END DESC,
							CASE WHEN @SortExpression = 'TaskAssignedUsers ASC' THEN Tasks.TaskAssignedUsers END ASC,
							CASE WHEN @SortExpression = 'Status ASC' THEN Tasks.[Status] END ASC,
							CASE WHEN @SortExpression = 'Status DESC' THEN Tasks.[Status] END DESC
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

--=================================================================================================================================================================================================

-- Published on live 12022016 

--=================================================================================================================================================================================================

/****** Object:  StoredProcedure [dbo].[usp_GetSubTasks]    Script Date: 05-Dec-16 9:05:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh Keraliya
-- Create date: 04/07/2016
-- Description:	Load all sub tasks of a task.
-- =============================================
-- usp_GetSubTasks 115, 1, 'Description DESC'
ALTER PROCEDURE [dbo].[usp_GetSubTasks] 
(
	@TaskId INT,
	@Admin BIT,
	@SortExpression	VARCHAR(250) = 'CreatedOn DESC',
	@OpenStatus		TINYINT = 1,
    @RequestedStatus	TINYINT = 2,
    @AssignedStatus	TINYINT = 3,
    @InProgressStatus	TINYINT = 4,
    @PendingStatus	TINYINT = 5,
    @ReOpenedStatus	TINYINT = 6,
    @ClosedStatus	TINYINT = 7,
    @SpecsInProgressStatus	TINYINT = 8,
    @DeletedStatus	TINYINT = 9
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	;WITH 
	
	Tasklist AS
	(	
		SELECT
			Tasks.*,
			Row_number() OVER
			(
				ORDER BY
					CASE WHEN @SortExpression = 'InstallId DESC' THEN Tasks.InstallId END DESC,
					CASE WHEN @SortExpression = 'InstallId ASC' THEN Tasks.InstallId END ASC,
					CASE WHEN @SortExpression = 'TaskId DESC' THEN Tasks.TaskId END DESC,
					CASE WHEN @SortExpression = 'TaskId ASC' THEN Tasks.TaskId END ASC,
					CASE WHEN @SortExpression = 'Title DESC' THEN Tasks.Title END DESC,
					CASE WHEN @SortExpression = 'Title ASC' THEN Tasks.Title END ASC,
					CASE WHEN @SortExpression = 'Description DESC' THEN Tasks.Description END DESC,
					CASE WHEN @SortExpression = 'Description ASC' THEN Tasks.Description END ASC,
					CASE WHEN @SortExpression = 'TaskDesignations DESC' THEN Tasks.TaskDesignations END DESC,
					CASE WHEN @SortExpression = 'TaskDesignations ASC' THEN Tasks.TaskDesignations END ASC,
					CASE WHEN @SortExpression = 'TaskAssignedUsers DESC' THEN Tasks.TaskAssignedUsers END DESC,
					CASE WHEN @SortExpression = 'TaskAssignedUsers ASC' THEN Tasks.TaskAssignedUsers END ASC,
					CASE WHEN @SortExpression = 'Status ASC' THEN Tasks.StatusOrder END ASC,
					CASE WHEN @SortExpression = 'Status DESC' THEN Tasks.StatusOrder END DESC,
					CASE WHEN @SortExpression = 'CreatedOn DESC' THEN Tasks.CreatedOn END DESC,
					CASE WHEN @SortExpression = 'CreatedOn ASC' THEN Tasks.CreatedOn END ASC
			) AS RowNo_Order
		FROM
			(
				SELECT 
					Tasks.*,
					CASE Tasks.[Status]
						WHEN @AssignedStatus THEN 1
						WHEN @RequestedStatus THEN 1

						WHEN @InProgressStatus THEN 2
						WHEN @PendingStatus THEN 2
						WHEN @ReOpenedStatus THEN 2

						WHEN @OpenStatus THEN 
							CASE 
								WHEN ISNULL([TaskPriority],'') <> '' THEN 3
								ELSE 4
							END

						WHEN @SpecsInProgressStatus THEN 4

						WHEN @ClosedStatus THEN 5

						WHEN @DeletedStatus THEN 6

						ELSE 7

					END AS StatusOrder
				FROM 
					[TaskListView] Tasks
				WHERE
					Tasks.ParentTaskId = @TaskId
			) Tasks
	)
	
	-- get records
	SELECT * 
	FROM Tasklist 

END
GO


/****** Object:  StoredProcedure [dbo].[uspSearchTasks]    Script Date: 05-Dec-16 10:20:25 AM ******/
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
	@OpenStatus		TINYINT = 1,
    @RequestedStatus	TINYINT = 2,
    @AssignedStatus	TINYINT = 3,
    @InProgressStatus	TINYINT = 4,
    @PendingStatus	TINYINT = 5,
    @ReOpenedStatus	TINYINT = 6,
    @ClosedStatus	TINYINT = 7,
    @SpecsInProgressStatus	TINYINT = 8,
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
			Tasks.*,
			Row_number() OVER
			(
				ORDER BY
					CASE WHEN @SortExpression = 'InstallId DESC' THEN Tasks.InstallId END DESC,
					CASE WHEN @SortExpression = 'InstallId ASC' THEN Tasks.InstallId END ASC,
					CASE WHEN @SortExpression = 'TaskId DESC' THEN Tasks.TaskId END DESC,
					CASE WHEN @SortExpression = 'TaskId ASC' THEN Tasks.TaskId END ASC,
					CASE WHEN @SortExpression = 'Title DESC' THEN Tasks.Title END DESC,
					CASE WHEN @SortExpression = 'Title ASC' THEN Tasks.Title END ASC,
					CASE WHEN @SortExpression = 'Description DESC' THEN Tasks.Description END DESC,
					CASE WHEN @SortExpression = 'Description ASC' THEN Tasks.Description END ASC,
					CASE WHEN @SortExpression = 'TaskDesignations DESC' THEN Tasks.TaskDesignations END DESC,
					CASE WHEN @SortExpression = 'TaskDesignations ASC' THEN Tasks.TaskDesignations END ASC,
					CASE WHEN @SortExpression = 'TaskAssignedUsers DESC' THEN Tasks.TaskAssignedUsers END DESC,
					CASE WHEN @SortExpression = 'TaskAssignedUsers ASC' THEN Tasks.TaskAssignedUsers END ASC,
					CASE WHEN @SortExpression = 'Status ASC' THEN Tasks.StatusOrder END ASC,
					CASE WHEN @SortExpression = 'Status DESC' THEN Tasks.StatusOrder END DESC,
					CASE WHEN @SortExpression = 'CreatedOn DESC' THEN Tasks.CreatedOn END DESC,
					CASE WHEN @SortExpression = 'CreatedOn ASC' THEN Tasks.CreatedOn END ASC
			) AS RowNo_Order
		FROM
			(
				SELECT 
					Tasks.*,
					CASE Tasks.[Status]
						WHEN @AssignedStatus THEN 1
						WHEN @RequestedStatus THEN 1

						WHEN @InProgressStatus THEN 2
						WHEN @PendingStatus THEN 2
						WHEN @ReOpenedStatus THEN 2

						WHEN @OpenStatus THEN 
							CASE 
								WHEN ISNULL([TaskPriority],'') <> '' THEN 3
								ELSE 4
							END

						WHEN @SpecsInProgressStatus THEN 4

						WHEN @ClosedStatus THEN 5

						WHEN @DeletedStatus THEN 6

						ELSE 7

					END AS StatusOrder
				FROM 
					[TaskListView] Tasks
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
	)
	
	-- get records
	SELECT * 
	FROM Tasklist 
	WHERE  
		RowNo_Order BETWEEN (@PageIndex - 1) * @PageSize + 1 AND 
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


CREATE TABLE [dbo].[tblTaskApprovals](
	[Id] [bigint] IDENTITY(1,1) PRIMARY KEY,
	[TaskId] [bigint] NOT NULL REFERENCES tblTask,
	[EstimatedHours] VARCHAR(5) NOT NULL,
	[Description] [text] NULL,
	[UserId] INT NULL,
	[IsInstallUser] BIT NULL,
	[DateCreated] [datetime] NOT NULL,
	[DateUpdated] [datetime] NOT NULL)
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh
-- Create date: 06 Dec 16
-- Description:	Insert Task approval.
-- =============================================
CREATE PROCEDURE [dbo].[InsertTaskApproval]
	@TaskId bigint,
	@EstimatedHours varchar(5),
	@Description text,
	@UserId int,
	@IsInstallUser bit
AS
BEGIN

	INSERT INTO [dbo].[tblTaskApprovals]
           ([TaskId]
           ,[EstimatedHours]
           ,[Description]
           ,[UserId]
           ,[IsInstallUser]
           ,[DateCreated]
           ,[DateUpdated])
     VALUES
           (@TaskId
           ,@EstimatedHours
           ,@Description
           ,@UserId
           ,@IsInstallUser
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
-- Create date: 06 Dec 16
-- Description:	Update Task approval.
-- =============================================
CREATE PROCEDURE [dbo].[UpdateTaskApproval]
	@Id		bigint,
	@TaskId bigint,
	@EstimatedHours VARCHAR(5),
	@Description text,
	@UserId int,
	@IsInstallUser bit
AS
BEGIN

	UPDATE [dbo].[tblTaskApprovals]
    SET
	    [TaskId] = @TaskId
       ,[EstimatedHours] = @EstimatedHours
       ,[Description] = @Description
       ,[UserId] = @UserId
       ,[IsInstallUser] = @IsInstallUser
       ,[DateUpdated] = GETDATE()
     WHERE
		Id = @Id

END
GO



SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[UDF_GetIsAdminUser]
(
	@Designation VARCHAR(50)
)
RETURNS BIT
AS
BEGIN
	declare @IsAdmin BIT

	SELECT 
		@IsAdmin = CASE UPPER(@Designation)
			WHEN 'ADMIN' THEN 1
			WHEN 'OFFICE MANAGER' THEN 1
			WHEN 'SALES MANAGER' THEN 1
			WHEN 'ITLEAD' THEN 1
			WHEN 'FOREMAN' THEN 1
			ELSE 0 
		END

	RETURN @IsAdmin
END
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[UDF_GetIsAdminOrITLeadUser]
(
	@Designation VARCHAR(50)
)
RETURNS BIT
AS
BEGIN
	declare @IsAdmin BIT

	SELECT 
		@IsAdmin = CASE UPPER(@Designation)
			WHEN 'ADMIN' THEN 1
			WHEN 'ITLEAD' THEN 1
			ELSE 0 
		END

	RETURN @IsAdmin
END
GO




SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TaskApprovalsView] as

	SELECT
			s.*,
			
			u.Username AS Username,
			u.FirstName AS UserFirstName,
			u.LastName AS UserLastName,
			u.Email AS UserEmail,
			u.Designation AS UserDesignation,
			[dbo].[UDF_GetIsAdminOrITLeadUser](u.Designation) AS IsAdminOrITLead

	FROM tblTaskApprovals s
			OUTER APPLY
			(
				SELECT TOP 1 iu.Id,iu.FristName AS Username, iu.FristName AS FirstName, iu.LastName, iu.Email, iu.Designation
				FROM tblInstallUsers iu
				WHERE iu.Id = s.UserId AND s.IsInstallUser = 1
			
				UNION

				SELECT TOP 1 u.Id,u.Username AS Username, u.FirstName AS FirstName, u.LastName, u.Email, u.Designation
				FROM tblUsers u
				WHERE u.Id = s.UserId AND s.IsInstallUser = 0
			) AS u

GO



/****** Object:  StoredProcedure [dbo].[usp_GetSubTasks]    Script Date: 06-Dec-16 11:30:16 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Yogesh Keraliya
-- Create date: 04/07/2016
-- Description:	Load all sub tasks of a task.
-- =============================================
-- usp_GetSubTasks 115, 1, 'Description DESC'
ALTER PROCEDURE [dbo].[usp_GetSubTasks] 
(
	@TaskId INT,
	@Admin BIT,
	@SortExpression	VARCHAR(250) = 'CreatedOn DESC',
	@OpenStatus		TINYINT = 1,
    @RequestedStatus	TINYINT = 2,
    @AssignedStatus	TINYINT = 3,
    @InProgressStatus	TINYINT = 4,
    @PendingStatus	TINYINT = 5,
    @ReOpenedStatus	TINYINT = 6,
    @ClosedStatus	TINYINT = 7,
    @SpecsInProgressStatus	TINYINT = 8,
    @DeletedStatus	TINYINT = 9
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	;WITH 
	
	Tasklist AS
	(	
		SELECT
			Tasks.*,
			Row_number() OVER
			(
				ORDER BY
					CASE WHEN @SortExpression = 'InstallId DESC' THEN Tasks.InstallId END DESC,
					CASE WHEN @SortExpression = 'InstallId ASC' THEN Tasks.InstallId END ASC,
					CASE WHEN @SortExpression = 'TaskId DESC' THEN Tasks.TaskId END DESC,
					CASE WHEN @SortExpression = 'TaskId ASC' THEN Tasks.TaskId END ASC,
					CASE WHEN @SortExpression = 'Title DESC' THEN Tasks.Title END DESC,
					CASE WHEN @SortExpression = 'Title ASC' THEN Tasks.Title END ASC,
					CASE WHEN @SortExpression = 'Description DESC' THEN Tasks.Description END DESC,
					CASE WHEN @SortExpression = 'Description ASC' THEN Tasks.Description END ASC,
					CASE WHEN @SortExpression = 'TaskDesignations DESC' THEN Tasks.TaskDesignations END DESC,
					CASE WHEN @SortExpression = 'TaskDesignations ASC' THEN Tasks.TaskDesignations END ASC,
					CASE WHEN @SortExpression = 'TaskAssignedUsers DESC' THEN Tasks.TaskAssignedUsers END DESC,
					CASE WHEN @SortExpression = 'TaskAssignedUsers ASC' THEN Tasks.TaskAssignedUsers END ASC,
					CASE WHEN @SortExpression = 'Status ASC' THEN Tasks.StatusOrder END ASC,
					CASE WHEN @SortExpression = 'Status DESC' THEN Tasks.StatusOrder END DESC,
					CASE WHEN @SortExpression = 'CreatedOn DESC' THEN Tasks.CreatedOn END DESC,
					CASE WHEN @SortExpression = 'CreatedOn ASC' THEN Tasks.CreatedOn END ASC
			) AS RowNo_Order
		FROM
			(
				SELECT 
					Tasks.*,
					CASE Tasks.[Status]
						WHEN @AssignedStatus THEN 1
						WHEN @RequestedStatus THEN 1

						WHEN @InProgressStatus THEN 2
						WHEN @PendingStatus THEN 2
						WHEN @ReOpenedStatus THEN 2

						WHEN @OpenStatus THEN 
							CASE 
								WHEN ISNULL([TaskPriority],'') <> '' THEN 3
								ELSE 4
							END

						WHEN @SpecsInProgressStatus THEN 4

						WHEN @ClosedStatus THEN 5

						WHEN @DeletedStatus THEN 6

						ELSE 7

					END AS StatusOrder,
					TaskApprovals.Id AS TaskApprovalId,
					TaskApprovals.EstimatedHours AS TaskApprovalEstimatedHours,
					TaskApprovals.Description AS TaskApprovalDescription,
					TaskApprovals.UserId AS TaskApprovalUserId,
					TaskApprovals.IsInstallUser AS TaskApprovalIsInstallUser
				FROM 
					[TaskListView] Tasks 
						LEFT JOIN [TaskApprovalsView] TaskApprovals ON Tasks.TaskId = TaskApprovals.TaskId 
																	AND TaskApprovals.IsAdminOrITLead = @Admin
				WHERE
					Tasks.ParentTaskId = @TaskId
			) Tasks
	)
	
	-- get records
	SELECT * 
	FROM Tasklist 

END

GO


/****** Object:  StoredProcedure [dbo].[usp_GetSubTasks]    Script Date: 06-Dec-16 11:30:16 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Yogesh Keraliya
-- Create date: 04/07/2016
-- Description:	Load all sub tasks of a task.
-- =============================================
-- usp_GetSubTasks 115, 1, 'Description DESC'
ALTER PROCEDURE [dbo].[usp_GetSubTasks] 
(
	@TaskId INT,
	@Admin BIT,
	@SortExpression	VARCHAR(250) = 'CreatedOn DESC',
	@OpenStatus		TINYINT = 1,
    @RequestedStatus	TINYINT = 2,
    @AssignedStatus	TINYINT = 3,
    @InProgressStatus	TINYINT = 4,
    @PendingStatus	TINYINT = 5,
    @ReOpenedStatus	TINYINT = 6,
    @ClosedStatus	TINYINT = 7,
    @SpecsInProgressStatus	TINYINT = 8,
    @DeletedStatus	TINYINT = 9
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	;WITH 
	
	Tasklist AS
	(	
		SELECT
			Tasks.*,
			(SELECT EstimatedHours 
				FROM [TaskApprovalsView] TaskApprovals 
				WHERE Tasks.TaskId = TaskApprovals.TaskId AND TaskApprovals.IsAdminOrITLead = 1) AS AdminOrITLeadEstimatedHours,
			(SELECT EstimatedHours 
				FROM [TaskApprovalsView] TaskApprovals 
				WHERE Tasks.TaskId = TaskApprovals.TaskId AND TaskApprovals.IsAdminOrITLead = 0) AS UserEstimatedHours,
			Row_number() OVER
			(
				ORDER BY
					CASE WHEN @SortExpression = 'InstallId DESC' THEN Tasks.InstallId END DESC,
					CASE WHEN @SortExpression = 'InstallId ASC' THEN Tasks.InstallId END ASC,
					CASE WHEN @SortExpression = 'TaskId DESC' THEN Tasks.TaskId END DESC,
					CASE WHEN @SortExpression = 'TaskId ASC' THEN Tasks.TaskId END ASC,
					CASE WHEN @SortExpression = 'Title DESC' THEN Tasks.Title END DESC,
					CASE WHEN @SortExpression = 'Title ASC' THEN Tasks.Title END ASC,
					CASE WHEN @SortExpression = 'Description DESC' THEN Tasks.Description END DESC,
					CASE WHEN @SortExpression = 'Description ASC' THEN Tasks.Description END ASC,
					CASE WHEN @SortExpression = 'TaskDesignations DESC' THEN Tasks.TaskDesignations END DESC,
					CASE WHEN @SortExpression = 'TaskDesignations ASC' THEN Tasks.TaskDesignations END ASC,
					CASE WHEN @SortExpression = 'TaskAssignedUsers DESC' THEN Tasks.TaskAssignedUsers END DESC,
					CASE WHEN @SortExpression = 'TaskAssignedUsers ASC' THEN Tasks.TaskAssignedUsers END ASC,
					CASE WHEN @SortExpression = 'Status ASC' THEN Tasks.StatusOrder END ASC,
					CASE WHEN @SortExpression = 'Status DESC' THEN Tasks.StatusOrder END DESC,
					CASE WHEN @SortExpression = 'CreatedOn DESC' THEN Tasks.CreatedOn END DESC,
					CASE WHEN @SortExpression = 'CreatedOn ASC' THEN Tasks.CreatedOn END ASC
			) AS RowNo_Order
		FROM
			(
				SELECT 
					Tasks.*,
					CASE Tasks.[Status]
						WHEN @AssignedStatus THEN 1
						WHEN @RequestedStatus THEN 1

						WHEN @InProgressStatus THEN 2
						WHEN @PendingStatus THEN 2
						WHEN @ReOpenedStatus THEN 2

						WHEN @OpenStatus THEN 
							CASE 
								WHEN ISNULL([TaskPriority],'') <> '' THEN 3
								ELSE 4
							END

						WHEN @SpecsInProgressStatus THEN 4

						WHEN @ClosedStatus THEN 5

						WHEN @DeletedStatus THEN 6

						ELSE 7

					END AS StatusOrder,
					TaskApprovals.Id AS TaskApprovalId,
					TaskApprovals.EstimatedHours AS TaskApprovalEstimatedHours,
					TaskApprovals.Description AS TaskApprovalDescription,
					TaskApprovals.UserId AS TaskApprovalUserId,
					TaskApprovals.IsInstallUser AS TaskApprovalIsInstallUser
				FROM 
					[TaskListView] Tasks 
						LEFT JOIN [TaskApprovalsView] TaskApprovals ON Tasks.TaskId = TaskApprovals.TaskId AND TaskApprovals.IsAdminOrITLead = @Admin
				WHERE
					Tasks.ParentTaskId = @TaskId
			) Tasks
	)
	
	-- get records
	SELECT * 
	FROM Tasklist 

END

GO

