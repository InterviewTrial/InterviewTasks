using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Data;
using System.Data.Common;
using Microsoft.Practices.EnterpriseLibrary.Data.Sql;
using JG_Prospect.DAL.Database;
using JG_Prospect.Common.modal;


namespace JG_Prospect.DAL
{
    public class UserAuditTrailDAL
    {
        #region  - constructor & variable-

        private static UserAuditTrailDAL m_UserAuditTrailDAL = new UserAuditTrailDAL();

        private UserAuditTrailDAL()
        {

        }

        public static UserAuditTrailDAL Instance
        {
            get { return m_UserAuditTrailDAL; }
            private set {; }
        }

        

        #endregion

        #region Public Methods

        public void AddUpdateUserAuditTrailRecord(UserAuditTrail objUserAudit)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("SP_AddUpdateUserAuditRecord");
                    command.CommandType = CommandType.StoredProcedure;

                    database.AddInParameter(command, "@LogInGuID", DbType.String, objUserAudit.LogInGuID);
                    database.AddInParameter(command, "@UserLoginID", DbType.String, objUserAudit.UserLoginID);
                    database.AddInParameter(command, "@Description", DbType.String, objUserAudit.Description);
                    database.AddInParameter(command, "@CurrentActionTime", DbType.DateTime, objUserAudit.CurrentActionTime);

                    database.ExecuteScalar(command);
                    //int res = Convert.ToInt32(database.GetParameterValue(command, "@result"));

                }
            }
            catch (Exception ex)
            {


            }
        }

        public DataSet GetAuditsTrailLstByLoginID(string userLoginID)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DataSet returndata = new DataSet();
                    DbCommand command = database.GetStoredProcCommand("SP_GetAuditTrailDataByLoginID");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@UserLoginID", DbType.String, userLoginID);

                    returndata = database.ExecuteDataSet(command);

                    return returndata;
                }
            }

            catch (Exception ex)
            {
                return null;
            }
        }

        public DataSet GetUpdateUserAuditsTrailLstByLoginID(string userLoginID)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DataSet returndata = new DataSet();
                    DbCommand command = database.GetStoredProcCommand("SP_GetUpdateUserAuditTrailDataByUserID");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@UserLoginID", DbType.String, userLoginID);

                    returndata = database.ExecuteDataSet(command);

                    return returndata;
                }
            }

            catch (Exception ex)
            {
                return null;
            }
        }


        public void UpdateUserLogOutTime(UserAuditTrail objUserAudit)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("SP_UpdateUserAuditLogOutTime");
                    command.CommandType = CommandType.StoredProcedure;

                    database.AddInParameter(command, "@LogInGuID", DbType.String, objUserAudit.LogInGuID);
                    database.AddInParameter(command, "@LogOutTime", DbType.String, objUserAudit.LogOutTime);

                    database.ExecuteScalar(command);
                    //int res = Convert.ToInt32(database.GetParameterValue(command, "@result"));

                }
            }
            catch (Exception ex)
            {  
            }
        }
        #endregion

    }
}
