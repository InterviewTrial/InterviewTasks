using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.Common;
using Microsoft.Practices.EnterpriseLibrary.Data.Sql;

using JG_Prospect.DAL.Database;
using JG_Prospect.Common.modal;
using JG_Prospect.Common;


namespace JG_Prospect.DAL
{
    public class TaskGeneratorDAL
    {
        public static TaskGeneratorDAL m_TaskGeneratorDAL = new TaskGeneratorDAL();
        private TaskGeneratorDAL()
        {
        }
        public static TaskGeneratorDAL Instance
        {
            get { return m_TaskGeneratorDAL; }
            private set { ; }
        }

        private DataSet returndata;

        public Int64 SaveOrDeleteTask(Task objTask)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("SP_SaveOrDeleteTask");

                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@Mode", DbType.Int16, objTask.Mode);
                    database.AddInParameter(command, "@TaskId", DbType.Int64, objTask.TaskId);
                    database.AddInParameter(command, "@Title", DbType.String, objTask.Title);
                    database.AddInParameter(command, "@Description", DbType.String, objTask.Description);
                    database.AddInParameter(command, "@Status", DbType.Int16, objTask.Status);

                    if (!string.IsNullOrEmpty(objTask.DueDate))
                    {
                        database.AddInParameter(command, "@DueDate", DbType.DateTime, Convert.ToDateTime(objTask.DueDate));
                    }

                    database.AddInParameter(command, "@Hours", DbType.String, objTask.Hours);
                    database.AddInParameter(command, "@CreatedBy", DbType.Int32, objTask.CreatedBy);

                    if (objTask.ParentTaskId.HasValue)
                    {
                        database.AddInParameter(command, "@InstallId", DbType.String, objTask.InstallId);
                        database.AddInParameter(command, "@ParentTaskId", DbType.Int32, objTask.ParentTaskId.Value);
                    }

                    if (objTask.TaskType.HasValue)
                    {
                        database.AddInParameter(command, "@TaskType", DbType.Int16, objTask.TaskType.Value);
                    }

                    if (objTask.TaskPriority.HasValue)
                    {
                        database.AddInParameter(command, "@TaskPriority", DbType.Int16, objTask.TaskPriority.Value);
                    }
                    database.AddInParameter(command, "@IsTechTask", DbType.Int16, objTask.IsTechTask);
                    database.AddInParameter(command, "@DeletedStatus", SqlDbType.SmallInt, (byte)Common.JGConstant.TaskStatus.Deleted);

                    database.AddOutParameter(command, "@Result", DbType.Int32, 0);

                    int result = database.ExecuteNonQuery(command);

                    if (objTask.Mode == 0)
                    {
                        Int64 Identity = 0;
                        Identity = Convert.ToInt64(database.GetParameterValue(command, "@Result"));
                        return Identity;
                    }
                    else
                    {
                        return Convert.ToInt64(result);
                    }

                }
            }

            catch (Exception ex)
            {
                return 0;
            }

        }

        public int UpdateTaskStatus(Task objTask)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("usp_UpdateTaskStatus");

                    command.CommandType = CommandType.StoredProcedure;

                    database.AddInParameter(command, "@TaskId", DbType.Int64, objTask.TaskId);
                    database.AddInParameter(command, "@Status", DbType.Int16, objTask.Status);

                    int result = database.ExecuteNonQuery(command);

                    return result;

                }
            }

            catch (Exception ex)
            {
                return 0;
            }

        }

        public int UpdateTaskPriority(Task objTask)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("usp_UpdateTaskPriority");

                    command.CommandType = CommandType.StoredProcedure;

                    database.AddInParameter(command, "@TaskId", DbType.Int64, objTask.TaskId);
                    database.AddInParameter(command, "@TaskPriority", DbType.Int16, objTask.TaskPriority);

                    int result = database.ExecuteNonQuery(command);

                    return result;

                }
            }

            catch (Exception ex)
            {
                return 0;
            }

        }

        public bool DeleteTask(UInt64 taskId)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("usp_DeleteTask");

                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@TaskId", SqlDbType.BigInt, taskId);
                    database.AddInParameter(command, "@DeletedStatus", SqlDbType.SmallInt, (byte)Common.JGConstant.TaskStatus.Deleted);

                    int result = database.ExecuteNonQuery(command);

                    if (result > 0)
                    {
                        return true;
                    }
                    else
                    {
                        return false;
                    }
                }
            }
            catch (Exception ex)
            {
                return false;
            }

        }

        public bool SaveTaskDesignations(UInt64 TaskId, String strDesignations, String TaskIDCode)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("usp_InsertTaskDesignations");

                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@TaskId", SqlDbType.BigInt, TaskId);
                    database.AddInParameter(command, "@Designations", SqlDbType.VarChar, strDesignations);
                    database.AddInParameter(command, "@TaskIDCode", SqlDbType.VarChar, TaskIDCode);

                    int result = database.ExecuteNonQuery(command);

                    if (result > 0)
                    {
                        return true;
                    }
                    else
                    {
                        return false;
                    }
                }
            }
            catch (Exception ex)
            {
                return false;
            }

        }

        public bool SaveTaskAssignedUsers(UInt64 TaskId, String UserIds)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("usp_InsertTaskAssignedUsers");

                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@TaskId", SqlDbType.BigInt, TaskId);
                    database.AddInParameter(command, "@UserIds", SqlDbType.VarChar, UserIds);

                    int result = database.ExecuteNonQuery(command);

                    if (result > 0)
                    {
                        return true;
                    }
                    else
                    {
                        return false;
                    }
                }
            }

            catch (Exception ex)
            {
                return false;
            }
        }

        public bool SaveTaskAssignedToMultipleUsers(UInt64 TaskId, String UserId)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("usp_InsertTaskAssignedToMultipleUsers");

                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@TaskId", SqlDbType.BigInt, TaskId);
                    database.AddInParameter(command, "@UserIds", SqlDbType.VarChar, UserId);

                    int result = database.ExecuteNonQuery(command);

                    if (result > 0)
                    {
                        return true;
                    }
                    else
                    {
                        return false;
                    }
                }
            }

            catch (Exception ex)
            {
                return false;
            }
        }

        public bool SaveTaskAssignmentRequests(UInt64 TaskId, String UserIds)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("usp_InsertTaskAssignmentRequests");

                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@TaskId", SqlDbType.BigInt, TaskId);
                    database.AddInParameter(command, "@UserIds", SqlDbType.VarChar, UserIds);

                    int result = database.ExecuteNonQuery(command);

                    if (result > 0)
                    {
                        return true;
                    }
                    else
                    {
                        return false;
                    }
                }
            }

            catch (Exception ex)
            {
                return false;
            }
        }

        public bool AcceptTaskAssignmentRequests(UInt64 TaskId, String UserIds)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("usp_AcceptTaskAssignmentRequests");

                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@TaskId", SqlDbType.BigInt, TaskId);
                    database.AddInParameter(command, "@UserIds", SqlDbType.VarChar, UserIds);

                    int result = database.ExecuteNonQuery(command);

                    if (result > 0)
                    {
                        return true;
                    }
                    else
                    {
                        return false;
                    }
                }
            }

            catch (Exception ex)
            {
                return false;
            }
        }

        public bool SaveOrDeleteTaskNotes(ref TaskUser objTaskUser)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("SP_SaveOrDeleteTaskUser");

                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@Mode", DbType.Int16, objTaskUser.Mode);
                    database.AddInParameter(command, "@Id", DbType.Int64, objTaskUser.Id);
                    database.AddInParameter(command, "@TaskId", DbType.Int64, objTaskUser.TaskId);
                    database.AddInParameter(command, "@UserId", DbType.String, objTaskUser.UserId);
                    database.AddInParameter(command, "@UserType", DbType.Boolean, objTaskUser.UserType);
                    database.AddInParameter(command, "@Status", DbType.Int16, objTaskUser.Status);
                    database.AddInParameter(command, "@Notes", DbType.String, objTaskUser.Notes);
                    database.AddInParameter(command, "@UserAcceptance", DbType.Boolean, objTaskUser.UserAcceptance);
                    database.AddOutParameter(command, "@TaskUpdateId", SqlDbType.BigInt, Int32.MaxValue);
                    database.AddInParameter(command, "@IsCreatorUser", DbType.Boolean, objTaskUser.IsCreatorUser);
                    database.AddInParameter(command, "@UserFirstName", DbType.String, objTaskUser.UserFirstName);


                    int result = database.ExecuteNonQuery(command);

                    objTaskUser.TaskUpdateId = Convert.ToInt32(database.GetParameterValue(command, "@TaskUpdateId"));

                    if (result > 0)
                    {
                        return true;
                    }
                    else
                    {
                        return false;
                    }

                }
            }

            catch (Exception ex)
            {
                return false;
            }

        }

        public bool SaveTaskDescription(Int64 TaskId, String TaskDescription)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("usp_SaveTaskDescription");

                    command.CommandType = CommandType.StoredProcedure;

                    database.AddInParameter(command, "@TaskId", DbType.Int64, TaskId);

                    database.AddInParameter(command, "@Description", DbType.String, TaskDescription);

                    int result = database.ExecuteNonQuery(command);

                    if (result > 0)
                    {
                        return true;
                    }
                    else
                    {
                        return false;
                    }

                }
            }

            catch (Exception ex)
            {
                return false;
            }

        }


        public bool UpdateTaskUserAcceptance(ref TaskUser objTaskUser)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("usp_UpdateTaskAcceptance");

                    command.CommandType = CommandType.StoredProcedure;

                    database.AddInParameter(command, "@TaskId", DbType.Int64, objTaskUser.TaskId);
                    database.AddInParameter(command, "@UserId", DbType.String, objTaskUser.UserId);
                    database.AddInParameter(command, "@Acceptance", DbType.Boolean, objTaskUser.UserAcceptance);

                    int result = database.ExecuteNonQuery(command);

                    if (result > 0)
                    {
                        return true;
                    }
                    else
                    {
                        return false;
                    }

                }
            }

            catch (Exception ex)
            {
                return false;
            }

        }

        public bool DeleteTaskUserFile(Int64 Id)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("usp_DeleteTaskAttachmentFile");

                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@Id", SqlDbType.BigInt, Id);

                    int result = database.ExecuteNonQuery(command);



                    if (result > 0)
                    {
                        return true;
                    }
                    else
                    {
                        return false;
                    }
                }
            }

            catch (Exception ex)
            {
                return false;
            }

        }

        public bool SaveOrDeleteTaskUserFiles(TaskUser objTaskUser)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("SP_SaveOrDeleteTaskUserFiles");

                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@Mode", SqlDbType.TinyInt, objTaskUser.Mode);


                    if (objTaskUser.TaskUpdateId != null)
                    {
                        database.AddInParameter(command, "@TaskUpDateId", SqlDbType.BigInt, objTaskUser.TaskUpdateId);
                    }
                    else
                    {
                        database.AddInParameter(command, "@TaskUpDateId", SqlDbType.BigInt, DBNull.Value);
                    }

                    if (objTaskUser.TaskFileDestination.HasValue)
                    {
                        database.AddInParameter(command, "@FileDestination", SqlDbType.TinyInt, Convert.ToByte(objTaskUser.TaskFileDestination.Value));
                    }

                    database.AddInParameter(command, "@TaskId", SqlDbType.BigInt, objTaskUser.TaskId);
                    database.AddInParameter(command, "@UserId", SqlDbType.Int, objTaskUser.UserId);
                    database.AddInParameter(command, "@Attachment", DbType.String, objTaskUser.Attachment);
                    database.AddInParameter(command, "@OriginalFileName", DbType.String, objTaskUser.OriginalFileName);
                    database.AddInParameter(command, "@UserType", DbType.String, objTaskUser.UserType);
                    database.AddInParameter(command, "@FileType", DbType.String, objTaskUser.FileType);

                    int result = database.ExecuteNonQuery(command);

                    if (result > 0)
                    {
                        return true;
                    }
                    else
                    {
                        return false;
                    }
                }
            }

            catch (Exception ex)
            {
                return false;
            }

        }

        //Get details for task with user and attachments
        public DataSet GetTaskDetails(Int32 TaskId)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    returndata = new DataSet();
                    DbCommand command = database.GetStoredProcCommand("usp_GetTaskDetails");
                    command.CommandType = CommandType.StoredProcedure;

                    database.AddInParameter(command, "@TaskId", DbType.Int32, TaskId);

                    returndata = database.ExecuteDataSet(command);

                    return returndata;
                }
            }

            catch (Exception ex)
            {
                return null;
            }
        }

        //Get details for sub tasks with user and attachments
        public DataSet GetSubTasks(Int32 TaskId, bool blIsAdmin, string strSortExpression)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    returndata = new DataSet();
                    DbCommand command = database.GetStoredProcCommand("usp_GetSubTasks");
                    command.CommandType = CommandType.StoredProcedure;

                    database.AddInParameter(command, "@TaskId", DbType.Int32, TaskId);
                    database.AddInParameter(command, "@Admin", DbType.Boolean, blIsAdmin);

                    database.AddInParameter(command, "@SortExpression", DbType.String, strSortExpression);

                    database.AddInParameter(command, "@OpenStatus", SqlDbType.SmallInt, (byte)Common.JGConstant.TaskStatus.Open);
                    database.AddInParameter(command, "@RequestedStatus", SqlDbType.SmallInt, (byte)Common.JGConstant.TaskStatus.Requested);
                    database.AddInParameter(command, "@AssignedStatus", SqlDbType.SmallInt, (byte)Common.JGConstant.TaskStatus.Assigned);
                    database.AddInParameter(command, "@InProgressStatus", SqlDbType.SmallInt, (byte)Common.JGConstant.TaskStatus.InProgress);
                    database.AddInParameter(command, "@PendingStatus", SqlDbType.SmallInt, (byte)Common.JGConstant.TaskStatus.Pending);
                    database.AddInParameter(command, "@ReOpenedStatus", SqlDbType.SmallInt, (byte)Common.JGConstant.TaskStatus.ReOpened);
                    database.AddInParameter(command, "@ClosedStatus", SqlDbType.SmallInt, (byte)Common.JGConstant.TaskStatus.Closed);
                    database.AddInParameter(command, "@SpecsInProgressStatus", SqlDbType.SmallInt, (byte)Common.JGConstant.TaskStatus.SpecsInProgress);
                    database.AddInParameter(command, "@DeletedStatus", SqlDbType.SmallInt, (byte)Common.JGConstant.TaskStatus.Deleted);

                    returndata = database.ExecuteDataSet(command);

                    return returndata;
                }
            }

            catch (Exception ex)
            {
                return null;
            }
        }

        public DataSet GetTaskUserFiles(Int32 TaskId, JGConstant.TaskFileDestination? objTaskFileDestination, Int32? intPageIndex, Int32? intPageSize)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    returndata = new DataSet();
                    DbCommand command = database.GetStoredProcCommand("usp_GetTaskUserFiles");
                    command.CommandType = CommandType.StoredProcedure;

                    database.AddInParameter(command, "@TaskId", DbType.Int32, TaskId);

                    if (objTaskFileDestination.HasValue)
                    {
                        database.AddInParameter(command, "@FileDestination", DbType.Int32, Convert.ToByte(objTaskFileDestination.Value));
                    }

                    if (intPageIndex.HasValue)
                    {
                        database.AddInParameter(command, "@PageIndex", DbType.Int32, intPageIndex.Value);
                    }
                    if (intPageSize.HasValue)
                    {
                        database.AddInParameter(command, "@PageSize", DbType.Int32, intPageSize);
                    }

                    returndata = database.ExecuteDataSet(command);

                    return returndata;
                }
            }

            catch (Exception ex)
            {
                return null;
            }
        }

        public DataSet GetInstallUsers(int Key, string Designastion)
        {
            DataSet result = new DataSet();
            try
            {

                string[] arrDesignation = Designastion.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);

                for (int i = 0; i < arrDesignation.Length; i++)
                {
                    arrDesignation[i] = arrDesignation[i].Trim();
                }

                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("SP_GetInstallUsers");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@Key", DbType.Int16, Key);
                    database.AddInParameter(command, "@Designations", DbType.String, string.Join(",", arrDesignation));
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                return null;
            }

        }

        public DataSet GetAllActiveTechTask()
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("SP_GetAllActiveTechTask");
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                return null;
            }

        }

        public DataSet GetTaskUserDetails(Int16 TaskID)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    returndata = new DataSet();
                    DbCommand command = database.GetStoredProcCommand("SP_GetTaskUserDetailsByTaskId");
                    command.CommandType = CommandType.StoredProcedure;

                    database.AddInParameter(command, "@TaskId", DbType.Int16, TaskID);

                    returndata = database.ExecuteDataSet(command);

                    return returndata;
                }
            }

            catch (Exception ex)
            {
                return null;
            }
        }

        public DataSet GetAllActiveTechTaskForDesignationID(int iDesignationID)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UDP_GetAllActiveTechTaskForDesignationID");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@DesignationID", DbType.Int32, iDesignationID);
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                return null;
            }

        }


        /// <summary>
        /// to GetUserDetails by Id
        /// </summary>
        /// <param name="Id"></param>
        /// <returns></returns>
        public DataSet GetUserDetails(Int32 Id)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("usp_GetUserDetails");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@Id", DbType.Int16, Id);
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        /// <summary>
        /// to GetInstallUserDetails by Id
        /// </summary>
        /// <param name="Id"></param>
        /// <returns></returns>
        public DataSet GetInstallUserDetails(Int32 Id)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("usp_GetInstallUserDetails");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@Id", DbType.Int16, Id);
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        /// <summary>
        /// Load auto search suggestion as user types in search box for task generator.
        /// </summary>
        /// <param name="searchTerm"></param>
        /// <returns> categorised search suggestions for Users, Designations, Task Title, Task Ids </returns>
        public DataSet GetTaskSearchAutoSuggestion(String searchTerm)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("usp_LoadSearchTaskAutoSuggestion");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@SearchTerm", DbType.String, searchTerm);
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        /// <summary>
        /// Will fetch task lists based on various filter parameters provided.
        /// </summary>
        /// <param name="UserID"></param>
        /// <param name="Title"></param>
        /// <param name="Designation"></param>
        /// <param name="Status"></param>
        /// <param name="CreatedOn"></param>
        /// <param name="Start"></param>
        /// <param name="PageLimit"></param>
        /// <returns></returns>
        public DataSet GetTasksList(int? UserID, string Title, string Designation, Int16? Status, DateTime? CreatedFrom, DateTime? CreatedTo, string Statuses, string Designations, bool isAdmin, int Start, int PageLimit, string strSortExpression)
        {
            returndata = new DataSet();

            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("uspSearchTasks");

                    if (!String.IsNullOrEmpty(Designations))
                    {
                        database.AddInParameter(command, "@Designations", DbType.String, Designation);
                    }
                    else
                    {
                        database.AddInParameter(command, "@Designations", DbType.String, DBNull.Value);
                    }

                    if (UserID.HasValue)
                    {
                        database.AddInParameter(command, "@UserId", DbType.Int32, UserID.Value);
                    }
                    else
                    {
                        database.AddInParameter(command, "@UserId", DbType.Int32, DBNull.Value);
                    }

                    if (Status.HasValue)
                    {
                        database.AddInParameter(command, "@Status", DbType.Int16, Status.Value);
                    }
                    else
                    {
                        database.AddInParameter(command, "@Status", DbType.Int16, DBNull.Value);
                    }

                    if (CreatedFrom.HasValue)
                    {
                        database.AddInParameter(command, "@CreatedFrom", DbType.DateTime, CreatedFrom.Value);
                    }
                    else
                    {
                        database.AddInParameter(command, "@CreatedFrom", DbType.DateTime, DBNull.Value);
                    }

                    if (CreatedTo.HasValue)
                    {
                        database.AddInParameter(command, "@CreatedTo", DbType.DateTime, CreatedTo.Value);
                    }
                    else
                    {
                        database.AddInParameter(command, "@CreatedTo", DbType.DateTime, DBNull.Value);
                    }

                    if (!String.IsNullOrEmpty(Title))
                    {
                        database.AddInParameter(command, "@SearchTerm", DbType.String, Title);
                    }
                    else
                    {
                        database.AddInParameter(command, "@SearchTerm", DbType.String, DBNull.Value);
                    }

                    //database.AddInParameter(command, "@ExcludeStatus", DbType.Int16, Convert.ToInt16(JG_Prospect.Common.JGConstant.TaskStatus.SpecsInProgress));
                    database.AddInParameter(command, "@ExcludeStatus", DbType.Int16, DBNull.Value);

                    database.AddInParameter(command, "@Admin", DbType.Boolean, isAdmin);

                    database.AddInParameter(command, "@PageIndex", DbType.Int32, Start);
                    database.AddInParameter(command, "@PageSize", DbType.Int32, PageLimit);
                    database.AddInParameter(command, "@SortExpression", DbType.String, strSortExpression);

                    database.AddInParameter(command, "@OpenStatus", SqlDbType.SmallInt, (byte)Common.JGConstant.TaskStatus.Open);
                    database.AddInParameter(command, "@RequestedStatus", SqlDbType.SmallInt, (byte)Common.JGConstant.TaskStatus.Requested);
                    database.AddInParameter(command, "@AssignedStatus", SqlDbType.SmallInt, (byte)Common.JGConstant.TaskStatus.Assigned);
                    database.AddInParameter(command, "@InProgressStatus", SqlDbType.SmallInt, (byte)Common.JGConstant.TaskStatus.InProgress);
                    database.AddInParameter(command, "@PendingStatus", SqlDbType.SmallInt, (byte)Common.JGConstant.TaskStatus.Pending);
                    database.AddInParameter(command, "@ReOpenedStatus", SqlDbType.SmallInt, (byte)Common.JGConstant.TaskStatus.ReOpened);
                    database.AddInParameter(command, "@ClosedStatus", SqlDbType.SmallInt, (byte)Common.JGConstant.TaskStatus.Closed);
                    database.AddInParameter(command, "@SpecsInProgressStatus", SqlDbType.SmallInt, (byte)Common.JGConstant.TaskStatus.SpecsInProgress);
                    database.AddInParameter(command, "@DeletedStatus", SqlDbType.SmallInt, (byte)Common.JGConstant.TaskStatus.Deleted);
                    
                    command.CommandType = CommandType.StoredProcedure;
                    returndata = database.ExecuteDataSet(command);
                    return returndata;
                }
            }

            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
            }
            return returndata;
        }

        /// <summary>
        /// Get all Users and their designtions in system for whom tasks are available in system.
        /// <returns></returns>
        public DataSet GetAllUsersNDesignationsForFilter()
        {
            returndata = new DataSet();

            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("usp_GetUsersNDesignationForTaskFilter");

                    command.CommandType = CommandType.StoredProcedure;
                    returndata = database.ExecuteDataSet(command);
                    return returndata;
                }
            }

            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
            }
            return returndata;
        }

        public bool UpadateTaskNotes(ref TaskUser objTaskUser)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("usp_UpadateTaskNotes");

                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@Id", DbType.Int64, objTaskUser.Id);
                    database.AddInParameter(command, "@Notes", DbType.String, objTaskUser.Notes);


                    int result = database.ExecuteNonQuery(command);


                    if (result > 0)
                    {
                        return true;
                    }
                    else
                    {
                        return false;
                    }

                }
            }

            catch (Exception ex)
            {
                return false;
            }

        }

        #region TaskWorkSpecification

        public int InsertTaskWorkSpecification(TaskWorkSpecification objTaskWorkSpecification)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("InsertTaskWorkSpecification");

                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@CustomId", DbType.String, objTaskWorkSpecification.CustomId);
                    database.AddInParameter(command, "@TaskId", DbType.Int64, objTaskWorkSpecification.TaskId);
                    database.AddInParameter(command, "@Description", DbType.String, objTaskWorkSpecification.Description);
                    database.AddInParameter(command, "@Title", DbType.String, objTaskWorkSpecification.Title);
                    database.AddInParameter(command, "@URL", DbType.String, objTaskWorkSpecification.URL);

                    database.AddInParameter(command, "@AdminStatus", DbType.Boolean, objTaskWorkSpecification.AdminStatus);
                    database.AddInParameter(command, "@AdminUserId", DbType.Int32, objTaskWorkSpecification.AdminUserId);
                    database.AddInParameter(command, "@IsAdminInstallUser", DbType.Boolean, objTaskWorkSpecification.IsAdminInstallUser);

                    database.AddInParameter(command, "@TechLeadStatus", DbType.Boolean, objTaskWorkSpecification.TechLeadStatus);
                    database.AddInParameter(command, "@TechLeadUserId", DbType.Int32, objTaskWorkSpecification.TechLeadUserId);
                    database.AddInParameter(command, "@IsTechLeadInstallUser", DbType.Boolean, objTaskWorkSpecification.IsTechLeadInstallUser);

                    database.AddInParameter(command, "@OtherUserStatus", DbType.Boolean, objTaskWorkSpecification.OtherUserStatus);
                    database.AddInParameter(command, "@OtherUserId", DbType.Int32, objTaskWorkSpecification.OtherUserId);
                    database.AddInParameter(command, "@IsOtherUserInstallUser", DbType.Boolean, objTaskWorkSpecification.IsOtherUserInstallUser);

                    if (objTaskWorkSpecification.ParentTaskWorkSpecificationId.HasValue)
                    {
                        database.AddInParameter(command, "@ParentTaskWorkSpecificationId", SqlDbType.BigInt, objTaskWorkSpecification.ParentTaskWorkSpecificationId.Value);
                    }

                    return database.ExecuteNonQuery(command);
                }
            }
            catch
            {
                return -1;
            }
        }

        public int UpdateTaskWorkSpecification(TaskWorkSpecification objTaskWorkSpecification)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UpdateTaskWorkSpecification");

                    command.CommandType = CommandType.StoredProcedure;

                    database.AddInParameter(command, "@Id", DbType.Int64, objTaskWorkSpecification.Id);
                    database.AddInParameter(command, "@CustomId", DbType.String, objTaskWorkSpecification.CustomId);
                    database.AddInParameter(command, "@TaskId", DbType.Int64, objTaskWorkSpecification.TaskId);
                    database.AddInParameter(command, "@Description", DbType.String, objTaskWorkSpecification.Description);
                    database.AddInParameter(command, "@Title", DbType.String, objTaskWorkSpecification.Title);
                    database.AddInParameter(command, "@URL", DbType.String, objTaskWorkSpecification.URL);

                    if (objTaskWorkSpecification.ParentTaskWorkSpecificationId.HasValue)
                    {
                        database.AddInParameter(command, "@ParentTaskWorkSpecificationId", SqlDbType.BigInt, objTaskWorkSpecification.ParentTaskWorkSpecificationId.Value);
                    }

                    return database.ExecuteNonQuery(command);
                }
            }
            catch
            {
                return -1;
            }
        }

        public int DeleteTaskWorkSpecification(long intTaskWorkSpecification)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("DeleteTaskWorkSpecification");

                    command.CommandType = CommandType.StoredProcedure;

                    database.AddInParameter(command, "@Id", DbType.Int64, intTaskWorkSpecification);

                    return database.ExecuteNonQuery(command);
                }
            }
            catch
            {
                return -1;
            }
        }

        public DataSet GetTaskWorkSpecifications(Int32 TaskId, bool blIsAdmin, Int64? intParentTaskWorkSpecificationId, Int32? intPageIndex, Int32? intPageSize)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("GetTaskWorkSpecifications");
                    command.CommandType = CommandType.StoredProcedure;

                    database.AddInParameter(command, "@TaskId", DbType.Int32, TaskId);
                    database.AddInParameter(command, "@Admin", DbType.Boolean, blIsAdmin);

                    if (intParentTaskWorkSpecificationId.HasValue)
                    {
                        database.AddInParameter(command, "@ParentTaskWorkSpecificationId", DbType.Int64, intParentTaskWorkSpecificationId.Value);
                    }

                    if (intPageIndex.HasValue)
                    {
                        database.AddInParameter(command, "@PageIndex", DbType.Int32, intPageIndex.Value);
                    }
                    if (intPageSize.HasValue)
                    {
                        database.AddInParameter(command, "@PageSize", DbType.Int32, intPageSize);
                    }

                    return database.ExecuteDataSet(command);
                }
            }
            catch
            {
                return null;
            }
        }

        public TaskWorkSpecification GetTaskWorkSpecificationById(Int64 Id)
        {
            TaskWorkSpecification objTaskWorkSpecification = null;

            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("GetTaskWorkSpecificationById");
                    command.CommandType = CommandType.StoredProcedure;

                    database.AddInParameter(command, "@Id", DbType.Int64, Id);

                    DataSet dsTaskWorkSpecification = database.ExecuteDataSet(command);

                    if (
                        dsTaskWorkSpecification != null &&
                        dsTaskWorkSpecification.Tables.Count > 0 &&
                        dsTaskWorkSpecification.Tables[0].Rows.Count > 0
                       )
                    {
                        objTaskWorkSpecification = GetTaskWorkSpecification(dsTaskWorkSpecification.Tables[0].Rows[0]);
                    }

                    return objTaskWorkSpecification;
                }
            }
            catch
            {
                return objTaskWorkSpecification;
            }
        }

        public int UpdateTaskWorkSpecificationStatusByTaskId(TaskWorkSpecification objTaskWorkSpecification, bool blIsAdmin, bool blIsTechLead, bool blIsUser)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UpdateTaskWorkSpecificationStatusByTaskId");

                    command.CommandType = CommandType.StoredProcedure;

                    database.AddInParameter(command, "@TaskId", DbType.Int64, objTaskWorkSpecification.TaskId);
                    if (blIsAdmin)
                    {
                        database.AddInParameter(command, "@AdminStatus", DbType.Boolean, objTaskWorkSpecification.AdminStatus);
                        database.AddInParameter(command, "@UserId", DbType.Int32, objTaskWorkSpecification.AdminUserId);
                        database.AddInParameter(command, "@IsInstallUser", DbType.Boolean, objTaskWorkSpecification.IsAdminInstallUser);
                    }
                    else if (blIsTechLead)
                    {
                        database.AddInParameter(command, "@TechLeadStatus", DbType.Boolean, objTaskWorkSpecification.TechLeadStatus);
                        database.AddInParameter(command, "@UserId", DbType.Int32, objTaskWorkSpecification.TechLeadUserId);
                        database.AddInParameter(command, "@IsInstallUser", DbType.Boolean, objTaskWorkSpecification.IsTechLeadInstallUser);
                    }
                    else if (blIsUser)
                    {
                        database.AddInParameter(command, "@OtherUserStatus", DbType.Boolean, objTaskWorkSpecification.OtherUserStatus);
                        database.AddInParameter(command, "@UserId", DbType.Int32, objTaskWorkSpecification.OtherUserId);
                        database.AddInParameter(command, "@IsInstallUser", DbType.Boolean, objTaskWorkSpecification.IsOtherUserInstallUser);
                    }

                    return database.ExecuteNonQuery(command);
                }
            }
            catch
            {
                return -1;
            }
        }

        public int UpdateTaskWorkSpecificationStatusById(TaskWorkSpecification objTaskWorkSpecification, bool blIsAdmin, bool blIsTechLead, bool blIsUser)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UpdateTaskWorkSpecificationStatusById");

                    command.CommandType = CommandType.StoredProcedure;

                    database.AddInParameter(command, "@Id", DbType.Int64, objTaskWorkSpecification.Id);
                    if (blIsAdmin)
                    {
                        database.AddInParameter(command, "@AdminStatus", DbType.Boolean, objTaskWorkSpecification.AdminStatus);
                        database.AddInParameter(command, "@UserId", DbType.Int32, objTaskWorkSpecification.AdminUserId);
                        database.AddInParameter(command, "@IsInstallUser", DbType.Boolean, objTaskWorkSpecification.IsAdminInstallUser);
                    }
                    else if (blIsTechLead)
                    {
                        database.AddInParameter(command, "@TechLeadStatus", DbType.Boolean, objTaskWorkSpecification.TechLeadStatus);
                        database.AddInParameter(command, "@UserId", DbType.Int32, objTaskWorkSpecification.TechLeadUserId);
                        database.AddInParameter(command, "@IsInstallUser", DbType.Boolean, objTaskWorkSpecification.IsTechLeadInstallUser);
                    }
                    else if (blIsUser)
                    {
                        database.AddInParameter(command, "@OtherUserStatus", DbType.Boolean, objTaskWorkSpecification.OtherUserStatus);
                        database.AddInParameter(command, "@UserId", DbType.Int32, objTaskWorkSpecification.OtherUserId);
                        database.AddInParameter(command, "@IsInstallUser", DbType.Boolean, objTaskWorkSpecification.IsOtherUserInstallUser);
                    }

                    return database.ExecuteNonQuery(command);
                }
            }
            catch
            {
                return -1;
            }
        }

        public DataSet GetPendingTaskWorkSpecificationCount(Int32 TaskId)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    returndata = new DataSet();
                    DbCommand command = database.GetStoredProcCommand("GetPendingTaskWorkSpecificationCount");
                    command.CommandType = CommandType.StoredProcedure;

                    database.AddInParameter(command, "@TaskId", DbType.Int32, TaskId);
                    return database.ExecuteDataSet(command);
                }
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        /// <summary>
        /// Get a TaskWorkSpecification object based on values in DataRow.
        /// </summary>
        /// <param name="drTaskWorkSpecification">possible DataRow containing TaskWorkSpecification data.</param>
        /// <returns></returns>
        private TaskWorkSpecification GetTaskWorkSpecification(DataRow drTaskWorkSpecification)
        {
            TaskWorkSpecification objTaskWorkSpecification = new TaskWorkSpecification();

            #region Prepare TaskWorkSpecification Object

            objTaskWorkSpecification.Id = Convert.ToInt64(drTaskWorkSpecification["Id"]);
            objTaskWorkSpecification.CustomId = Convert.ToString(drTaskWorkSpecification["CustomId"]);
            objTaskWorkSpecification.TaskId = Convert.ToInt64(drTaskWorkSpecification["TaskId"]);
            objTaskWorkSpecification.Description = Convert.ToString(drTaskWorkSpecification["Description"]);
            objTaskWorkSpecification.Title = Convert.ToString(drTaskWorkSpecification["Title"]);
            objTaskWorkSpecification.URL = Convert.ToString(drTaskWorkSpecification["URL"]);

            if (!string.IsNullOrEmpty(Convert.ToString(drTaskWorkSpecification["AdminUserId"])))
            {
                objTaskWorkSpecification.AdminUserId = Convert.ToInt32(drTaskWorkSpecification["AdminUserId"]);
                objTaskWorkSpecification.IsAdminInstallUser = Convert.ToBoolean(drTaskWorkSpecification["IsAdminInstallUser"]);
                objTaskWorkSpecification.AdminUsername = Convert.ToString(drTaskWorkSpecification["AdminUsername"]);
                objTaskWorkSpecification.AdminUserFirstname = Convert.ToString(drTaskWorkSpecification["AdminUserFirstName"]);
                objTaskWorkSpecification.AdminUserLastname = Convert.ToString(drTaskWorkSpecification["AdminUserLastName"]);
                objTaskWorkSpecification.AdminUserEmail = Convert.ToString(drTaskWorkSpecification["AdminUserEmail"]);
            }

            if (!string.IsNullOrEmpty(Convert.ToString(drTaskWorkSpecification["TechLeadUserId"])))
            {
                objTaskWorkSpecification.AdminUserId = Convert.ToInt32(drTaskWorkSpecification["TechLeadUserId"]);
                objTaskWorkSpecification.IsAdminInstallUser = Convert.ToBoolean(drTaskWorkSpecification["IsTechLeadInstallUser"]);
                objTaskWorkSpecification.TechLeadUsername = Convert.ToString(drTaskWorkSpecification["TechLeadUsername"]);
                objTaskWorkSpecification.TechLeadUserFirstname = Convert.ToString(drTaskWorkSpecification["TechLeadUserFirstName"]);
                objTaskWorkSpecification.TechLeadUserLastname = Convert.ToString(drTaskWorkSpecification["TechLeadUserLastName"]);
                objTaskWorkSpecification.TechLeadUserEmail = Convert.ToString(drTaskWorkSpecification["TechLeadUserEmail"]);
            }

            if (!string.IsNullOrEmpty(Convert.ToString(drTaskWorkSpecification["OtherUserId"])))
            {
                objTaskWorkSpecification.OtherUserId = Convert.ToInt32(drTaskWorkSpecification["OtherUserId"]);
                objTaskWorkSpecification.IsOtherUserInstallUser = Convert.ToBoolean(drTaskWorkSpecification["IsOtherUserInstallUser"]);
                objTaskWorkSpecification.OtherUsername = Convert.ToString(drTaskWorkSpecification["OtherUsername"]);
                objTaskWorkSpecification.OtherUserFirstname = Convert.ToString(drTaskWorkSpecification["OtherUserFirstName"]);
                objTaskWorkSpecification.OtherUserLastname = Convert.ToString(drTaskWorkSpecification["OtherUserLastName"]);
                objTaskWorkSpecification.OtherUserEmail = Convert.ToString(drTaskWorkSpecification["OtherUserEmail"]);
            }

            objTaskWorkSpecification.AdminStatus = Convert.ToBoolean(drTaskWorkSpecification["AdminStatus"]);
            objTaskWorkSpecification.TechLeadStatus = Convert.ToBoolean(drTaskWorkSpecification["TechLeadStatus"]);
            objTaskWorkSpecification.OtherUserStatus = Convert.ToBoolean(drTaskWorkSpecification["OtherUserStatus"]);
            objTaskWorkSpecification.DateCreated = Convert.ToDateTime(drTaskWorkSpecification["DateCreated"]);
            objTaskWorkSpecification.DateUpdated = Convert.ToDateTime(drTaskWorkSpecification["DateUpdated"]);

            #endregion

            return objTaskWorkSpecification;
        }


        #endregion

        public int UpdateSubTaskStatusById(Task objTask, bool blIsAdmin, bool blIsTechLead, bool blIsUser)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UpdateSubTaskStatusById");

                    command.CommandType = CommandType.StoredProcedure;

                    database.AddInParameter(command, "@TaskId", DbType.Int64, objTask.TaskId);
                    if (blIsAdmin)
                    {
                        database.AddInParameter(command, "@AdminStatus", DbType.Boolean, objTask.AdminStatus);
                        database.AddInParameter(command, "@UserId", DbType.Int32, objTask.AdminUserId);
                        database.AddInParameter(command, "@IsInstallUser", DbType.Boolean, objTask.IsAdminInstallUser);
                    }
                    else if (blIsTechLead)
                    {
                        database.AddInParameter(command, "@TechLeadStatus", DbType.Boolean, objTask.TechLeadStatus);
                        database.AddInParameter(command, "@UserId", DbType.Int32, objTask.TechLeadUserId);
                        database.AddInParameter(command, "@IsInstallUser", DbType.Boolean, objTask.IsTechLeadInstallUser);
                    }
                    else if (blIsUser)
                    {
                        database.AddInParameter(command, "@OtherUserStatus", DbType.Boolean, objTask.OtherUserStatus);
                        database.AddInParameter(command, "@UserId", DbType.Int32, objTask.OtherUserId);
                        database.AddInParameter(command, "@IsInstallUser", DbType.Boolean, objTask.IsOtherUserInstallUser);
                    }

                    return database.ExecuteNonQuery(command);
                }
            }
            catch
            {
                return -1;
            }
        }

        public DataSet GetPendingSubTaskCount(Int32 TaskId)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    returndata = new DataSet();
                    DbCommand command = database.GetStoredProcCommand("GetPendingSubTaskCount");
                    command.CommandType = CommandType.StoredProcedure;

                    database.AddInParameter(command, "@TaskId", DbType.Int32, TaskId);
                    return database.ExecuteDataSet(command);
                }
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        #region TaskAcceptance

        public DataSet GetTaskAcceptances(Int64 TaskId)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    returndata = new DataSet();
                    DbCommand command = database.GetStoredProcCommand("GetTaskAcceptances");
                    command.CommandType = CommandType.StoredProcedure;

                    database.AddInParameter(command, "@TaskId", DbType.Int64, TaskId);
                    return database.ExecuteDataSet(command);
                }
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        public int InsertTaskAcceptance(TaskAcceptance objTaskAcceptance)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("InsertTaskAcceptance");

                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@TaskId", DbType.Int64, objTaskAcceptance.TaskId);
                    database.AddInParameter(command, "@UserId", DbType.Int64, objTaskAcceptance.UserId);
                    database.AddInParameter(command, "@IsInstallUser", DbType.Boolean, objTaskAcceptance.IsInstallUser);
                    database.AddInParameter(command, "@IsAccepted", DbType.Boolean, objTaskAcceptance.IsAccepted);

                    return database.ExecuteNonQuery(command);
                }
            }
            catch
            {
                return -1;
            }
        }

        #endregion
    }
}
