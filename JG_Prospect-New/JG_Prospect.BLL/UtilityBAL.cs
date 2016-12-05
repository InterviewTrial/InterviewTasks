using JG_Prospect.DAL;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace JG_Prospect.BLL
{
    public class UtilityBAL
    {

        private static UtilityBAL m_UtilityBAL = new UtilityBAL();

        private UtilityBAL()
        {

        }

        public static UtilityBAL Instance
        {
            get { return m_UtilityBAL; }
            set { ; }
        }

        public static void AddException(string pageUrl, string loginID, string exMsg, string exTrace) //, int productTypeId, int estimateId)
        {
            UtilityDAL.Instance.AddException(pageUrl, loginID, exMsg, exTrace);
        }

        #region Content Settings

        public string GetContentSetting(string strKey)
        {
            return UtilityDAL.Instance.GetContentSetting(strKey);
        }

        public int InsertContentSetting(string strKey, string strValue)
        {
            return UtilityDAL.Instance.InsertContentSetting(strKey, strValue);
        }

        public int UpdateContentSetting(string strKey, string strValue)
        {
            return UtilityDAL.Instance.UpdateContentSetting(strKey, strValue);
        }

        public int DeleteContentSetting(string strKey)
        {
            return UtilityDAL.Instance.DeleteContentSetting(strKey);
        } 

        #endregion
    }
}
