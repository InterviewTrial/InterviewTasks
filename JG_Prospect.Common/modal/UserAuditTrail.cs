using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace JG_Prospect.Common.modal
{
    public class UserAuditTrail
    {
        public int AuditID { get; set; }
        public int UserID { get; set; }
        public string UserLoginID { get; set; }
        public string Description { get; set; }
        public DateTime CurrentActionTime { get; set; }
        public DateTime LogOutTime { get; set; }
        public string LogInGuID { get; set; }
    }
}
