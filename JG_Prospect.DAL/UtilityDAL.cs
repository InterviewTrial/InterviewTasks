using JG_Prospect.DAL.Database;
using Microsoft.Practices.EnterpriseLibrary.Data.Sql;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace JG_Prospect.DAL
{
    public class UtilityDAL
    {
        public static UtilityDAL m_UtilityDAL = new UtilityDAL();
        private UtilityDAL()
        {

        }

        public static UtilityDAL Instance
        {
            get { return m_UtilityDAL; }
            private set { ; }
        }

        public void AddException(string pageUrl, string loginID, string exMsg, string exTrace)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("AddException");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@PageUrl", DbType.String, pageUrl);
                    database.AddInParameter(command, "@LoginID", DbType.String, loginID);
                    database.AddInParameter(command, "@ExceptionMsg", DbType.String, exMsg);
                    database.AddInParameter(command, "@ExceptionTrace", DbType.String, exTrace);
                    database.ExecuteNonQuery(command);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        #region Content Settings

        public string GetContentSetting(string strKey)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("GetContentSetting");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@Key", DbType.String, strKey);
                    return Convert.ToString(database.ExecuteScalar(command));
                }
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        public int InsertContentSetting(string strKey,string strValue)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("InsertContentSetting");

                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@Key", DbType.String, strKey);
                    database.AddInParameter(command, "@Value", DbType.String, strValue);

                    return database.ExecuteNonQuery(command);
                }
            }
            catch
            {
                return -1;
            }
        }

        public int UpdateContentSetting(string strKey, string strValue)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UpdateContentSetting");

                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@Key", DbType.String, strKey);
                    database.AddInParameter(command, "@Value", DbType.String, strValue);

                    return database.ExecuteNonQuery(command);
                }
            }
            catch
            {
                return -1;
            }
        }

        public int DeleteContentSetting(string strKey)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("DeleteContentSetting");

                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@Key", DbType.String, strKey);

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
