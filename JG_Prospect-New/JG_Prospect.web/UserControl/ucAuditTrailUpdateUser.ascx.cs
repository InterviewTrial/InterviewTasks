using JG_Prospect.BLL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace JG_Prospect.UserControl
{
    public partial class ucAuditTrailUpdateUser : System.Web.UI.UserControl
    {
        #region '--Properties & variables --'

        public string UserLoginID { get; set; }

        public DataSet ucDataSour { get; set; }

        #endregion
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        public void BindUserData()
        {
            if (UserLoginID != null && UserLoginID.Trim() != string.Empty)
            {
                if (ucDataSour == null)
                {
                    ucDataSour = UserAuditTrailBLL.Instance.GetUpdateUserAuditsTrailLstByLoginID(UserLoginID);
                }

                if(ucDataSour != null)
                    if (ucDataSour.Tables[0].Rows.Count > 0)
                    {
                        grdAuditUserListing.DataSource = ucDataSour;
                        grdAuditUserListing.DataBind();
                        pnlAuditUserData.Visible = true;
                    }
                else
                        pnlAuditUserData.Visible = false;
                     
            }
            else
            {
                pnlAuditUserData.Visible = false;
            }
                
        }
    }
}