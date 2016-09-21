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
        public Int16? TaskPriority;

    }
}
