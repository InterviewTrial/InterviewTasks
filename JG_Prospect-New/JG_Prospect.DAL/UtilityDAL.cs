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
        public void AddException(string pageUrl, string loginID, string exMsg, string exTrace) //, int productTypeId, int estimateId)
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
    }
}
