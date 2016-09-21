using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace JG_Prospect.Common.modal
{
    public class TaskWorkSpecification
    {
        public TaskWorkSpecification()
        {
            this.TaskWorkSpecificationVersions = new List<TaskWorkSpecificationVersions>();
        }

        public Int64 Id { get; set; }
        public Int64 TaskId { get; set; }
        public List<TaskWorkSpecificationVersions> TaskWorkSpecificationVersions { get; set; }
    }
}
