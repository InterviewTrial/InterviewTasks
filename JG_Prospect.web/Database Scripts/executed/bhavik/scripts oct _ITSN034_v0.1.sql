USE [JGBS]
GO
 
---------- ADDMIN  NOW COL TO TABLE tblTask ----------
 
ALTER TABLE tblTask
ADD IsTechTask bit

GO
 
UPDATE tblTask SET IsTechTask = 0
GO

---------- Creating sp SP_GetAllActiveTechTask ----------

GO
/****** Object:  StoredProcedure [dbo].[SP_GetAllActiveTechTask]    Script Date: 10/6/2016 1:07:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Bhavik J. Vaishnani
-- Create date: 22-Sep-2016
-- Update date: 4-Oct-2016
-- Description:	Will populate List of TechTask
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetAllActiveTechTask] 
	-- Add the parameters for the stored procedure here	  
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT TaskId, Title
		FROM tblTask  
		WHERE  IsTechTask = 1
		--AND Status = 1  // As per Task ID#: ITSN034 (I - d)
		
END



---------- UPDATING sp SP_SaveOrDeleteTask ----------



GO
/****** Object:  StoredProcedure [dbo].[SP_SaveOrDeleteTask]    Script Date: 10/6/2016 1:12:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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
		INSERT INTO tblTask (Title,[Description],[Status],DueDate,[Hours],CreatedBy,CreatedOn,IsDeleted,InstallId,ParentTaskId,TaskType,TaskPriority,IsTechTask)
		VALUES(@Title,@Description,@Status,@DueDate,@Hours,@CreatedBy,GETDATE(),0,@InstallId,@ParentTaskId,@TaskType,@TaskPriority,@IsTechTask)  
  
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


---------- UPDATING sp usp_GetTaskDetails ----------


GO
/****** Object:  StoredProcedure [dbo].[usp_GetTaskDetails]    Script Date: 10/6/2016 1:14:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yogesh Keraliya
-- Updated By Date : 22-Sep-2016 - Added Tasks.IsTechTask COL
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
	SELECT	TaskUsers.Id,TaskUsers.UserId, TaskUsers.UserType, TaskUsers.Notes, TaskUsers.UserAcceptance, TaskUsers.UpdatedOn, 
		    TaskUsers.[Status], TaskUsers.TaskId, tblInstallUsers.FristName,TaskUsers.UserFirstName, tblInstallUsers.Designation,
			(SELECT COUNT(ttuf.[Id]) FROM dbo.tblTaskUserFiles ttuf WHERE ttuf.[TaskUpdateID] = TaskUsers.Id) AS AttachmentCount,
			dbo.UDF_GetTaskUpdateAttachments(TaskUsers.Id) AS attachments
	FROM    
		tblTaskUser AS TaskUsers 
		LEFT OUTER JOIN tblInstallUsers ON TaskUsers.UserId = tblInstallUsers.Id
	WHERE (TaskUsers.TaskId = @TaskId) 

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
				ISNULL(tuf.[Attachment],'') + '@' + ISNULL(tuf.[AttachmentOriginal],'') 
				AS VARCHAR(MAX)
			) AS attachment,
		ISNULL(u.FirstName,iu.FristName) AS FirstName
	FROM dbo.tblTaskUserFiles tuf
			LEFT JOIN tblUsers u ON tuf.UserId = u.Id --AND tuf.UserType = u.Usertype
			LEFT JOIN tblInstallUsers iu ON tuf.UserId = iu.Id --AND tuf.UserType = u.UserType
	WHERE tuf.TaskId = @TaskId

END


-------- Creating SP sp_Get_TaskAssignByUserID -------------


GO
/****** Object:  StoredProcedure [dbo].[sp_Get_TaskAssignByUserID]    Script Date: 10/6/2016 1:06:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:  Bhavik Vaishnani
-- Create date: 10/3/2016
-- Description: get tech task list from given user id.
-- =============================================
CREATE PROCEDURE [dbo].[sp_Get_TaskAssignByUserID]
 
   @UserId int
 
AS
BEGIN
 
 SET NOCOUNT ON;
     
 SELECT tblTaskAssignedUsers.TaskId ,Title 
	FROM tblTaskAssignedUsers , tblTask 
	
	WHERE 
       tblTaskAssignedUsers.TaskId = tblTask.TaskId 
	   AND UserId= @UserId
	    
END


-------- Create SP usp_InsertTaskAssignedToMultipleUsers --------

  
/****** Object:  StoredProcedure [dbo].[usp_InsertTaskAssignedToMultipleUsers]    Script Date: 10/6/2016 1:06:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Bhavik Vaishnani
-- Create date: 10/3/2016
-- Description:	This will insert assigned users to task
-- =============================================
CREATE PROCEDURE [dbo].[usp_InsertTaskAssignedToMultipleUsers] 
(	
	@TaskId int , 
	@UserIds VARCHAR(15) 
)
AS
BEGIN
	
-- insert users, which are not already present in database but are provided in new user list.
INSERT INTO tblTaskAssignedUsers (TaskId, UserId)
SELECT @TaskId , CAST(ss.Item AS BIGINT) 
FROM dbo.SplitString(@UserIds,',') ss 
WHERE NOT EXISTS(
					SELECT CAST(ttau.UserId as varchar) 
					FROM dbo.tblTaskAssignedUsers ttau 
					WHERE ttau.UserId = CAST(ss.Item AS bigint) AND ttau.TaskId = @TaskId
				)

END




-------- Create SP Sp_ReSchedule_Interivew --------

GO
/****** Object:  StoredProcedure [dbo].[Sp_ReSchedule_Interivew]    Script Date: 10/6/2016 1:21:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Bhavik J Vaishnani
-- Create date: 4-Oct-2016
-- Description:	Will Re schedule Interivew
-- =============================================
CREATE PROCEDURE [dbo].[Sp_ReSchedule_Interivew] 
	-- Add the parameters for the stored procedure here
	@ApplicantId int = 0,
	@ReSheduleDate varchar(50) = '',
	@ReSheduleTime varchar(50) = '',
	@ReSheduleByUserId int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    UPDATE [dbo].[tblInstallUsers]
	   SET 
		  RejectionDate = @ReSheduleDate
		  ,InterviewTime = @ReSheduleTime
		  
	   WHERE Id = @ApplicantId

	   SELECT Email,FristName, LastName ,HireDate ,EmpType,PayRates FROM tblInstallUsers WHERE Id = @ApplicantId

	   DECLARE @UpdateEventID INT

	
			SELECT @UpdateEventID = ID FROM tbl_AnnualEvents
				WHERE EventName = 'InterViewDetails'
					AND ApplicantId = @ApplicantId


			UPDATE tbl_AnnualEvents 
				SET EventDate = @ReSheduleDate
				  , EventAddedBy = @ReSheduleByUserId

				WHERE ID = @UpdateEventID 
	
END

--================================================================================================================================================================
-- Oct 10 2016
--================================================================================================================================================================

