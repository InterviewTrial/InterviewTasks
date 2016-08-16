using JG_Prospect.DAL;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace JG_Prospect.BLL
{
    public class UtilityBAL
    {
        public static void AddException(string pageUrl, string loginID, string exMsg, string exTrace) //, int productTypeId, int estimateId)
        {
            UtilityDAL obj = new UtilityDAL();
            obj.AddException(pageUrl, loginID, exMsg, exTrace);
        }
    }
}
