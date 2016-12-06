using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace JG_Prospect.Common.modal
{
    [Serializable]
    public partial class TaskWorkSpecification
    {
        public TaskWorkSpecification()
        {
            TaskWorkSpecifications = new List<TaskWorkSpecification>();
        }

        public List<TaskWorkSpecification> TaskWorkSpecifications;

        public int TaskWorkSpecificationsCount { get; set; }

        public long Id { get; set; }
        public long? ParentTaskWorkSpecificationId { get; set; }
        public string CustomId { get; set; }
        public long TaskId { get; set; }
        public string Description { get; set; }
        public string Title { get; set; }
        public string URL { get; set; }
        public int? AdminUserId { get; set; }
        public int? TechLeadUserId { get; set; }
        public int? OtherUserId { get; set; }
        public bool? IsAdminInstallUser { get; set; }
        public bool? IsTechLeadInstallUser { get; set; }
        public bool? IsOtherUserInstallUser { get; set; }
        public bool AdminStatus { get; set; }
        public bool TechLeadStatus { get; set; }
        public bool OtherUserStatus { get; set; }
        public DateTime DateCreated { get; set; }
        public DateTime DateUpdated { get; set; }
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
