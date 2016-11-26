using System.Data;
using JG_Prospect.DAL;
using JG_Prospect.Common.modal;

namespace JG_Prospect.BLL
{
    public class DepartmentBLL
    {
        private static DepartmentBLL m_DepartmentBLL = new DepartmentBLL();

        private DepartmentBLL()
        {

        }

        public static DepartmentBLL Instance
        {
            get { return m_DepartmentBLL; }
            set {; }
        }

        public DataSet GetAllDepartment()
        {
            return DepartmentDAL.Instance.GetDepartmentsByFilter(0);
        }

        public DataSet GetDepartmentByID(int? DepartmentID)
        {
            return DepartmentDAL.Instance.GetDepartmentsByFilter(DepartmentID);
        }

        public int DepartmentInsertUpdate(Department objDep)
        {
            return DepartmentDAL.Instance.DepartmentInsertUpdate(objDep);
        }
    }
}
