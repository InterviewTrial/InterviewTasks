using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace JG_Prospect.UserControl
{
    public partial class ucStatusChangePopup : System.Web.UI.UserControl
    {
        public string ucPopUpMsg { get; set; }
        public string ucPopUpHeader { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (ucPopUpMsg == null ||ucPopUpMsg.Trim() == string.Empty )
            {
                lblMsg.Text = "<h2 style='margin - top:25px'><i>Soon we are coming up with more functionality...!</i></h2>";
                lblHeader.Text = "<h3>Status Changed</h3>";
            }
            else if (ucPopUpMsg.Trim() == string.Empty)
            {
                lblMsg.Text = "<h2 style='margin - top:25px'><i>Soon we are coming up with more functionality...!</i></h2>";
                lblHeader.Text = "<h3>Status Changed</h3>";
            }
            else
            {
                if (ucPopUpHeader.Trim() != string.Empty)
                {
                    lblHeader.Text = "<h3>Information</h3>";
                }
                lblMsg.Text = "<h2 style='margin - top:25px'><i>" + ucPopUpMsg + "</i></h2>";
            }
        }

        public void changeText()
        {
            if (ucPopUpHeader == null || ucPopUpHeader == string.Empty)
            {
                lblHeader.Text = "<h1>Information</h1>";
            }

            lblMsg.Text = "<h2 style='margin - top:35px'><i>" + ucPopUpMsg + "</i></h2>";
        }
    }
}