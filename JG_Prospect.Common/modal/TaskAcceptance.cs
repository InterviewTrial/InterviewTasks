using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace JG_Prospect.Common.modal
{
    public class TaskAcceptance
    {
        public Int64 Id { get; set; }
        public Int64 TaskId { get; set; }
        public Int64 UserId { get; set; }
        public bool IsInstallUser { get; set; }
        public bool IsAccepted { get; set; }
        public DateTime DateCreated { get; set; }

        public bool Username { get; set; }
        public bool UserFirstName { get; set; }
        public bool UserLastName { get; set; }
        public bool UserEmail { get; set; }
    }
}
