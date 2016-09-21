using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.Common;
using Microsoft.Practices.EnterpriseLibrary.Data.Sql;

using JG_Prospect.DAL.Database;
using JG_Prospect.Common.modal;


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

        public bool DeleteTask(UInt64 taskId)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("usp_DeleteTask");

                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@TaskId", SqlDbType.BigInt, taskId);

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

                    database.AddInParameter(command, "@TaskId", SqlDbType.BigInt, objTaskUser.TaskId);
                    database.AddInParameter(command, "@UserId", SqlDbType.Int, objTaskUser.UserId);
                    database.AddInParameter(command, "@Attachment", DbType.String, objTaskUser.Attachment);
                    database.AddInParameter(command, "@OriginalFileName", DbType.String, objTaskUser.OriginalFileName);
                    database.AddInParameter(command, "@UserType", DbType.String, objTaskUser.UserType);


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

        public int InsertTaskWorkSpecification(TaskWorkSpecification objTaskWorkSpecification)
        {
            try
            {
                TaskWorkSpecificationVersions objTaskWorkSpecificationVersions = objTaskWorkSpecification.TaskWorkSpecificationVersions[0];

                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("InsertTaskWorkSpecification");

                    command.CommandType = CommandType.StoredProcedure;

                    database.AddInParameter(command, "@TaskId", DbType.Int64, objTaskWorkSpecification.TaskId);
                    database.AddInParameter(command, "@Content", DbType.String, objTaskWorkSpecificationVersions.Content);
                    database.AddInParameter(command, "@UserId", DbType.Int32, objTaskWorkSpecificationVersions.UserId);
                    database.AddInParameter(command, "@IsInstallUser", DbType.Boolean, objTaskWorkSpecificationVersions.IsInstallUser);
                    database.AddInParameter(command, "@Status", DbType.Boolean, objTaskWorkSpecificationVersions.Status);

                    int result = database.ExecuteNonQuery(command);

                    return result;
                }
            }
            catch (Exception ex)
            {
                return 0;
            }
        }

        public int UpdateTaskWorkSpecification(TaskWorkSpecification objTaskWorkSpecification)
        {
            try
            {
                TaskWorkSpecificationVersions objTaskWorkSpecificationVersions = objTaskWorkSpecification.TaskWorkSpecificationVersions[0];

                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UpdateTaskWorkSpecification");

                    command.CommandType = CommandType.StoredProcedure;

                    database.AddInParameter(command, "@TaskWorkSpecificationId", DbType.Int32, objTaskWorkSpecification.Id);
                    database.AddInParameter(command, "@Content", DbType.String, objTaskWorkSpecificationVersions.Content);
                    database.AddInParameter(command, "@UserId", DbType.Int32, objTaskWorkSpecificationVersions.UserId);
                    database.AddInParameter(command, "@IsInstallUser", DbType.Boolean, objTaskWorkSpecificationVersions.IsInstallUser);
                    database.AddInParameter(command, "@Status", DbType.Boolean, objTaskWorkSpecificationVersions.Status);

                    int result = database.ExecuteNonQuery(command);

                    return result;
                }
            }
            catch (Exception ex)
            {
                return 0;
            }
        }

        public DataSet GetLatestTaskWorkSpecification(Int32 TaskId, bool? bytStatus)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    returndata = new DataSet();
                    DbCommand command = database.GetStoredProcCommand("GetLatestTaskWorkSpecification");
                    command.CommandType = CommandType.StoredProcedure;

                    database.AddInParameter(command, "@TaskId", DbType.Int32, TaskId);
                    if (bytStatus.HasValue)
                    {
                        database.AddInParameter(command, "@Status", DbType.Boolean, bytStatus.Value);
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
        public DataSet GetSubTasks(Int32 TaskId)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    returndata = new DataSet();
                    DbCommand command = database.GetStoredProcCommand("usp_GetSubTasks");
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

        public DataSet GetTaskUserFiles(Int32 TaskId)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    returndata = new DataSet();
                    DbCommand command = database.GetStoredProcCommand("usp_GetTaskUserFiles");
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

        public DataSet GetInstallUsers(int Key, string Designastion)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("SP_GetInstallUsers");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@Key", DbType.Int16, Key);
                    database.AddInParameter(command, "@Designations", DbType.String, Designastion);
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
        public DataSet GetTasksList(int? UserID, string Title, string Designation, Int16? Status, DateTime? CreatedFrom, DateTime? CreatedTo, string Statuses, string Designations, bool isAdmin, int Start, int PageLimit)
        {
            returndata = new DataSet();

            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    /*
                    DbCommand command = database.GetStoredProcCommand("usp_SearchUserTasks");

                    if (UserID != null)
                    {
                        database.AddInParameter(command, "@UserID", DbType.Int32, Convert.ToInt32(UserID));
                    }
                    else
                    {
                        database.AddInParameter(command, "@UserID", DbType.Int32, DBNull.Value);
                    }

                    if (!String.IsNullOrEmpty(Title))
                    {
                        database.AddInParameter(command, "@Title", DbType.String, Title);
                    }
                    else
                    {
                        database.AddInParameter(command, "@Title", DbType.String, DBNull.Value);
                    }

                    if (!String.IsNullOrEmpty(Designation))
                    {
                        database.AddInParameter(command, "@Designation", DbType.String, Designation);
                    }
                    else
                    {
                        database.AddInParameter(command, "@Designation", DbType.String, DBNull.Value);
                    }

                    if (Status != null)
                    {
                        database.AddInParameter(command, "@Status", DbType.Int16, Convert.ToInt16(Status));
                    }
                    else
                    {
                        database.AddInParameter(command, "@Status", DbType.Int16, DBNull.Value);
                    }
                    if (CreatedFrom != null)
                    {
                        database.AddInParameter(command, "@CreatedFrom", DbType.DateTime, Convert.ToDateTime(CreatedFrom));
                    }
                    else
                    {
                        database.AddInParameter(command, "@CreatedFrom", DbType.DateTime, DBNull.Value);
                    }
                    if (CreatedTo != null)
                    {
                        database.AddInParameter(command, "@CreatedTo", DbType.DateTime, Convert.ToDateTime(CreatedTo));
                    }
                    else
                    {
                        database.AddInParameter(command, "@CreatedTo", DbType.DateTime, DBNull.Value);
                    }

                    database.AddInParameter(command, "@Start", DbType.Int32, Start);
                    database.AddInParameter(command, "@PageLimit", DbType.Int32, PageLimit);

                    database.AddInParameter(command, "@IsAdmin", DbType.Boolean, isAdmin);

                    if (!String.IsNullOrEmpty(Designations))
                    {
                        database.AddInParameter(command, "@Designations", DbType.String, Designations);
                    }
                    else
                    {
                        database.AddInParameter(command, "@Designations", DbType.String, DBNull.Value);
                    }

                    if (!String.IsNullOrEmpty(Statuses))
                    {
                        database.AddInParameter(command, "@Statuses", DbType.String, Statuses);
                    }
                    else
                    {
                        database.AddInParameter(command, "@Statuses", DbType.String, DBNull.Value);
                    }       
                    */

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

                    database.AddInParameter(command, "@PageIndex", DbType.Int32, Start);
                    database.AddInParameter(command, "@PageSize", DbType.Int32, PageLimit);

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

    }
}
