using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using JG_Prospect.DAL;
using JG_Prospect.Common;
using JG_Prospect.Common.modal;
using System.Data;
using Microsoft.Practices.EnterpriseLibrary.Data.Sql;
using System.Data.Common;
using JG_Prospect.DAL.Database;

namespace JG_Prospect.BLL
{
    public class TaskGeneratorBLL
    {
        private static TaskGeneratorBLL m_TaskGeneratorBLL = new TaskGeneratorBLL();

        private TaskGeneratorBLL()
        {

        }

        public static TaskGeneratorBLL Instance
        {
            get { return m_TaskGeneratorBLL; }
            set {; }
        }
        public Int64 SaveOrDeleteTask(Task objTask)
        {
            return TaskGeneratorDAL.Instance.SaveOrDeleteTask(objTask);
        }

        public bool SaveTaskDesignations(UInt64 TaskId, String strDesignations, String TaskIDCode)
        {
            return TaskGeneratorDAL.Instance.SaveTaskDesignations(TaskId, strDesignations, TaskIDCode);
        }
        public bool SaveTaskAssignedUsers(UInt64 TaskId, String UserIds)
        {
            return TaskGeneratorDAL.Instance.SaveTaskAssignedUsers(TaskId, UserIds);
        }
        public bool SaveTaskAssignmentRequests(UInt64 TaskId, String UserIds)
        {
            return TaskGeneratorDAL.Instance.SaveTaskAssignmentRequests(TaskId, UserIds);
        }
        public bool AcceptTaskAssignmentRequests(UInt64 TaskId, String UserIds)
        {
            return TaskGeneratorDAL.Instance.AcceptTaskAssignmentRequests(TaskId, UserIds);
        }
        public bool SaveOrDeleteTaskNotes(ref TaskUser objTaskUser)
        {
            return TaskGeneratorDAL.Instance.SaveOrDeleteTaskNotes(ref objTaskUser);
        }

        public bool UpdateTaskAcceptance(ref TaskUser objTaskUser)
        {
            return TaskGeneratorDAL.Instance.UpdateTaskUserAcceptance(ref objTaskUser);
        }

        public bool SaveOrDeleteTaskUserFiles(TaskUser objTaskUser)
        {
            return TaskGeneratorDAL.Instance.SaveOrDeleteTaskUserFiles(objTaskUser);
        }

        public int InsertTaskWorkSpecification(TaskWorkSpecification objTaskWorkSpecification)
        {
            return TaskGeneratorDAL.Instance.InsertTaskWorkSpecification(objTaskWorkSpecification);
        }

        public int UpdateTaskWorkSpecification(TaskWorkSpecification objTaskWorkSpecification)
        {
            return TaskGeneratorDAL.Instance.UpdateTaskWorkSpecification(objTaskWorkSpecification);
        }
        
        public DataSet GetLatestTaskWorkSpecification(Int32 TaskId, bool? bytStatus)
        {
            return TaskGeneratorDAL.Instance.GetLatestTaskWorkSpecification(TaskId, bytStatus);
        }
        public DataSet GetTaskDetails(Int32 TaskId)
        {
            return TaskGeneratorDAL.Instance.GetTaskDetails(TaskId);
        }

        public DataSet GetSubTasks(Int32 TaskId)
        {
            return TaskGeneratorDAL.Instance.GetSubTasks(TaskId);
        }

        public DataSet GetTaskUserFiles(Int32 TaskId)
        {
            return TaskGeneratorDAL.Instance.GetTaskUserFiles(TaskId);
        }

        public DataSet GetTaskUserDetails(Int16 Mode)
        {
            return TaskGeneratorDAL.Instance.GetTaskUserDetails(Mode);
        }
        public DataSet GetInstallUsers(int key, string Designation)
        {
            return TaskGeneratorDAL.Instance.GetInstallUsers(key, Designation);
        }
        public DataSet GetAllActiveTechTask()
        {
            return TaskGeneratorDAL.Instance.GetAllActiveTechTask();
        }

        public DataSet GetUserDetails(Int32 Id)
        {
            return TaskGeneratorDAL.Instance.GetUserDetails(Id);
        }

        public DataSet GetInstallUserDetails(Int32 Id)
        {
            return TaskGeneratorDAL.Instance.GetInstallUserDetails(Id);
        }

        public DataSet GetTaskSearchAutoSuggestion(String searchTerm)
        {
            return TaskGeneratorDAL.Instance.GetTaskSearchAutoSuggestion(searchTerm);
        }

        public DataSet GetTasksList(int? UserID, string Title, string Designation, Int16? Status, DateTime? CreatedFrom, DateTime? CreatedTo, string Statuses, string Designations, bool isAdmin, int Start, int PageLimit)
        {
            return TaskGeneratorDAL.Instance.GetTasksList(UserID, Title, Designation, Status, CreatedFrom, CreatedTo, Statuses , Designations,isAdmin,Start, PageLimit);
        }

        public DataSet GetAllUsersNDesignationsForFilter()
        {
            return TaskGeneratorDAL.Instance.GetAllUsersNDesignationsForFilter();
        }

        public int UpdateTaskStatus(Task objTask)
        {
            return TaskGeneratorDAL.Instance.UpdateTaskStatus(objTask);
        }
        public bool DeleteTask(UInt64 TaskId)
        {
            return TaskGeneratorDAL.Instance.DeleteTask(TaskId);
        }
    }
}
