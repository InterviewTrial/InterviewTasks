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
    }
}