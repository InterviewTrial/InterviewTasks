using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using JG_Prospect.Common.modal;
using JG_Prospect.DAL;
using System.Data;

namespace JG_Prospect.BLL
{
    public class UserAuditTrailBLL
    {
        private static UserAuditTrailBLL m_UserAuditTrailBLL = new UserAuditTrailBLL();

        private UserAuditTrailBLL()
        {
        }

        public static UserAuditTrailBLL Instance
        {
            get { return m_UserAuditTrailBLL; }
            set {; }
        }

        public void AddUpdateUserAuditTrailRecord(UserAuditTrail objUserAudit)
        {
             UserAuditTrailDAL.Instance.AddUpdateUserAuditTrailRecord(objUserAudit);
        }

        public void UpdateUserLogOutTime(UserAuditTrail objUserAudit)
        {
            UserAuditTrailDAL.Instance.UpdateUserLogOutTime(objUserAudit);
        }

        public DataSet GetAuditsTrailLstByLoginID(string userLoginID)
        {
           return  UserAuditTrailDAL.Instance.GetAuditsTrailLstByLoginID(userLoginID);
        }
    }
}
