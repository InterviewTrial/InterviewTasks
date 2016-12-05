using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;

namespace JG_Prospect.Common.modal
{
    [Serializable]
    public class Task
    {
        public int Mode;
        public int TaskId;
        public string Title;
        public string Description;
        public int Status;
        public string DueDate;
        public string Hours;
        public string Notes;
        public string Attachment;
        public int CreatedBy;
        public string CreatedOn;
        public string InstallId;
        public int? ParentTaskId;
        public Int16? TaskType;
        public byte? TaskPriority;
        public bool IsTechTask;

        public int? AdminUserId { get; set; }
        public int? TechLeadUserId { get; set; }
        public int? OtherUserId { get; set; }
        public bool? IsAdminInstallUser { get; set; }
        public bool? IsTechLeadInstallUser { get; set; }
        public bool? IsOtherUserInstallUser { get; set; }
        public bool AdminStatus { get; set; }
        public bool TechLeadStatus { get; set; }
        public bool OtherUserStatus { get; set; }
        public DateTime? AdminStatusUpdated { get; set; }
        public DateTime? TechLeadStatusUpdated { get; set; }
        public DateTime? OtherUserStatusUpdated { get; set; }
        public string AdminUsername { get; set; }
        public string AdminUserFirstname { get; set; }
        public string AdminUserLastname { get; set; }
        public string AdminUserEmail { get; set; }
        public string TechLeadUsername { get; set; }
        public string TechLeadUserFirstname { get; set; }
        public string TechLeadUserLastname { get; set; }
        public string TechLeadUserEmail { get; set; }
        public string OtherUsername { get; set; }
        public string OtherUserFirstname { get; set; }
        public string OtherUserLastname { get; set; }
        public string OtherUserEmail { get; set; }
    }
}
