using JG_Prospect.BLL;
using JG_Prospect.Common.modal;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Configuration;
using System.Web;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Net;
using System.Net.Mail;
using JG_Prospect.Common.Logger;

namespace JG_Prospect.Sr_App
{
    public partial class home : System.Web.UI.Page
    {
        ErrorLog logManager = new ErrorLog();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Session["AppType"] = "SrApp";
                if ((string)Session["usertype"] == "SM" || (string)Session["usertype"] == "SSE" || (string)Session["usertype"] == "MM")
                {
                    li_AnnualCalender.Visible = true;
                }
                if ((string)Session["usertype"] == "Admin")
                {
                    pnlTestEmail.Visible = true;
                }
            }
        }

        [System.Web.Services.WebMethod]
        public static string GetAllScripts(string strScriptId)
        {
            DataSet ds = new DataSet();
            int? intScriptId = Convert.ToInt32(strScriptId);
            if (strScriptId == "0")
                intScriptId = null;
            ds = UserBLL.Instance.fetchAllScripts(intScriptId); ;
            if (ds != null)
            {
                if (ds.Tables[0].Rows.Count > 0)
                {
                    return JsonConvert.SerializeObject(ds.Tables[0]);
                }
                else
                {
                    return string.Empty;
                }
            }
            else
                return string.Empty;
        }

        [System.Web.Services.WebMethod]
        public static string ManageScripts(string intMode, string intScriptId, string strScriptName, string strScriptDescription)
        {
            DataSet ds = new DataSet();
            PhoneDashboard objPhoneDashboard = new PhoneDashboard();
            objPhoneDashboard.intMode = Convert.ToInt32(intMode);
            objPhoneDashboard.intScriptId = Convert.ToInt32(intScriptId);
            objPhoneDashboard.strScriptName = strScriptName;
            objPhoneDashboard.strScriptDescription = strScriptDescription;

            ds = UserBLL.Instance.manageScripts(objPhoneDashboard);
            if (ds != null)
            {
                if (ds.Tables[0].Rows.Count > 0)
                {
                    return JsonConvert.SerializeObject(ds.Tables[0]);
                }
                else
                {
                    return string.Empty;
                }
            }
            else
                return string.Empty;
        }

        protected void btnTestMail_Click(object sender, EventArgs e)
        {
            if (txtTestEmail.Text != "")
                SendEmail(txtTestEmail.Text);
        }

        private void SendEmail(string emailId)
        {
            try
            {
                string strHeader = "<div>Email Header</div>";
                string strBody = "<div>Email Body</div>";
                string strFooter = "<div>Email Footer</div>";
                string strsubject = "Subject - test mail";

                string userName = ConfigurationManager.AppSettings["VendorCategoryUserName"].ToString();
                string password = ConfigurationManager.AppSettings["VendorCategoryPassword"].ToString();

                StringBuilder Body = new StringBuilder();
                MailMessage Msg = new MailMessage();
                Msg.From = new MailAddress(userName, "JGrove Construction");
                Msg.To.Add(emailId);
                //Msg.Bcc.Add(new MailAddress("shabbir.kanchwala@straitapps.com", "Shabbir Kanchwala"));
                //Msg.CC.Add(new MailAddress("jgrove.georgegrove@gmail.com", "Justin Grove"));

                Msg.Subject = strsubject;// "JG Prospect Notification";
                Body.Append(strHeader);
                Body.Append(strBody);
                Body.Append(strFooter);

                Msg.Body = Convert.ToString(Body);
                Msg.IsBodyHtml = true;// your remote SMTP server IP

                SmtpClient sc = new SmtpClient(ConfigurationManager.AppSettings["smtpHost"].ToString(), Convert.ToInt32(ConfigurationManager.AppSettings["smtpPort"].ToString()));

                NetworkCredential ntw = new System.Net.NetworkCredential(userName, password);
                sc.UseDefaultCredentials = false;
                sc.Credentials = ntw;

                sc.DeliveryMethod = SmtpDeliveryMethod.Network;
                sc.EnableSsl = Convert.ToBoolean(ConfigurationManager.AppSettings["enableSSL"].ToString()); // runtime encrypt the SMTP communications using SSL
                try
                {
                    sc.Send(Msg);
                }
                catch (Exception ex)
                {
                    lblMessage.Text = "failure";
                    logManager.writeToLog(ex, "Home", Request.ServerVariables["remote_addr"].ToString());
                }

                Msg = null;
                sc.Dispose();
                sc = null;
                lblMessage.Text = "Successfully Sent to " + emailId;
                txtTestEmail.Text = "";
            }
            catch (Exception ex)
            {
                lblMessage.Text = "failure";
                logManager.writeToLog(ex, "Home", Request.ServerVariables["remote_addr"].ToString());
            }
        }

    }
}