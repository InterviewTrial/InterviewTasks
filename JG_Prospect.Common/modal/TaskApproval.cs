using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace JG_Prospect.Common.modal
{
    [Serializable]
    public partial class TaskApproval
    {
        public long Id { get; set; }
        public long TaskId { get; set; }
        public string Description { get; set; }
        public string EstimatedHours { get; set; }
        public int? UserId { get; set; }
        public bool? IsInstallUser { get; set; }
        public DateTime DateCreated { get; set; }
        public DateTime DateUpdated { get; set; }
    }
}
