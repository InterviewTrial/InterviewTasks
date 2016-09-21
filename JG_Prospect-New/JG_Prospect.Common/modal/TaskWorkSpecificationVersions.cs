using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace JG_Prospect.Common.modal
{
    public class TaskWorkSpecificationVersions
    {
        public Int64 Id { get; set; }
        public Int64 TaskWorkSpecificationId { get; set; }
        public Int32 UserId { get; set; }
        public bool IsInstallUser { get; set; }
        public string Content { get; set; }
        public bool Status { get; set; }
        public DateTime DateCreated { get; set; }
        public TaskWorkSpecification TaskWorkSpecification { get; set; }
    }
}
