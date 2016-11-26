using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.Common;
using Microsoft.Practices.EnterpriseLibrary.Data.Sql;
using System.Data.SqlClient;
using JG_Prospect.DAL.Database;
using JG_Prospect.Common;
using JG_Prospect.Common.modal;
using System.Configuration;

namespace JG_Prospect.DAL
{
    public class DepartmentDAL
    {
        private static DepartmentDAL m_DepartmentDAL = new DepartmentDAL();
        public static DepartmentDAL Instance
        {
            get { return m_DepartmentDAL; }
            private set {; }
        }

        private DataSet returndata;

        public DataSet GetDepartmentsByFilter(int? DepartmentID)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    returndata = new DataSet();
                    DbCommand command = database.GetStoredProcCommand("UDP_GetDepartmentsByFilter");
                    database.AddInParameter(command, "@DepId", DbType.Int32, DepartmentID);
                    command.CommandType = CommandType.StoredProcedure;
                    returndata = database.ExecuteDataSet(command);
                    return returndata;
                }
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        public int DepartmentInsertUpdate(Department objDep)
        {
            int result = JGConstant.RETURN_ZERO;
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UDP_DepartmentInsertUpdate");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@ID", DbType.Int32, objDep.ID);
                    database.AddInParameter(command, "@DepartmentName", DbType.String, objDep.DepartmentName);
                    database.AddInParameter(command, "@IsActive", DbType.Boolean, objDep.IsActive);
                    database.AddOutParameter(command, "@result", DbType.Int16, result);
                    database.ExecuteNonQuery(command);
                    result = Convert.ToInt32(database.GetParameterValue(command, "@result"));
                    return result;
                }
            }
            catch(Exception ex)
            {
                return result;
            }
        }
    }
}
