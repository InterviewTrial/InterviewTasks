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
    public class DesignationDAL
    {
        private static DesignationDAL m_DesignationDAL = new DesignationDAL();
        public static DesignationDAL Instance
        {
            get { return m_DesignationDAL; }
            private set {; }
        }

        private DataSet returndata;

        public DataSet GetAllDesignationsForHumanResource()
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    returndata = new DataSet();
                    DbCommand command = database.GetStoredProcCommand("UDP_GetAllDesignationsForHumanResource");
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

        public DataSet GetDesignationByFilter(int? DesignationID, int? DepartmentID)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    returndata = new DataSet();
                    DbCommand command = database.GetStoredProcCommand("UDP_GetDesignationByFilter");
                    database.AddInParameter(command, "@DepartmentID", DbType.Int32, DepartmentID);
                    database.AddInParameter(command, "@DesignationID", DbType.Int32, DesignationID);
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

        public int DesignationInsertUpdate(Designation objDec)
        {
            int result = JGConstant.RETURN_ZERO;
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UDP_DesignationInsertUpdate");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@ID", DbType.Int32, objDec.ID);
                    database.AddInParameter(command, "@DesignationName", DbType.String, objDec.DesignationName);
                    database.AddInParameter(command, "@IsActive", DbType.Boolean, objDec.IsActive);
                    database.AddInParameter(command, "@DepartmentID", DbType.Int16, objDec.DepartmentID);
                    database.AddOutParameter(command, "@result", DbType.Int16, result);
                    database.ExecuteNonQuery(command);
                    result = Convert.ToInt32(database.GetParameterValue(command, "@result"));
                    return result;
                }
            }
            catch (Exception ex)
            {
                return result;
            }
        }
    }
}