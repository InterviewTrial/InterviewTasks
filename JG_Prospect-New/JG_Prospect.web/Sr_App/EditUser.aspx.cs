using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using JG_Prospect.BLL;
using JG_Prospect.Common;
using JG_Prospect.Common.modal;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Data.OleDb;
using System.Text;
using Word = Microsoft.Office.Interop.Word;
using System.Net;
using System.Net.Mail;
using System.Web.UI.DataVisualization.Charting;
using System.Xml.Serialization;
using System.Xml;
using JG_Prospect.App_Code;

namespace JG_Prospect
{
    #region '--Enums--'

    enum OrderStatus1
    {
        OfferMade = 0,
        InterviewScreened,
        InterviewDate,
        Applicant,
        InstallProspect,
        PhoneScreened,
        Active,
        Deactive,
        Rejected,
        Deleted
    }

    enum OrderStatus2
    {
        Applicant = 0,
        InstallProspect,
        InterviewDate,
        PhoneScreened,
        OfferMade,
        InterviewScreened,
        Active,
        Deactive,
        Rejected
    }

    public class HrData
    {
        public string status { get; set; }
        public string count { get; set; }
    }

    #endregion

    public partial class EditUser : System.Web.UI.Page
    {

        #region '--Members--'

        #endregion

        #region '--Properties--'

        public SortDirection dir
        {
            get
            {
                if (ViewState["dirState"] == null)
                {
                    ViewState["dirState"] = SortDirection.Ascending;
                }
                return (SortDirection)ViewState["dirState"];
            }
            set
            {
                ViewState["dirState"] = value;
            }
        }

        #endregion

        #region '--Page Events--'

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["Username"] == null)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Your session has expired,login to contineu');window.location='../login.aspx?returnurl=" + Request.Url.PathAndQuery + "'", true);
            }

            if (Convert.ToString(Session["usertype"]).Contains("Admin"))
            {
                btnExport.Visible = true;
            }
            else
            {
                btnExport.Visible = false;
            }
            if (!IsPostBack)
            {
                CalendarExtender1.StartDate = DateTime.Now;
                Session["DeactivationStatus"] = "";
                Session["FirstNameNewSC"] = "";
                Session["LastNameNewSC"] = "";
                Session["DesignitionSC"] = "";
                binddata();
                DataSet dsCurrentPeriod = UserBLL.Instance.Getcurrentperioddates();
                //bindPayPeriod(dsCurrentPeriod);
                FillCustomer();
                txtfrmdate.Text = DateTime.Now.AddDays(-14).ToString("MM/dd/yyyy");
                txtTodate.Text = DateTime.Now.ToString("MM/dd/yyyy");
                ShowHRData();
            }
        }

        #endregion

        #region '--Control Events--'

        #region grdUsers - Filters

        protected void ddlFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindGrid();
        }

        protected void txtfrmdate_TextChanged(object sender, EventArgs e)
        {
            ShowHRData();
        }

        protected void txtTodate_TextChanged(object sender, EventArgs e)
        {
            ShowHRData();
        }

        #endregion

        #region grdUsers - User List

        protected void grdUsers_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            grdUsers.EditIndex = -1;
            // binddata();
        }

        protected void grdUsers_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            try
            {
                string key = grdUsers.DataKeys[e.RowIndex].Values[0].ToString();
                bool result = InstallUserBLL.Instance.DeleteInstallUser(Convert.ToInt32(key));
                binddata();

                if (result)
                {
                    //    lblmsg.Visible = true;
                    //    lblmsg.CssClass = "success";
                    //    lblmsg.Text = "User has been deleted successfully";
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "AlertBox", "alert('User Deleted Successfully');", true);
                }
            }
            catch (Exception ex)
            {
                //return ex
            }
        }

        protected void grdUsers_RowEditing(object sender, GridViewEditEventArgs e)
        {
            grdUsers.EditIndex = e.NewEditIndex;
            binddata();
        }

        protected void grdUsers_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {

        }

        protected void grdUsers_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            try
            {
                if (e.Row.RowType == DataControlRowType.DataRow)
                {
                    DropDownList ddlStatus = (e.Row.FindControl("ddlStatus") as DropDownList);//Find the DropDownList in the Row                    
                    string Status = Convert.ToString((e.Row.FindControl("lblStatus") as HiddenField).Value);//Select the status in DropDownList
                    string orderStatus = Convert.ToString((e.Row.FindControl("lblOrderStatus") as HiddenField).Value);

                    if (Status != "")
                    {
                        ddlStatus.Items.FindByValue(Status).Selected = true;

                        switch (Status)
                        {
                            case "Applicant":
                                {
                                    e.Row.Attributes["style"] = "background-color: #FFFF00";
                                    break;
                                }
                            case "InstallProspect":
                            case "Install Prospect":
                                {
                                    e.Row.Attributes["style"] = "background-color: #FFA500";
                                    break;
                                }
                            case "Rejected":
                                {
                                    e.Row.Attributes["style"] = "background-color: #AEAEAE";
                                    break;
                                }
                            case "Deleted":
                                {
                                    e.Row.Attributes["style"] = "background-color: #565656";
                                    break;
                                }
                            default:
                                break;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Response.Write("" + ex.Message);
            }
        }

        protected void grdUsers_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        protected void grdUsers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string str = ConfigurationManager.ConnectionStrings["JGPA"].ConnectionString;
            SqlConnection con = new SqlConnection(str);
            if (e.CommandName == "Edit")
            {
                GridViewRow row = (GridViewRow)((Control)e.CommandSource).NamingContainer;
                int index = row.RowIndex;
                Label desig = (Label)(grdUsers.Rows[index].Cells[4].FindControl("lblDesignation"));
                string designation = desig.Text;
                string ID1 = e.CommandArgument.ToString();
                con.Open();
                SqlCommand cmd = new SqlCommand("select Usertype from tblInstallUsers where Id='" + ID1 + "' ", con);
                SqlDataReader rdr = cmd.ExecuteReader();
                string type = "";
                while (rdr.Read())
                {
                    type = rdr[0].ToString();

                }
                con.Close();
                //if (designation != "SubContractor" && type != "Sales")
                //{
                //    string ID = e.CommandArgument.ToString();
                //    Response.Redirect("InstallCreateUser.aspx?id=" + ID);
                //}
                //else if (designation == "SubContractor" && type != "Sales")
                //{
                //    string ID = e.CommandArgument.ToString();
                //    Response.Redirect("InstallCreateUser2.aspx?id=" + ID);
                //}
                //else if (type == "Sales")
                //{
                string ID = e.CommandArgument.ToString();
                Response.Redirect("CreateSalesUser.aspx?id=" + ID);
                //}

            }
            else if (e.CommandName == "Delete")
            {
                int id = Convert.ToInt32(e.CommandArgument.ToString());
                InstallUserBLL.Instance.DeleteInstallUser(id);
            }
            else if (e.CommandName == "ShowPicture")
            {
                string ImagePath = "";
                string ImageName = e.CommandArgument.ToString();
                ImagePath = "UploadedFile/" + Path.GetFileName(ImageName);
                img_InstallerImage.ImageUrl = ImagePath;
                mp1.Show();
            }
            else if (e.CommandName == "ChangeStatus")
            {
                GridViewRow gvRow = (GridViewRow)((Control)e.CommandSource).NamingContainer;
                int Index = gvRow.RowIndex;
                DropDownList ddlStatus = (DropDownList)gvRow.FindControl("ddlStatus");
                int StatusId = Convert.ToInt32(e.CommandArgument);
                string Status = ddlStatus.SelectedValue;
                bool result = InstallUserBLL.Instance.UpdateInstallUserStatus(Status, StatusId);
            }

        }

        protected void grdUsers_Sorting(object sender, GridViewSortEventArgs e)
        {
            binddata();
            DataTable dt = new DataTable();
            dt = (DataTable)(Session["UserGridData"]);
            {
                string SortDir = string.Empty;
                if (dir == SortDirection.Ascending)
                {
                    dir = SortDirection.Descending;
                    SortDir = "Desc";
                }
                else
                {
                    dir = SortDirection.Ascending;
                    SortDir = "Asc";
                }
                DataView sortedView = new DataView(dt);
                sortedView.Sort = e.SortExpression + " " + SortDir;
                grdUsers.DataSource = sortedView;
                grdUsers.DataBind();
            }
        }

        protected void grdUsers_ddlStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
            //Below 4 lines is to get that particular row control values
            DropDownList ddlNew = sender as DropDownList;
            string strddlNew = ddlNew.SelectedValue;
            GridViewRow grow = (GridViewRow)((Control)sender).NamingContainer;
            Label lblDesignation = (Label)(grow.FindControl("lblDesignation"));
            Label lblFirstName = (Label)(grow.FindControl("lblFirstName"));
            Label lblLastName = (Label)(grow.FindControl("lblLastName"));
            Label lblEmail = (Label)(grow.FindControl("lblEmail"));
            HiddenField lblStatus = (HiddenField)(grow.FindControl("lblStatus"));
            Label Id = (Label)grow.FindControl("lblid");
            DropDownList ddl = (DropDownList)grow.FindControl("ddlStatus");
            Session["EditId"] = Id.Text;
            Session["EditStatus"] = ddl.SelectedValue;
            Session["DesignitionSC"] = lblDesignation.Text;
            Session["FirstNameNewSC"] = lblFirstName.Text;
            Session["LastNameNewSC"] = lblLastName.Text;
            if ((lblStatus.Value == "Active") && (!(Convert.ToString(Session["usertype"]).Contains("Admin")) && !(Convert.ToString(Session["usertype"]).Contains("SM"))))
            {
                binddata();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('You dont have rights change the status.')", true);
                return;
            }
            else if ((lblStatus.Value == "Active" && ddl.SelectedValue != "Deactive") && ((Convert.ToString(Session["usertype"]).Contains("Admin")) || (Convert.ToString(Session["usertype"]).Contains("SM"))))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "Overlay", "overlayPassword();", true);
                return;
            }
            bool status = CheckRequiredFields(ddl.SelectedValue, Convert.ToInt32(Id.Text));
            if (!status)
            {
                if (ddl.SelectedValue == "Offer Made" || ddl.SelectedValue == "OfferMade")
                {
                    hdnFirstName.Value = lblFirstName.Text;
                    hdnLastName.Value = lblLastName.Text;
                    txtEmail.Text = lblEmail.Text;
                    txtPassword1.Attributes.Add("value", "jmgrove");
                    txtpassword2.Attributes.Add("value", "jmgrove");
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "Overlay", "OverlayPopupOfferMade();", true);
                    return;
                }
                else
                {
                    binddata();
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Status cannot be changed as required field for selected status are not field')", true);
                    return;
                }
            }

            if ((ddl.SelectedValue == "Active" || ddl.SelectedValue == "Deactive") && (!(Convert.ToString(Session["usertype"]).Contains("Admin")) && !(Convert.ToString(Session["usertype"]).Contains("SM"))))
            {
                ddl.SelectedValue = Convert.ToString(lblStatus.Value);
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('You dont have permission to Activate or Deactivate user')", true);
                return;
            }
            else if (ddl.SelectedValue == "Rejected")
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "Overlay", "overlay()", true);
                return;
            }
            else if (ddl.SelectedValue == "InterviewDate")
            {
                LoadUsersByRecruiterDesgination();
                FillTechTaskDropDown();
                ddlInsteviewtime.DataSource = GetTimeIntervals();
                ddlInsteviewtime.DataBind();
                dtInterviewDate.Text = DateTime.Now.AddDays(1).ToShortDateString();
                ddlInsteviewtime.SelectedValue = "10:00 AM";
                ScriptManager.RegisterStartupScript(this, this.GetType(), "Overlay", "overlayInterviewDate()", true);
                return;
            }
            else if (ddl.SelectedValue == "Deactive" && ((Convert.ToString(Session["usertype"]).Contains("Admin")) && (Convert.ToString(Session["usertype"]).Contains("SM"))))
            {
                Session["DeactivationStatus"] = "Deactive";
                ScriptManager.RegisterStartupScript(this, this.GetType(), "Overlay", "overlay()", true);
                return;
            }
            else if (ddl.SelectedValue == "OfferMade")
            {
                txtEmail.Text = lblEmail.Text;
                txtPassword1.Attributes.Add("value", "jmgrove");
                txtpassword2.Attributes.Add("value", "jmgrove");
                ScriptManager.RegisterStartupScript(this, this.GetType(), "Overlay", "OverlayPopupOfferMade();", true);
                return;
                /*
                DataSet ds = new DataSet();
                string email = "";
                string HireDate = "";
                string EmpType = "";
                string PayRates = "";
                ds = InstallUserBLL.Instance.ChangeStatus(Convert.ToString(Session["EditStatus"]), Convert.ToInt32(Session["EditId"]), DateTime.Today.ToString("yyyy-MM-dd"), DateTime.Now.ToShortTimeString(), Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]), txtReason.Text);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        if (Convert.ToString(ds.Tables[0].Rows[0][0]) != "")
                        {
                            email = Convert.ToString(ds.Tables[0].Rows[0][0]);
                        }
                        if (Convert.ToString(ds.Tables[0].Rows[0][1]) != "")
                        {
                            HireDate = Convert.ToString(ds.Tables[0].Rows[0][1]);
                        }
                        if (Convert.ToString(ds.Tables[0].Rows[0][2]) != "")
                        {
                            EmpType = Convert.ToString(ds.Tables[0].Rows[0][2]);
                        }
                        if (Convert.ToString(ds.Tables[0].Rows[0][3]) != "")
                        {
                            PayRates = Convert.ToString(ds.Tables[0].Rows[0][3]);
                        }
                    }
                }
                SendEmail(email, lblFirstName.Text, lblLastName.Text, "Offer Made", txtReason.Text, lblDesignation.Text, HireDate, EmpType, PayRates, 105);
                binddata();
                return;
                */
            }

            if (lblStatus.Value == "Active" && (!(Convert.ToString(Session["usertype"]).Contains("Admin"))))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Status cannot be changed to any other status other than Deactive once user is Active')", true);
                if (Convert.ToString(Session["PreviousStatusNew"]) != "")
                {
                    ddl.SelectedValue = Convert.ToString(Session["PreviousStatusNew"]);
                }
                return;
            }
            else
            {
                // Adding a popUp...
                
                InstallUserBLL.Instance.ChangeStatus(Convert.ToString(Session["EditStatus"]), Convert.ToInt32(Session["EditId"]), Convert.ToString(DateTime.Today.ToShortDateString()), DateTime.Now.ToShortTimeString(), Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]), JGSession.IsInstallUser.Value, txtReason.Text);
                binddata();

                if ((ddl.SelectedValue == "Active") || (ddl.SelectedValue == "Deactive"))
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "Overlay", "showStatusChangePopUp()", true);
                return;
            }

            if (ddl.SelectedValue == "Install Prospect")
            {
                if (lblStatus.Value != "")
                {
                    ddl.SelectedValue = lblStatus.Value;
                }
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Status cannot be changed to Install Prospect')", true);
                return;
            }

            //else
            //{

            //    int StatusId = Convert.ToInt32(Id.Text);
            //    string Status = ddl.SelectedValue;
            //    //bool result = InstallUserBLL.Instance.UpdateInstallUserStatus(Status, StatusId);
            //    InstallUserBLL.Instance.ChangeStatus(Status, StatusId, Convert.ToString(DateTime.Today.ToShortDateString()), DateTime.Now.ToShortTimeString(), Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]));
            //}

            //call: updateStauts() function to update it in database.
        }

        #endregion

        #region grdUsers - Popups

        protected void btnChangeStatus_Click(object sender, EventArgs e)
        {
            int isvaliduser = 0;
            isvaliduser = UserBLL.Instance.chklogin(Convert.ToString(Session["loginid"]), txtPassword.Text);
            if (isvaliduser > 0)
            {
                InstallUserBLL.Instance.ChangeStatus(Convert.ToString(Session["EditStatus"]), Convert.ToInt32(Session["EditId"]), Convert.ToString(DateTime.Today.ToShortDateString()), DateTime.Now.ToShortTimeString(), Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]), JGSession.IsInstallUser.Value, txtReason.Text);
                binddata();
            }
        }

        protected void btnSaveReason_Click(object sender, EventArgs e)
        {
            if (Convert.ToString(Session["DeactivationStatus"]) == "Deactive")
            {
                DataSet ds = new DataSet();
                string email = "";
                string HireDate = "";
                string EmpType = "";
                string PayRates = "";
                ds = InstallUserBLL.Instance.ChangeStatus(Convert.ToString(Session["EditStatus"]), Convert.ToInt32(Session["EditId"]), DateTime.Today.ToString("yyyy-MM-dd"), DateTime.Now.ToShortTimeString(), Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]), JGSession.IsInstallUser.Value, txtReason.Text);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        if (Convert.ToString(ds.Tables[0].Rows[0][0]) != "")
                        {
                            email = Convert.ToString(ds.Tables[0].Rows[0][0]);
                        }
                        if (Convert.ToString(ds.Tables[0].Rows[0][1]) != "")
                        {
                            HireDate = Convert.ToString(ds.Tables[0].Rows[0][1]);
                        }
                        if (Convert.ToString(ds.Tables[0].Rows[0][2]) != "")
                        {
                            EmpType = Convert.ToString(ds.Tables[0].Rows[0][2]);
                        }
                        if (Convert.ToString(ds.Tables[0].Rows[0][3]) != "")
                        {
                            PayRates = Convert.ToString(ds.Tables[0].Rows[0][3]);
                        }
                    }
                }
                SendEmail(email, Convert.ToString(Session["FirstNameNewSC"]), Convert.ToString(Session["LastNameNewSC"]), "Deactivation", txtReason.Text, Convert.ToString(Session["DesignitionSC"]), HireDate, EmpType, PayRates, 0);
            }
            else
            {
                InstallUserBLL.Instance.ChangeStatus(Convert.ToString(Session["EditStatus"]), Convert.ToInt32(Session["EditId"]), Convert.ToString(DateTime.Today.ToShortDateString()), DateTime.Now.ToShortTimeString(), Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]), JGSession.IsInstallUser.Value, txtReason.Text);
                binddata();
            }
            ScriptManager.RegisterStartupScript(this, this.GetType(), "Overlay", "ClosePopup()", true);
            return;
        }

        protected void btnSaveInterview_Click(object sender, EventArgs e)
        {
            DataSet ds = new DataSet();
            string email = "";
            string HireDate = "";
            string EmpType = "";
            string PayRates = "";


            //string InterviewDate = dtInterviewDate.Text;
            DateTime interviewDate;
            DateTime.TryParse(dtInterviewDate.Text, out interviewDate);
            if (interviewDate == null)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "Overlay", "alert('Invalid Interview Date, Please verify');", true);
                return;
            }
            ds = InstallUserBLL.Instance.ChangeStatus(Convert.ToString(Session["EditStatus"]), Convert.ToInt32(Session["EditId"]), interviewDate.ToString("yyyy-MM-dd"), ddlInsteviewtime.SelectedItem.Text, Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]), JGSession.IsInstallUser.Value, txtReason.Text, ddlUsers.SelectedValue);
            if (ds.Tables.Count > 0)
            {
                if (ds.Tables[0].Rows.Count > 0)
                {
                    if (Convert.ToString(ds.Tables[0].Rows[0][0]) != "")
                    {
                        email = Convert.ToString(ds.Tables[0].Rows[0][0]);
                    }
                    if (Convert.ToString(ds.Tables[0].Rows[0][1]) != "")
                    {
                        HireDate = Convert.ToString(ds.Tables[0].Rows[0][1]);
                    }
                    if (Convert.ToString(ds.Tables[0].Rows[0][2]) != "")
                    {
                        EmpType = Convert.ToString(ds.Tables[0].Rows[0][2]);
                    }
                    if (Convert.ToString(ds.Tables[0].Rows[0][3]) != "")
                    {
                        PayRates = Convert.ToString(ds.Tables[0].Rows[0][3]);
                    }
                }
            }
            SendEmail(email, Convert.ToString(Session["FirstNameNewSC"]), Convert.ToString(Session["LastNameNewSC"]), "Interview Date Auto Email", txtReason.Text, Convert.ToString(Session["DesignitionSC"]), HireDate, EmpType, PayRates, 104);

            //AssignedTask if any or Default
			AssignedTaskToUser();

            Response.Redirect(JG_Prospect.Common.JGConstant.PG_PATH_MASTER_CALENDAR);

            //binddata();
            //ScriptManager.RegisterStartupScript(this, this.GetType(), "Overlay", "ClosePopupInterviewDate()", true);
            //return;
        }


        #region 'Private Methods - Assigned Task ToUser '

        private void AssignedTaskToUser()
        {
            string ApplicantId = Session["EditId"].ToString();

            //If dropdown has any value then assigned it to user else. return 
            if (ddlTechTask.Items.Count > 0)
            {
                // save (insert / delete) assigned users.
                //bool isSuccessful = TaskGeneratorBLL.Instance.SaveTaskAssignedUsers(Convert.ToUInt64(ddlTechTask.SelectedValue), Session["EditId"].ToString());

                // save assigned user a TASK.
                bool isSuccessful = TaskGeneratorBLL.Instance.SaveTaskAssignedToMultipleUsers(Convert.ToUInt64(ddlTechTask.SelectedValue), ApplicantId);

                // Change task status to assigned = 3.
                if (isSuccessful)
                    UpdateTaskStatus(Convert.ToInt32(ddlTechTask.SelectedValue), Convert.ToUInt16(TaskStatus.Assigned));
                
                if (ddlTechTask.SelectedValue != "" || ddlTechTask.SelectedValue != "0")
                    SendEmailToAssignedUsers(ApplicantId, ddlTechTask.SelectedValue);
            }
        }

        private void UpdateTaskStatus(Int32 taskId, UInt16 Status)
        {
            Task task = new Task();
            task.TaskId = taskId;
            task.Status = Status;

            int result = TaskGeneratorBLL.Instance.UpdateTaskStatus(task);    // save task master details
            
            //String AlertMsg;

            //if (result > 0)
            //{
            //    AlertMsg = "Status changed successfully!";
            //}
            //else
            //{
            //    AlertMsg = "Status change was not successfull, Please try again later.";
            //}
        }

        private void SendEmailToAssignedUsers(string strInstallUserIDs , string strTaskId)
        {
            try
            {
                string strHTMLTemplateName = "Task Generator Auto Email";
                DataSet dsEmailTemplate = AdminBLL.Instance.GetEmailTemplate(strHTMLTemplateName, 108);
                foreach (string userID in strInstallUserIDs.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
                {
                    DataSet dsUser = TaskGeneratorBLL.Instance.GetInstallUserDetails(Convert.ToInt32(userID));

                    string emailId = dsUser.Tables[0].Rows[0]["Email"].ToString();
                    string FName = dsUser.Tables[0].Rows[0]["FristName"].ToString();
                    string LName = dsUser.Tables[0].Rows[0]["LastName"].ToString();
                    string fullname = FName + " " + LName;

                    string strHeader = dsEmailTemplate.Tables[0].Rows[0]["HTMLHeader"].ToString();
                    string strBody = dsEmailTemplate.Tables[0].Rows[0]["HTMLBody"].ToString();
                    string strFooter = dsEmailTemplate.Tables[0].Rows[0]["HTMLFooter"].ToString();
                    string strsubject = dsEmailTemplate.Tables[0].Rows[0]["HTMLSubject"].ToString();

                    strBody = strBody.Replace("#Fname#", fullname);
                    strBody = strBody.Replace("#TaskLink#", string.Format("{0}?TaskId={1}", Request.Url.ToString().Split('?')[0], strTaskId));

                    strBody = strHeader + strBody + strFooter;

                    List<Attachment> lstAttachments = new List<Attachment>();
                    // your remote SMTP server IP.
                    for (int i = 0; i < dsEmailTemplate.Tables[1].Rows.Count; i++)
                    {
                        string sourceDir = Server.MapPath(dsEmailTemplate.Tables[1].Rows[i]["DocumentPath"].ToString());
                        if (File.Exists(sourceDir))
                        {
                            Attachment attachment = new Attachment(sourceDir);
                            attachment.Name = Path.GetFileName(sourceDir);
                            lstAttachments.Add(attachment);
                        }
                    }

                    CommonFunction.SendEmail(strHTMLTemplateName, emailId, strsubject, strBody, lstAttachments);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("{0} Exception caught.", ex);
            }
        }

        #endregion


        protected void btnCancelInterview_Click(object sender, EventArgs e)
        {
            binddata();
        }

        protected void btnSaveOfferMade_Click(object sender, EventArgs e)
        {
            int EditId = 0;
            int.TryParse(Convert.ToString(Session["EditId"]), out EditId);
            InstallUserBLL.Instance.UpdateOfferMade(EditId, txtEmail.Text, txtPassword1.Text);

            DataSet ds = new DataSet();
            string email = "";
            string HireDate = "";
            string EmpType = "";
            string PayRates = "";
            string Desig = "";
            ds = InstallUserBLL.Instance.ChangeStatus(Convert.ToString(Session["EditStatus"]), EditId, DateTime.Today.ToString("yyyy-MM-dd"), DateTime.Now.ToShortTimeString(), Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]), JGSession.IsInstallUser.Value, txtReason.Text);
            if (ds.Tables.Count > 0)
            {
                if (ds.Tables[0].Rows.Count > 0)
                {
                    if (Convert.ToString(ds.Tables[0].Rows[0][0]) != "")
                    {
                        email = Convert.ToString(ds.Tables[0].Rows[0][0]);
                    }
                    if (Convert.ToString(ds.Tables[0].Rows[0][1]) != "")
                    {
                        HireDate = Convert.ToString(ds.Tables[0].Rows[0][1]);
                    }
                    if (Convert.ToString(ds.Tables[0].Rows[0][2]) != "")
                    {
                        EmpType = Convert.ToString(ds.Tables[0].Rows[0][2]);
                    }
                    if (Convert.ToString(ds.Tables[0].Rows[0][3]) != "")
                    {
                        PayRates = Convert.ToString(ds.Tables[0].Rows[0][3]);
                    }
                    if (Convert.ToString(ds.Tables[0].Rows[0]["Designation"]) != "")
                    {
                        Desig = Convert.ToString(ds.Tables[0].Rows[0]["Designation"]);
                    }
                }
            }
            string strHtml = JG_Prospect.App_Code.CommonFunction.GetContractTemplateContent(199, 0, Desig);
            strHtml = strHtml.Replace("#CurrentDate#", DateTime.Now.ToShortDateString());
            strHtml = strHtml.Replace("#FirstName#", hdnFirstName.Value);
            strHtml = strHtml.Replace("#LastName#", hdnLastName.Value);
            strHtml = strHtml.Replace("#Address#", string.Empty);
            strHtml = strHtml.Replace("#Designation#", Desig);
            if (!string.IsNullOrEmpty(EmpType) && EmpType.Length > 1)
            {
                strHtml = strHtml.Replace("#EmpType#", EmpType);
            }
            else
            {
                strHtml = strHtml.Replace("#EmpType#", "________________");
            }
            strHtml = strHtml.Replace("#JoiningDate#", HireDate);
            if (!string.IsNullOrEmpty(PayRates))
            {
                strHtml = strHtml.Replace("#RatePerHour#", PayRates);
            }
            else
            {
                strHtml = strHtml.Replace("#RatePerHour#", "____");
            }
            DateTime dtPayCheckDate;
            if (!string.IsNullOrEmpty(HireDate))
            {
                dtPayCheckDate = Convert.ToDateTime(HireDate);
            }
            else
            {
                dtPayCheckDate = DateTime.Now;
            }
            dtPayCheckDate = new DateTime(dtPayCheckDate.Year, dtPayCheckDate.Month, DateTime.DaysInMonth(dtPayCheckDate.Year, dtPayCheckDate.Month));
            strHtml = strHtml.Replace("#PayCheckDate#", dtPayCheckDate.ToShortDateString());

            string strPath = JG_Prospect.App_Code.CommonFunction.ConvertHtmlToPdf(strHtml, Server.MapPath(@"~\Sr_App\MailDocument\MailAttachments\"), "Job acceptance letter");
            List<Attachment> lstAttachments = new List<Attachment>();
            if (File.Exists(strPath))
            {
                Attachment attachment = new Attachment(strPath);
                attachment.Name = Path.GetFileName(strPath);
                lstAttachments.Add(attachment);
            }
            SendEmail(email, hdnFirstName.Value, hdnLastName.Value, "Offer Made", txtReason.Text, Desig, HireDate, EmpType, PayRates, 105, lstAttachments);

            binddata();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "Overlay", "ClosePopupOfferMade()", true);
            return;
        }

        #endregion

        protected void btnUpload_Click(object sender, EventArgs e)
        {
            try
            {
                if (BulkProspectUploader.HasFile)
                {
                    string ext = Path.GetExtension(BulkProspectUploader.FileName);
                    if (ext == ".xls" || ext == ".xlsx")
                    {
                        string FileName = Path.GetFileName(BulkProspectUploader.PostedFile.FileName);
                        string Extension = Path.GetExtension(BulkProspectUploader.PostedFile.FileName);
                        string FolderPath = ConfigurationManager.AppSettings["FolderPath"];
                        string FilePath = Server.MapPath(FolderPath + FileName);
                        BulkProspectUploader.SaveAs(FilePath);
                        Import_To_Grid(FilePath, Extension);
                        binddata();
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Select xls or xlsx file')", true);
                    }
                }
            }
            catch (Exception ex)
            {
                UtilityBAL.AddException("EditUser-btnUpload_Click", Session["loginid"] == null ? "" : Session["loginid"].ToString(), ex.Message, ex.StackTrace);

            }
        }

        protected void btnExport_Click(object sender, EventArgs e)
        {/*
            Response.ClearContent();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", string.Format("attachment; filename={0}", "Users.xls"));
            Response.ContentType = "application/ms-excel";
            // DataSet ds = InstallUserBLL.Instance.getalluserdetails();
            DataTable dt = (DataTable)(Session["GridDataExport"]);
            // dt.Columns.Remove("PrimeryTradeId");
            // dt.Columns.Remove("SecondoryTradeId");
            string str = string.Empty;
            foreach (DataColumn dtcol in dt.Columns)
            {
                Response.Write(str + dtcol.ColumnName);
                str = "\t";
            }
            Response.Write("\n");
            foreach (DataRow dr in dt.Rows)
            {
                str = "";
                for (int j = 0; j < dt.Columns.Count; j++)
                {
                    Response.Write(str + Convert.ToString(dr[j]));
                    str = "\t";
                }
                Response.Write("\n");
            }
            Response.End();
          * */

            DataTable dt = (DataTable)(Session["GridDataExport"]);

            string filename = "SalesUser.xls";
            System.IO.StringWriter tw = new System.IO.StringWriter();
            System.Web.UI.HtmlTextWriter hw = new System.Web.UI.HtmlTextWriter(tw);
            DataGrid dgGrid = new DataGrid();
            dgGrid.DataSource = dt;
            dgGrid.DataBind();

            //Get the HTML for the control.
            dgGrid.RenderControl(hw);
            //Write the HTML back to the browser.
            //Response.ContentType = application/vnd.ms-excel;
            Response.ContentType = "application/vnd.ms-excel";
            Response.AppendHeader("Content-Disposition", "attachment; filename=" + filename + "");
            this.EnableViewState = false;
            string style = @"<style> .textmode { mso-number-format:\@; } </style>";
            Response.Write(style);
            Response.Write(tw.ToString());
            Response.End();
        }

        protected void btnYesEdit_Click(object sender, EventArgs e)
        {
            DataTable dt = (DataTable)Session["DuplicateUsers"];
            XmlDocument xmlDoc = new XmlDocument();
            CreateDuplicateUserObjectXml(dt, out xmlDoc);

            bool result = InstallUserBLL.Instance.BulkUpdateIntsallUser(xmlDoc.OuterXml);

            if (result)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "AlertBox", "alert('Data updated successfully!');ClosePopupUploadBulk();", true);
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "AlertBox", "alert('There is some error.');", true);
            }
        }

        protected void btnNoEdit_Click(object sender, EventArgs e)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "overlay", "ClosePopupUploadBulk();", true);
            return;
        }

        //protected void btnshow_Click(object sender, EventArgs e)
        //{
        //    DateTime fromDate = Convert.ToDateTime(txtfrmdate.Text, JG_Prospect.Common.JGConstant.CULTURE);
        //    DateTime toDate = Convert.ToDateTime(txtTodate.Text, JG_Prospect.Common.JGConstant.CULTURE);
        //    if (fromDate < toDate)
        //    {
        //        DataSet ds = InstallUserBLL.Instance.GetHrData(fromDate, toDate, Convert.ToInt16(drpUser.SelectedValue));
        //        if (ds != null)
        //        {
        //            DataTable dtHrData = ds.Tables[0];
        //            DataTable dtgridData = ds.Tables[1];
        //            List<HrData> lstHrData = new List<HrData>();
        //            foreach (DataRow row in dtHrData.Rows)
        //            {
        //                HrData hrdata = new HrData();
        //                hrdata.status = row["status"].ToString();
        //                hrdata.count = row["cnt"].ToString();
        //                lstHrData.Add(hrdata);
        //            }

        //            if (dtHrData.Rows.Count > 0)
        //            {

        //                var rowOfferMade = lstHrData.Where(r => r.status == "OfferMade").FirstOrDefault();
        //                if (rowOfferMade != null)
        //                {
        //                    string count = rowOfferMade.count;
        //                    lbljoboffercount.Text = count;
        //                }
        //                else
        //                {
        //                    lbljoboffercount.Text = "0";
        //                }
        //                var rowActive = lstHrData.Where(r => r.status == "Active").FirstOrDefault();
        //                if (rowActive != null)
        //                {
        //                    string count = rowActive.count;
        //                    lblActiveCount.Text = count;
        //                }
        //                else
        //                {
        //                    lblActiveCount.Text = "0";
        //                }
        //                var rowRejected = lstHrData.Where(r => r.status == "Rejected").FirstOrDefault();
        //                if (rowRejected != null)
        //                {
        //                    string count = rowRejected.count;
        //                    lblRejectedCount.Text = count;
        //                }
        //                else
        //                {
        //                    lblRejectedCount.Text = "0";
        //                }
        //                var rowDeactive = lstHrData.Where(r => r.status == "Deactive").FirstOrDefault();
        //                if (rowDeactive != null)
        //                {
        //                    string count = rowDeactive.count;
        //                    lblDeactivatedCount.Text = count;
        //                }
        //                else
        //                {
        //                    lblDeactivatedCount.Text = "0";
        //                }
        //                var rowInstallProspect = lstHrData.Where(r => r.status == "Install Prospect").FirstOrDefault();
        //                if (rowInstallProspect != null)
        //                {
        //                    string count = rowInstallProspect.count;
        //                    lblInstallProspectCount.Text = count;
        //                }
        //                else
        //                {
        //                    lblInstallProspectCount.Text = "0";
        //                }
        //                var rowPhoneScreened = lstHrData.Where(r => r.status == "PhoneScreened").FirstOrDefault();
        //                if (rowPhoneScreened != null)
        //                {
        //                    string count = rowPhoneScreened.count;
        //                    lblPhoneVideoScreenedCount.Text = count;
        //                }
        //                else
        //                {
        //                    lblPhoneVideoScreenedCount.Text = "0";
        //                }
        //                var rowInterviewDate = lstHrData.Where(r => r.status == "InterviewDate").FirstOrDefault();
        //                if (rowInterviewDate != null)
        //                {
        //                    string count = rowInterviewDate.count;
        //                    lblInterviewDateCount.Text = count;
        //                }
        //                else
        //                {
        //                    lblInterviewDateCount.Text = "0";
        //                }
        //                var rowApplicant = lstHrData.Where(r => r.status == "Applicant").FirstOrDefault();
        //                string Applicantcount = "0";
        //                if (rowApplicant != null)
        //                {
        //                    Applicantcount = rowApplicant.count;

        //                }
        //                else
        //                {
        //                    Applicantcount = "0";

        //                }
        //                // Ratio Calculation
        //                lblAppInterviewRatio.Text = Convert.ToString(Convert.ToDouble(lblInterviewDateCount.Text) / Convert.ToDouble(Applicantcount));
        //                //lblAppHireRatio.Text = Convert.ToString(Convert.ToDouble(lblActiveCount.Text) / Convert.ToDouble(Applicantcount));
        //                //lblJobOfferHireRatio.Text = Convert.ToString(Convert.ToDouble(lblActive.Text) / Convert.ToDouble(lblInterviewDateCount.Text));
        //            }
        //            else
        //            {
        //                lbljoboffercount.Text = "0";
        //                lblActiveCount.Text = "0";
        //                lblRejectedCount.Text = "0";
        //                lblDeactivatedCount.Text = "0";
        //                lblInstallProspectCount.Text = "0";
        //                lblPhoneVideoScreenedCount.Text = "0";
        //                lblInterviewDateCount.Text = "0";
        //                lblAppInterviewRatio.Text = "0";
        //                //lblAppHireRatio.Text = "0";
        //            }
        //            if (dtgridData.Rows.Count > 0)
        //            {
        //                Session["UserGridData"] = dtgridData;
        //                BindUsers(dtgridData);
        //                //grdUsers.DataSource = dtgridData;
        //                //grdUsers.DataBind();
        //            }
        //            else
        //            {
        //                Session["UserGridData"] = null;
        //                grdUsers.DataSource = null;
        //                grdUsers.DataBind();
        //            }
        //        }
        //    }
        //    else
        //    {
        //        ScriptManager.RegisterStartupScript(this, this.GetType(), "AlertBox", "alert('ToDate must be greater than FromDate');", true);
        //    }
        //}

        #endregion

        #region '--Methods--'

        private void BindUsers(DataTable dt)
        {
            try
            {
                string usertype = Session["usertype"].ToString().ToLower();

                if (dt.Columns["OrderStatus"] == null)
                {
                    dt.Columns.Add("OrderStatus");
                    int st = 0;

                    if (usertype == "jg account" || usertype == "sales manager" || usertype == "office manager" || usertype == "recruiter")
                    {
                        foreach (DataRow dr in dt.Rows)
                        {
                            st = (int)((OrderStatus1)Enum.Parse(typeof(OrderStatus1), dr["Status"].ToString().Replace(" ", "")));
                            dr["OrderStatus"] = st.ToString();
                        }
                    }
                    else if (usertype == "admin" || usertype == "jr. sales" || usertype == "project manager")
                    {
                        foreach (DataRow dr in dt.Rows)
                        {
                            st = (int)((OrderStatus2)Enum.Parse(typeof(OrderStatus2), dr["Status"].ToString().Replace(" ", "")));
                            dr["OrderStatus"] = st.ToString();
                        }
                    }
                }

                DataView dv = dt.DefaultView;
                dv.Sort = "OrderStatus asc";

                grdUsers.DataSource = dv;
                grdUsers.DataBind();
            }
            catch (Exception ex)
            {
                UtilityBAL.AddException("Edituser", Session["loginid"] == null ? "" : Session["loginid"].ToString(), ex.Message, ex.StackTrace);
            }
        }

        private void binddata()
        {
            DataSet DS = new DataSet();
            //DS = UserBLL.Instance.getallusers(usertype);
            DataSet ds = new DataSet();
            ds = InstallUserBLL.Instance.GetAllSalesUserToExport();
            DS = InstallUserBLL.Instance.GetAllEditSalesUser();

            BindPieChart(DS.Tables[0]);

            //DS.Tables[0].Columns[4].DataType = typeof(Int32);
            Session["GridDataExport"] = ds.Tables[0];
            Session["UserGridData"] = DS.Tables[0];

            BindUsers(DS.Tables[0]);
            //grdUsers.DataSource = DS.Tables[0];
            //grdUsers.DataBind();

            ddlDesignation.DataSource = (from ptrade in DS.Tables[0].AsEnumerable()
                                         where !string.IsNullOrEmpty(ptrade.Field<string>("Designation"))
                                         select Convert.ToString(ptrade["Designation"])).Distinct().ToList();
            ddlDesignation.DataBind();
            ddlDesignation.Items.Insert(0, "--All--");
        }

        private void FillCustomer()
        {
            DataSet dds = new DataSet();
            dds = new_customerBLL.Instance.GeUsersForDropDown();
            DataRow dr = dds.Tables[0].NewRow();
            dr["Id"] = "0";
            dr["Username"] = "--All--";
            dds.Tables[0].Rows.InsertAt(dr, 0);
            if (dds.Tables[0].Rows.Count > 0)
            {
                drpUser.DataSource = dds.Tables[0];
                drpUser.DataValueField = "Id";
                drpUser.DataTextField = "Username";
                drpUser.DataBind();
            }
            DataSet dsSource = new DataSet();
            dsSource = InstallUserBLL.Instance.GetSource();
            DataRow drSource = dsSource.Tables[0].NewRow();
            drSource["Id"] = "0";
            drSource["Source"] = "--All--";
            dsSource.Tables[0].Rows.InsertAt(drSource, 0);
            if (dsSource.Tables[0].Rows.Count > 0)
            {
                ddlSource.DataSource = dsSource.Tables[0];
                ddlSource.DataValueField = "Id";
                ddlSource.DataTextField = "Source";
                ddlSource.DataBind();
            }
        }

        protected void DownloadFile(object sender, EventArgs e)
        {
            string filePath = (sender as LinkButton).CommandArgument;
            Response.ContentType = ContentType;
            Response.AppendHeader("Content-Disposition", "attachment; filename=" + Path.GetFileName(filePath));
            Response.WriteFile(filePath);
            Response.End();
        }

        private string GetId(string Desig, string UserStatus)
        {
            string LastInt = "";
            DataTable dtId;
            string SalesId = string.Empty;
            dtId = InstallUserBLL.Instance.GetMaxSalesId(Desig);
            if (dtId.Rows.Count > 0)
            {
                SalesId = Convert.ToString(dtId.Rows[0][0]);
            }
            if ((Desig == "Admin" || Desig == "Office Manager" || Desig == "Recruiter") && (UserStatus != "Deactive"))
            {
                if (SalesId != "")
                {
                    LastInt = SalesId.Substring(SalesId.Length - 4);
                    SalesId = "ADM000" + Convert.ToString(Convert.ToInt32(LastInt) + 1);
                }
                else
                {
                    SalesId = "ADM0001";
                }
            }
            else if ((Desig == "Admin" || Desig == "Office Manager" || Desig == "Recruiter") && (UserStatus == "Deactive") && (SalesId != ""))
            {
                SalesId = SalesId + "-X";
            }
            else if ((Desig == "Jr. Sales" || Desig == "Jr Project Manager" || Desig == "Sales Manager" || Desig == "Sr. Sales") && (UserStatus != "Deactive"))
            {
                if (SalesId != "")
                {
                    LastInt = SalesId.Substring(SalesId.Length - 4);
                    SalesId = "SLE000" + Convert.ToString(Convert.ToInt32(LastInt) + 1);
                }
                else
                {
                    SalesId = "SLE0001";
                }
            }
            else if ((Desig == "Jr. Sales" || Desig == "Jr Project Manager" || Desig == "Sales Manager" || Desig == "Sr. Sales") && (UserStatus == "Deactive") && (SalesId != ""))
            {
                SalesId = SalesId + "-X";
            }

            return SalesId;
        }

        private void Import_To_Grid(string FilePath, string Extension)
        {

            
            string conStr = "";
            switch (Extension)
            {
                case ".xls": //Excel 97-03
                    conStr = @"Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" + FilePath + ";Extended Properties='Excel 8.0;HDR=No;IMEX=1'";
                    //conStr = ConfigurationManager.ConnectionStrings["Excel03ConString"]
                    //         .ConnectionString;
                    break;
                case ".xlsx": //Excel 07
                    conStr = @"Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" + FilePath + ";Extended Properties=Excel 12.0;";
                    //conStr = @"Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + FilePath + ";Extended Properties='Excel 8.0;HDR=Yes;IMEX=1'";
                    //conStr = ConfigurationManager.ConnectionStrings["Excel07ConString"]
                    //          .ConnectionString;
                    break;
            }
            conStr = String.Format(conStr, FilePath);
            OleDbConnection connExcel = new OleDbConnection(conStr);
            OleDbCommand cmdExcel = new OleDbCommand();
            OleDbDataAdapter oda = new OleDbDataAdapter();
            DataTable dtExcel = new DataTable();
            cmdExcel.Connection = connExcel;
            string IdGenerated = "";
            //Get the name of First Sheet
            connExcel.Open();
            DataTable dtExcelSchema;
            dtExcelSchema = connExcel.GetOleDbSchemaTable(OleDbSchemaGuid.Tables, null);
            string SheetName = dtExcelSchema.Rows[0]["TABLE_NAME"].ToString();
            connExcel.Close();

            //Read Data from First Sheet
            connExcel.Open();
            cmdExcel.CommandText = "SELECT * From [" + SheetName + "]";
            oda.SelectCommand = cmdExcel;
            oda.Fill(dtExcel);

            XmlDocument xmlDoc = new XmlDocument();
            CreateUserObjectXml(dtExcel, out xmlDoc);

            connExcel.Close();
            DataSet ds = new DataSet();

            if (xmlDoc.OuterXml != "")
                ds = InstallUserBLL.Instance.BulkIntsallUser(xmlDoc.InnerXml);

            if (ds.Tables[0] != null && ds.Tables[0].Rows.Count > 0) //true.. ds returns duplicate users
            {
                Session["DuplicateUsers"] = ds.Tables[0];

                listDuplicateUsers.DataSource = ds.Tables[0];
                listDuplicateUsers.DataBind();

                ScriptManager.RegisterStartupScript(this, this.GetType(), "overlay", "OverlayPopupUploadBulk();", true);
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "overlay", "alert('All records has been added successfully!');window.location ='EditUser.aspx';", true);
            }
        }

        public void CreateUserObjectXml(DataTable dtExcel, out XmlDocument xmlDoc)
        {
            List<user1> list = new List<user1>();
            string helper = "";
            user1 objuser = null;
            xmlDoc = new XmlDocument();
            bool IsValid = true;

            for (int i = 0; i < dtExcel.Rows.Count; i++)
            {
                try
                {
                    #region
                    //0 ID #: ---	1 *Designitions:--	2 status:	-- 3 Date Sourced: 	-- 4 *First Name*  	-- 5 *Last Name	-- 6 * Source	-- 7 *Primary contact phone #:(3-3-4)
                    //8 *phone type:(drop down: Cell Phone #, House Phone #, Work Phone #, Alt #)	-- 9 secondary contact phone #(3-3-4)	-- 10 phone type:(drop down: Cell Phone #, House Phone #, Work Phone #, Alt #)
                    //11 *Company Name	-- 12 *Primary Trade 	-- 13 SecondaryTrade* (list as many secondary… 1 primary)	
                    //14 *Home Address  	-- 15 Zip  	-- 16 State  17 City 	 -- 18 Suite/Apt/Room(If applicable)   
                    //19 *Secondary Address	 -- 20 Zip  -- 21 State -- 22 City 	-- 23 Suite/Apt/Room(If applicable)
                    //24 Are you currently employed? 	-- 25 Reason for leaving your current employer/position  -- 26 Have you ever applied or worked here before? 
                    //27 How many full time positions have you had in the past 5 years?	 -- 28 Can you tell me a little about any sales or construction industry experience you have?
                    //29 No FELONY or DUI charges?  -- 30 Will you be able to pass a drug test and background check?  -- 31  What are your salary requirements for this position?
                    //32 If selected for position, when will you be available to start?
                    #endregion

                    objuser = new user1();

                    #region BindUserObject

                    objuser.Email = dtExcel.Rows[i][5].ToString().Trim();

                    if (objuser.Email == "")
                        break;

                    objuser.firstname = dtExcel.Rows[i][0].ToString().Trim();  //changes by Ratnakar
                    objuser.lastname = dtExcel.Rows[i][1].ToString().Trim();
                    objuser.CompanyName = dtExcel.Rows[i][2].ToString().Trim();
                    objuser.status = "Applicant";
                    objuser.DateSourced = DateTime.Now.ToString();
                    objuser.phone = dtExcel.Rows[i][3].ToString().Trim();
                    objuser.Phone2 = dtExcel.Rows[i][4].ToString().Trim();
                    objuser.SourceUser = Convert.ToString(Session["userid"]);
                    objuser.Source = Convert.ToString(Session["Username"]);

                    objuser.Email = dtExcel.Rows[i][5].ToString().Trim();
                    objuser.Email2 = dtExcel.Rows[i][7].ToString().Trim();
                    objuser.DateSourced = dtExcel.Rows[i][7].ToString().Trim();
                    objuser.Notes = dtExcel.Rows[i][9].ToString().Trim();
                    objuser.Designation = dtExcel.Rows[i][9].ToString().Trim();
                    objuser.status = dtExcel.Rows[i][10].ToString().Trim();

                    //objuser.Designation = dtExcel.Rows[i][1].ToString().Trim();
                    //objuser.status = "Applicant";
                    //objuser.DateSourced = DateTime.Now.ToString();
                    //objuser.firstname = dtExcel.Rows[i][4].ToString().Trim();
                    //objuser.lastname = dtExcel.Rows[i][5].ToString().Trim();
                    //objuser.SourceUser = Convert.ToString(Session["userid"]);
                    //objuser.Source = Convert.ToString(Session["Username"]);

                    //objuser.phone = dtExcel.Rows[i][7].ToString().Trim();
                    //objuser.phonetype = dtExcel.Rows[i][8].ToString().Trim();
                    //objuser.Phone2 = dtExcel.Rows[i][9].ToString().Trim();
                    //objuser.Phone2Type = dtExcel.Rows[i][10].ToString().Trim();

                    //objuser.CompanyName = dtExcel.Rows[i][11].ToString().Trim();

                    //helper = dtExcel.Rows[i][12].ToString().Trim();
                    //objuser.PrimeryTradeId = helper == "" ? 0 : Convert.ToInt32(helper);

                    //helper = dtExcel.Rows[i][13].ToString().Trim();
                    //objuser.SecondoryTradeId = helper == "" ? 0 : Convert.ToInt32(helper);

                    //objuser.address = dtExcel.Rows[i][14].ToString().Trim();
                    //objuser.zip = dtExcel.Rows[i][15].ToString().Trim();
                    //objuser.state = dtExcel.Rows[i][16].ToString().Trim();
                    //objuser.city = dtExcel.Rows[i][17].ToString().Trim();
                    //objuser.SuiteAptRoom = dtExcel.Rows[i][18].ToString().Trim();

                    //objuser.Address2 = dtExcel.Rows[i][19].ToString().Trim();
                    //objuser.Zip2 = dtExcel.Rows[i][20].ToString().Trim();
                    //objuser.State2 = dtExcel.Rows[i][21].ToString().Trim();
                    //objuser.City2 = dtExcel.Rows[i][22].ToString().Trim();
                    //objuser.SuiteAptRoom2 = dtExcel.Rows[i][23].ToString().Trim();

                    //helper = dtExcel.Rows[i][24].ToString().Trim().ToLower();

                    if (helper == "yes" || helper == "true")
                        objuser.CurrentEmployement = true;
                    else if (helper == "no" || helper == "false")
                        objuser.CurrentEmployement = false;

                    //objuser.LeavingReason = dtExcel.Rows[i][25].ToString().Trim();

                   //helper = dtExcel.Rows[i][26].ToString().Trim().ToLower();

                    if (helper == "yes" || helper == "true")
                        objuser.PrevApply = true;
                    else if (helper == "no" || helper == "false")
                        objuser.PrevApply = false;

                    //helper = dtExcel.Rows[i][27].ToString().Trim();
                    //objuser.FullTimePosition = helper == "" ? 0 : Convert.ToInt32(helper);
                    //objuser.SalesExperience = dtExcel.Rows[i][28].ToString().Trim();

                    //helper = dtExcel.Rows[i][29].ToString().Trim().ToLower();

                    if (helper == "yes" || helper == "true")
                        objuser.FELONY = true;
                    else if (helper == "no" || helper == "false")
                        objuser.FELONY = false;

                    //helper = dtExcel.Rows[i][30].ToString().Trim().ToLower();

                    if (helper == "yes" || helper == "true")
                        objuser.DrugTest = true;
                    else if (helper == "no" || helper == "false")
                        objuser.DrugTest = false;

                    //objuser.SalaryReq = dtExcel.Rows[i][31].ToString().Trim();
                    //objuser.Avialability = dtExcel.Rows[i][32].ToString().Trim();
                    objuser.UserType = "SalesUser";

                    #endregion
                    //|| objuser.phonetype == ""
                    //|| objuser.PrimeryTradeId == 0
                    if (objuser.Email == "" || objuser.Designation == "" || objuser.firstname == "" || objuser.lastname == "" || objuser.Source == "" ||
                        objuser.phone == ""  || objuser.CompanyName == "" )
                    {
                        IsValid = false;
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "AlertBox", "alert('Upload file contains data error or matching data exists, please check and upload again');", true);
                        return;
                    }
                    list.Add(objuser);

                    #region commented



                    //DataSet dsCheckDuplicate = InstallUserBLL.Instance.CheckInstallUser(dtExcel.Rows[i][5].ToString().Trim(), dtExcel.Rows[i][3].ToString().Trim());

                    //if (dsCheckDuplicate.Tables[0].Rows.Count == 0)
                    //{
                    //    IdGenerated = GetId(dtExcel.Rows[i][9].ToString().Trim(), dtExcel.Rows[i][10].ToString().Trim());
                    //    objuser.InstallId = IdGenerated;
                    //    DataSet ds = InstallUserBLL.Instance.CheckSource(Convert.ToString(Session["Username"]));
                    //    if (ds.Tables[0].Rows.Count > 0)
                    //    {
                    //        //do nothing
                    //    }
                    //    else
                    //    {
                    //        DataSet dsadd = InstallUserBLL.Instance.AddSource(Convert.ToString(Session["Username"]));
                    //    }
                    //    //objuser.DateSourced = Convert.ToString(dtExcel.Rows[i][9].ToString());
                    //    objuser.Notes = dtExcel.Rows[i][8].ToString().Trim();
                    //    bool result = InstallUserBLL.Instance.AddUser(objuser);
                    //    count += Convert.ToInt32(result);
                    //}

                    #endregion
                }
                catch (Exception ex)
                {
                    UtilityBAL.AddException("EditUser-CreateUserObjectXml", Session["loginid"] == null ? "" : Session["loginid"].ToString(), ex.Message, ex.StackTrace);
                    continue;
                }
            }

            ////check duplicacy of data in sheet itself
            //var duplicate = from c in list.AsEnumerable()
            //                group c by c.Email into grp
            //                where grp.Count() > 1
            //                select grp.Key;
            //if (duplicate.ToList().Count > 0)
            //{
            //    IsValid = false;
            //    ScriptManager.RegisterStartupScript(this, this.GetType(), "AlertBox", "alert('Upload file contains data error or matching data exists, please check and upload again');", true);
            //    return;
            //}


            if (IsValid)
            {
                xmlDoc.LoadXml(Serialize(list));

                if (xmlDoc.FirstChild.NodeType == XmlNodeType.XmlDeclaration)
                    xmlDoc.RemoveChild(xmlDoc.FirstChild);
            }
        }

        public void CreateDuplicateUserObjectXml(DataTable dt, out XmlDocument xmlDoc)
        {
            List<user1> list = new List<user1>();
            string helper = "";
            user1 objuser = null;
            xmlDoc = new XmlDocument();

            for (int i = 0; i < dt.Rows.Count; i++)
            {
                try
                {
                    objuser = new user1();

                    #region BindUserObject

                    helper = dt.Rows[i]["Id"].ToString().Trim();
                    objuser.Id = helper == "" ? 0 : Convert.ToInt32(helper);

                    objuser.Email = dt.Rows[i]["Email"].ToString().Trim();
                    objuser.Designation = dt.Rows[i]["Designation"].ToString().Trim();
                    objuser.status = "Applicant";
                    objuser.DateSourced = DateTime.Now.ToString();
                    objuser.firstname = dt.Rows[i]["firstname"].ToString().Trim();
                    objuser.lastname = dt.Rows[i]["lastname"].ToString().Trim();
                    objuser.SourceUser = Convert.ToString(Session["userid"]);
                    objuser.Source = Convert.ToString(Session["Username"]);

                    objuser.phone = dt.Rows[i]["phone"].ToString().Trim();
                    objuser.phonetype = dt.Rows[i]["phonetype"].ToString().Trim();
                    objuser.Phone2 = dt.Rows[i]["Phone2"].ToString().Trim();
                    objuser.Phone2Type = dt.Rows[i]["Phone2Type"].ToString().Trim();

                    objuser.CompanyName = dt.Rows[i]["CompanyName"].ToString().Trim();

                    helper = dt.Rows[i]["PrimeryTradeId"].ToString().Trim();
                    objuser.PrimeryTradeId = helper == "" ? 0 : Convert.ToInt32(helper);

                    helper = dt.Rows[i]["SecondoryTradeId"].ToString().Trim();
                    objuser.SecondoryTradeId = helper == "" ? 0 : Convert.ToInt32(helper);

                    objuser.address = dt.Rows[i]["address"].ToString().Trim();
                    objuser.zip = dt.Rows[i]["zip"].ToString().Trim();
                    objuser.state = dt.Rows[i]["state"].ToString().Trim();
                    objuser.city = dt.Rows[i]["city"].ToString().Trim();
                    objuser.SuiteAptRoom = dt.Rows[i]["SuiteAptRoom"].ToString().Trim();

                    objuser.Address2 = dt.Rows[i]["Address2"].ToString().Trim();
                    objuser.Zip2 = dt.Rows[i]["Zip2"].ToString().Trim();
                    objuser.State2 = dt.Rows[i]["State2"].ToString().Trim();
                    objuser.City2 = dt.Rows[i]["City2"].ToString().Trim();
                    objuser.SuiteAptRoom2 = dt.Rows[i]["SuiteAptRoom2"].ToString().Trim();

                    helper = dt.Rows[i]["CurrentEmployement"].ToString().Trim().ToLower();

                    if (helper == "yes" || helper == "true")
                        objuser.CurrentEmployement = true;
                    else if (helper == "no" || helper == "false")
                        objuser.CurrentEmployement = false;

                    objuser.LeavingReason = dt.Rows[i]["LeavingReason"].ToString().Trim();

                    helper = dt.Rows[i]["PrevApply"].ToString().Trim().ToLower();

                    if (helper == "yes" || helper == "true")
                        objuser.PrevApply = true;
                    else if (helper == "no" || helper == "false")
                        objuser.PrevApply = false;

                    helper = dt.Rows[i]["FullTimePosition"].ToString().Trim();
                    objuser.FullTimePosition = helper == "" ? 0 : Convert.ToInt32(helper);
                    objuser.SalesExperience = dt.Rows[i]["SalesExperience"].ToString().Trim();

                    helper = dt.Rows[i]["FELONY"].ToString().Trim().ToLower();

                    if (helper == "yes" || helper == "true")
                        objuser.FELONY = true;
                    else if (helper == "no" || helper == "false")
                        objuser.FELONY = false;

                    helper = dt.Rows[i]["DrugTest"].ToString().Trim().ToLower();

                    if (helper == "yes" || helper == "true")
                        objuser.DrugTest = true;
                    else if (helper == "no" || helper == "false")
                        objuser.DrugTest = false;

                    objuser.SalaryReq = dt.Rows[i]["SalaryReq"].ToString().Trim();
                    objuser.Avialability = dt.Rows[i]["Avialability"].ToString().Trim();

                    #endregion

                    list.Add(objuser);
                }
                catch (Exception ex)
                {
                    continue;
                }
            }

            xmlDoc.LoadXml(Serialize(list));

            if (xmlDoc.FirstChild.NodeType == XmlNodeType.XmlDeclaration)
                xmlDoc.RemoveChild(xmlDoc.FirstChild);
        }

        public static string Serialize(object dataToSerialize)
        {
            if (dataToSerialize == null) return null;

            using (StringWriter stringwriter = new System.IO.StringWriter())
            {
                var serializer = new XmlSerializer(dataToSerialize.GetType());
                serializer.Serialize(stringwriter, dataToSerialize, null);

                return stringwriter.ToString();
            }
        }

        public static T Deserialize<T>(string xmlText)
        {
            if (String.IsNullOrWhiteSpace(xmlText)) return default(T);

            using (StringReader stringReader = new System.IO.StringReader(xmlText))
            {
                var serializer = new XmlSerializer(typeof(T));
                return (T)serializer.Deserialize(stringReader);
            }
        }

        private bool CheckRequiredFields(string SelectedStatus, int Id)
        {
            DataSet dsNew = new DataSet();
            dsNew = InstallUserBLL.Instance.getuserdetails(Id);
            if (dsNew.Tables.Count > 0)
            {
                if (dsNew.Tables[0].Rows.Count > 0)
                {
                    if (SelectedStatus == "Applicant")
                    {
                        if (Convert.ToString(dsNew.Tables[0].Rows[0][1]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][2]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][3]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][8]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][38]) == "")
                        {
                            //ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Status cannot be changed to Applicant as required fields for it are not filled.')", true);
                            return false;
                        }
                    }
                    else if (SelectedStatus == "OfferMade" || SelectedStatus == "Offer Made")
                    {
                        //if (Convert.ToString(dsNew.Tables[0].Rows[0][1]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][2]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][4]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][5]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][11]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][12]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][13]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][3]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][8]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][38]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][44]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][46]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][48]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][50]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][100]) == "")
                        if (Convert.ToString(dsNew.Tables[0].Rows[0]["Email"]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0]["Password"]) == "")
                        {
                            txtEmail.Text = Convert.ToString(dsNew.Tables[0].Rows[0]["Email"]);
                            //ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Status cannot be changed to Offer Made as required fields for it are not filled.')", true);
                            return false;
                        }
                    }
                    else if (SelectedStatus == "Active")
                    {
                        if (Convert.ToString(dsNew.Tables[0].Rows[0][1]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][2]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][3]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][4]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][5]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][7]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][9]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][11]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][12]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][13]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][17]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][16]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][17]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][8]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][18]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][19]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][20]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][35]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][38]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][39]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][44]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][46]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][48]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][50]) == "" || Convert.ToString(dsNew.Tables[0].Rows[0][100]) == "")
                        {
                            //ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Status cannot be changed to Offer Made as required fields for it are not filled.')", true); 
                            return false;
                        }
                    }
                }
            }
            return true;
        }

        private void SendEmail(string emailId, string FName, string LName, string status, string Reason, string Designition, string HireDate, string EmpType, string PayRates, int htmlTempID, List<Attachment> Attachments = null)
        {
            string fullname = FName + " " + LName;
            DataSet ds = AdminBLL.Instance.GetEmailTemplate(Designition, htmlTempID);// AdminBLL.Instance.FetchContractTemplate(104);
            //htmlTempID = 105 only in btnSaveOfferMade method. otherwise  = 0 

            if (ds == null)
            {
                ds = AdminBLL.Instance.GetEmailTemplate("Admin");
            }
            else if (ds.Tables[0].Rows.Count == 0)
            {
                ds = AdminBLL.Instance.GetEmailTemplate("Admin");
            }
            string strHeader = ds.Tables[0].Rows[0]["HTMLHeader"].ToString(); //GetEmailHeader(status);
            string strBody = ds.Tables[0].Rows[0]["HTMLBody"].ToString(); //GetEmailBody(status);
            string strFooter = ds.Tables[0].Rows[0]["HTMLFooter"].ToString(); // GetFooter(status);
            string strsubject = ds.Tables[0].Rows[0]["HTMLSubject"].ToString();

            string userName = ConfigurationManager.AppSettings["VendorCategoryUserName"].ToString();
            string password = ConfigurationManager.AppSettings["VendorCategoryPassword"].ToString();

            strBody = strBody.Replace("#Email#", emailId).Replace("#email#", emailId);
            strBody = strBody.Replace("#Name#", FName).Replace("#name#", FName);
            strBody = strBody.Replace("#Date#", dtInterviewDate.Text).Replace("#date#", dtInterviewDate.Text);
            strBody = strBody.Replace("#Time#", ddlInsteviewtime.SelectedValue).Replace("#time#", ddlInsteviewtime.SelectedValue);
            strBody = strBody.Replace("#Designation#", Designition).Replace("#designation#", Designition);

            strFooter = strFooter.Replace("#Name#", FName).Replace("#name#", FName);
            strFooter = strFooter.Replace("#Date#", dtInterviewDate.Text).Replace("#date#", dtInterviewDate.Text);
            strFooter = strFooter.Replace("#Time#", ddlInsteviewtime.SelectedValue).Replace("#time#", ddlInsteviewtime.SelectedValue);
            strFooter = strFooter.Replace("#Designation#", Designition).Replace("#designation#", Designition);

            strBody = strBody.Replace("Lbl Full name", fullname);
            strBody = strBody.Replace("LBL position", Designition);
            //strBody = strBody.Replace("lbl: start date", txtHireDate.Text);
            //strBody = strBody.Replace("($ rate","$"+ txtHireDate.Text);
            strBody = strBody.Replace("Reason", Reason);

            strBody = strHeader + strBody + strFooter;

            //Hi #lblFName#, <br/><br/>You are requested to appear for an interview on #lblDate# - #lblTime#.<br/><br/>Regards,<br/>

            if (status == "OfferMade")
            {
                createForeMenForJobAcceptance(strBody, FName, LName, Designition, emailId, HireDate, EmpType, PayRates);
            }
            if (status == "Deactive")
            {
                CreateDeactivationAttachment(strBody, FName, LName, Designition, emailId, HireDate, EmpType, PayRates);
            }

            List<Attachment> lstAttachments = new List<Attachment>();

            for (int i = 0; i < ds.Tables[1].Rows.Count; i++)
            {
                string sourceDir = Server.MapPath(ds.Tables[1].Rows[i]["DocumentPath"].ToString());
                if (File.Exists(sourceDir))
                {
                    Attachment attachment = new Attachment(sourceDir);
                    attachment.Name = Path.GetFileName(sourceDir);
                    lstAttachments.Add(attachment);
                }
            }
            if (Attachments != null)
            {
                lstAttachments.AddRange(Attachments);
            }

            JG_Prospect.App_Code.CommonFunction.SendEmail(Designition, emailId, strsubject, strBody, lstAttachments);

            ScriptManager.RegisterStartupScript(this, this.GetType(), "UserMsg", "alert('An email notification has sent on " + emailId + ".');", true);
        }

        private string GetFooter(string status)
        {
            string Footer = string.Empty;
            DataTable DtFooter;
            DtFooter = InstallUserBLL.Instance.getTemplate(status, "footer");
            if (DtFooter.Rows.Count > 0)
            {
                Footer = DtFooter.Rows[0][0].ToString();
            }
            return Footer;
        }

        private string GetEmailBody(string status)
        {
            string Body = string.Empty;
            DataTable DtBody;
            DtBody = InstallUserBLL.Instance.getTemplate(status, "Body");
            if (DtBody.Rows.Count > 0)
            {
                Body = DtBody.Rows[0][0].ToString();
            }
            return Body;
        }

        private string GetEmailHeader(string status)
        {
            string Header = string.Empty;
            DataTable DtHeader;
            DtHeader = InstallUserBLL.Instance.getTemplate(status, "Header");
            if (DtHeader.Rows.Count > 0)
            {
                Header = DtHeader.Rows[0][0].ToString();
            }
            return Header;
        }

        private void FindAndReplace(Word.Application wordApp, object findText, object replaceText)
        {
            object matchCase = true;
            object matchWholeWord = true;
            object matchWildCards = false;
            object matchSoundsLike = false;
            object matchAllWordForms = false;
            object forward = true;
            object format = false;
            object matchKashida = false;
            object matchDiacritics = false;
            object matchAlefHamza = false;
            object matchControl = false;
            object read_only = false;
            object visible = true;
            object replace = 2;
            object wrap = 1;
            wordApp.Selection.Find.Execute(ref findText, ref matchCase,
                ref matchWholeWord, ref matchWildCards, ref matchSoundsLike,
                ref matchAllWordForms, ref forward, ref wrap, ref format,
                ref replaceText, ref replace, ref matchKashida,
                        ref matchDiacritics,
                ref matchAlefHamza, ref matchControl);
        }

        public void createForeMenForJobAcceptance(string str_Body, string FName, string LName, string Designition, string emailId, string HireDate, string EmpType, string PayRates)
        {
            //copy sample file for Foreman Job Acceptance letter template
            string str_date = DateTime.Now.ToString().Replace("/", "");
            str_date = str_date.Replace(":", "");
            str_date = str_date.Replace("-", "");
            str_date = str_date.Replace(" ", "");
            string SourcePath = @"~/Sr_App/MailDocSample/ForemanJobAcceptancelettertemplate.docx";
            string TargetPath = @"~/Sr_App/MailDocument/" + str_date + FName + "ForemanJobAcceptanceletter.docx";
            System.IO.File.Copy(Server.MapPath(SourcePath), Server.MapPath(TargetPath), true);
            //modify word document
            object missing = System.Reflection.Missing.Value;
            Word.Application wordApp = new Word.Application();
            Word.Document aDoc = null;
            object Target = Server.MapPath(TargetPath);
            if (File.Exists(Server.MapPath(TargetPath)))
            {
                DateTime today = DateTime.Now;
                object readonlyNew = false;
                object isVisible = false;
                wordApp.Visible = false;
                FileInfo objFInfo = new FileInfo(Server.MapPath(TargetPath));
                objFInfo.IsReadOnly = false;
                aDoc = wordApp.Documents.Open(ref Target, ref missing, ref readonlyNew, ref missing, ref missing, ref missing, ref missing, ref missing, ref missing, ref missing, ref missing, ref isVisible, ref missing, ref missing, ref missing, ref missing);
                aDoc.Activate();
                this.FindAndReplace(wordApp, "LBL Date", DateTime.Now.ToShortDateString());
                this.FindAndReplace(wordApp, "Lbl Full name", FName + " " + LName);
                this.FindAndReplace(wordApp, "LBL name", FName + " " + LName);
                this.FindAndReplace(wordApp, "LBL position", Designition);
                this.FindAndReplace(wordApp, "lbl fulltime", EmpType);
                this.FindAndReplace(wordApp, "lbl: start date", HireDate);
                this.FindAndReplace(wordApp, "$ rate", PayRates);
                this.FindAndReplace(wordApp, "lbl: next pay period", "");
                this.FindAndReplace(wordApp, "lbl: paycheck date", "");
                aDoc.SaveAs(ref Target, ref missing, ref missing, ref missing, ref missing, ref missing, ref missing, ref missing, ref missing, ref missing, ref missing, ref missing, ref missing, ref missing, ref missing, ref missing);
                aDoc.Close(ref missing, ref missing, ref missing);
            }
            using (MailMessage mm = new MailMessage("qat2015team@gmail.com", emailId))
            {
                try
                {
                    mm.Subject = "Foreman Job Acceptance";
                    mm.Body = str_Body;
                    mm.Attachments.Add(new Attachment(Server.MapPath(TargetPath)));
                    mm.IsBodyHtml = true;
                    SmtpClient smtp = new SmtpClient();
                    smtp.Host = "smtp.gmail.com";
                    smtp.EnableSsl = true;
                    NetworkCredential NetworkCred = new NetworkCredential("qat2015team@gmail.com", "q$7@wt%j*65ba#3M@9P6");
                    smtp.UseDefaultCredentials = true;
                    smtp.Credentials = NetworkCred;
                    smtp.Port = 587;
                    smtp.Send(mm);
                }
                catch (Exception ex)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message + "')", true);
                }
                //ClientScript.RegisterStartupScript(GetType(), "alert", "alert('Email sent.');", true);
            }
        }

        public void CreateDeactivationAttachment(string MailBody, string FName, string LName, string Designition, string emailId, string HireDate, string EmpType, string PayRates)
        {
            string str_date = DateTime.Now.ToString().Replace("/", "");
            str_date = str_date.Replace(":", "");
            str_date = str_date.Replace("-", "");
            str_date = str_date.Replace(" ", "");
            string SourcePath = @"~/Sr_App/MailDocSample/DeactivationMail.doc";
            string TargetPath = @"~/Sr_App/MailDocument/" + str_date + FName + "DeactivationMail.doc";
            System.IO.File.Copy(Server.MapPath(SourcePath), Server.MapPath(TargetPath), true);
            //modify word document
            object missing = System.Reflection.Missing.Value;
            Word.Application wordApp = new Word.Application();
            Word.Document aDoc = null;
            object Target = Server.MapPath(TargetPath);
            if (File.Exists(Server.MapPath(TargetPath)))
            {
                DateTime today = DateTime.Now;
                object readonlyNew = false;
                object isVisible = false;
                wordApp.Visible = false;
                FileInfo objFInfo = new FileInfo(Server.MapPath(TargetPath));
                objFInfo.IsReadOnly = false;
                aDoc = wordApp.Documents.Open(ref Target, ref missing, ref readonlyNew, ref missing, ref missing, ref missing, ref missing, ref missing, ref missing, ref missing, ref missing, ref isVisible, ref missing, ref missing, ref missing, ref missing);
                aDoc.Activate();
                this.FindAndReplace(wordApp, "name", FName + " " + LName);
                this.FindAndReplace(wordApp, "HireDate", HireDate);
                this.FindAndReplace(wordApp, "full time or part  time", EmpType);
                this.FindAndReplace(wordApp, "HourlyRate", PayRates);
                this.FindAndReplace(wordApp, "WorkingStatus", "No");
                this.FindAndReplace(wordApp, "LastWorkingDay", DateTime.Now.ToShortDateString());
                aDoc.SaveAs(ref Target, ref missing, ref missing, ref missing, ref missing, ref missing, ref missing, ref missing, ref missing, ref missing, ref missing, ref missing, ref missing, ref missing, ref missing, ref missing);
                aDoc.Close(ref missing, ref missing, ref missing);
            }
            using (MailMessage mm = new MailMessage("qat2015team@gmail.com", emailId))
            {
                try
                {
                    mm.Subject = "Deactivation";
                    mm.Body = MailBody;
                    mm.Attachments.Add(new Attachment(Server.MapPath(TargetPath)));
                    mm.IsBodyHtml = true;
                    SmtpClient smtp = new SmtpClient();
                    smtp.Host = "smtp.gmail.com";
                    smtp.EnableSsl = true;
                    NetworkCredential NetworkCred = new NetworkCredential("qat2015team@gmail.com", "q$7@wt%j*65ba#3M@9P6");
                    smtp.UseDefaultCredentials = true;
                    smtp.Credentials = NetworkCred;
                    smtp.Port = 587;
                    smtp.Send(mm);
                }
                catch (Exception ex)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message + "')", true);
                }
            }
        }

        public List<string> GetTimeIntervals()
        {
            List<string> timeIntervals = new List<string>();
            TimeSpan startTime = new TimeSpan(0, 0, 0);
            DateTime startDate = new DateTime(DateTime.MinValue.Ticks); // Date to be used to get shortTime format.
            for (int i = 0; i < 48; i++)
            {
                int minutesToBeAdded = 30 * i;      // Increasing minutes by 30 minutes interval
                TimeSpan timeToBeAdded = new TimeSpan(0, minutesToBeAdded, 0);
                TimeSpan t = startTime.Add(timeToBeAdded);
                DateTime result = startDate + t;
                timeIntervals.Add(result.ToShortTimeString());      // Use Date.ToShortTimeString() method to get the desired format                
            }
            return timeIntervals;
        }
        private void LoadUsersByRecruiterDesgination()
        {
            DataSet dsUsers;

            dsUsers = TaskGeneratorBLL.Instance.GetInstallUsers(2, "Admin,Office Manager,Recruiter");

            ddlUsers.DataSource = dsUsers;
            ddlUsers.DataTextField = "FristName";
            ddlUsers.DataValueField = "Id";
            ddlUsers.DataBind();

            ddlUsers.Items.Insert(0, new ListItem("--All--", "0"));
        }

        private void FillTechTaskDropDown()
        {
            DataSet dsTechTask;

            dsTechTask = TaskGeneratorBLL.Instance.GetAllActiveTechTask();

            ddlTechTask.DataSource = dsTechTask;
            ddlTechTask.DataTextField = "Title";
            ddlTechTask.DataValueField = "TaskId";
            ddlTechTask.DataBind();
        }

        private void BindGrid()
        {
            ShowHRData();

            DataTable dt = (DataTable)(Session["UserGridData"]);
            EnumerableRowCollection<DataRow> query = null;
            if ((ddlUserStatus.SelectedIndex != 0 || ddlDesignation.SelectedIndex != 0 || drpUser.SelectedIndex != 0 || ddlSource.SelectedIndex != 0)
                && dt != null)
            {
                string Status = ddlUserStatus.SelectedItem.Value;
                query = from userdata in dt.AsEnumerable()
                        where (userdata.Field<string>("Status") == Status || ddlUserStatus.SelectedIndex == 0)
                       && (userdata.Field<string>("Designation") == ddlDesignation.SelectedItem.Text || ddlDesignation.SelectedIndex == 0)
                         && (userdata.Field<string>("AddedBy") == drpUser.SelectedItem.Text || drpUser.SelectedIndex == 0)
                          && (userdata.Field<string>("Source") == ddlSource.SelectedItem.Text || ddlSource.SelectedIndex == 0)
                        select userdata;
                if (query.Count() > 0)
                {
                    dt = query.CopyToDataTable();
                }
                else
                    dt = null;
            }
            //grdUsers.DataSource = dt;
            //grdUsers.DataBind();

            BindUsers(dt);
        }

        private void ShowHRData()
        {
            DateTime fromDate = Convert.ToDateTime(txtfrmdate.Text, JG_Prospect.Common.JGConstant.CULTURE);
            DateTime toDate = Convert.ToDateTime(txtTodate.Text, JG_Prospect.Common.JGConstant.CULTURE);
            if (fromDate < toDate)
            {
                DataSet ds = InstallUserBLL.Instance.GetHrData(fromDate, toDate, Convert.ToInt16(drpUser.SelectedValue));
                if (ds != null)
                {
                    DataTable dtHrData = ds.Tables[0];
                    DataTable dtgridData = ds.Tables[1];
                    List<HrData> lstHrData = new List<HrData>();
                    foreach (DataRow row in dtHrData.Rows)
                    {
                        HrData hrdata = new HrData();
                        hrdata.status = row["status"].ToString();
                        hrdata.count = row["cnt"].ToString();
                        lstHrData.Add(hrdata);
                    }

                    if (dtHrData.Rows.Count > 0)
                    {

                        var rowOfferMade = lstHrData.Where(r => r.status == "OfferMade").FirstOrDefault();
                        if (rowOfferMade != null)
                        {
                            string count = rowOfferMade.count;
                            lbljoboffercount.Text = count;
                        }
                        else
                        {
                            lbljoboffercount.Text = "0";
                        }
                        var rowActive = lstHrData.Where(r => r.status == "Active").FirstOrDefault();
                        if (rowActive != null)
                        {
                            string count = rowActive.count;
                            lblActiveCount.Text = count;
                        }
                        else
                        {
                            lblActiveCount.Text = "0";
                        }
                        var rowRejected = lstHrData.Where(r => r.status == "Rejected").FirstOrDefault();
                        if (rowRejected != null)
                        {
                            string count = rowRejected.count;
                            lblRejectedCount.Text = count;
                        }
                        else
                        {
                            lblRejectedCount.Text = "0";
                        }
                        var rowDeactive = lstHrData.Where(r => r.status == "Deactive").FirstOrDefault();
                        if (rowDeactive != null)
                        {
                            string count = rowDeactive.count;
                            lblDeactivatedCount.Text = count;
                        }
                        else
                        {
                            lblDeactivatedCount.Text = "0";
                        }
                        var rowInstallProspect = lstHrData.Where(r => r.status == "Install Prospect").FirstOrDefault();
                        if (rowInstallProspect != null)
                        {
                            string count = rowInstallProspect.count;
                            lblInstallProspectCount.Text = count;
                        }
                        else
                        {
                            lblInstallProspectCount.Text = "0";
                        }
                        var rowPhoneScreened = lstHrData.Where(r => r.status == "PhoneScreened").FirstOrDefault();
                        if (rowPhoneScreened != null)
                        {
                            string count = rowPhoneScreened.count;
                            lblPhoneVideoScreenedCount.Text = count;
                        }
                        else
                        {
                            lblPhoneVideoScreenedCount.Text = "0";
                        }
                        var rowInterviewDate = lstHrData.Where(r => r.status == "InterviewDate").FirstOrDefault();
                        if (rowInterviewDate != null)
                        {
                            string count = rowInterviewDate.count;
                            lblInterviewDateCount.Text = count;
                        }
                        else
                        {
                            lblInterviewDateCount.Text = "0";
                        }
                        var rowApplicant = lstHrData.Where(r => r.status == "Applicant").FirstOrDefault();
                        string Applicantcount = "0";
                        if (rowApplicant != null)
                        {
                            Applicantcount = rowApplicant.count;

                        }
                        else
                        {
                            Applicantcount = "0";

                        }



                        lblNewApplicantsCount.Text = Convert.ToDouble(Applicantcount).ToString();
                        // Ratio Calculation
                        lblAppInterviewRatio.Text = Convert.ToString(Convert.ToDouble(lblInterviewDateCount.Text) / Convert.ToDouble(Applicantcount));
                        //lblAppHireRatio.Text = Convert.ToString(Convert.ToDouble(lblActiveCount.Text) / Convert.ToDouble(Applicantcount) );
                        //lblJobOfferHireRatio.Text = Convert.ToString(Convert.ToDouble(lblActive.Text) / Convert.ToDouble(lblInterviewDateCount.Text));
                        if (lblInterviewDateCount.Text != "0")
                        {
                            lblInterviewActiveRatio.Text = Convert.ToString(Convert.ToDouble(lblActiveCount.Text) / Convert.ToDouble(lblInterviewDateCount.Text));
                        }
                        else
                        {
                            lblInterviewActiveRatio.Text = "0";
                        }
                        if (lbljoboffercount.Text != "0")
                        {
                            lblJobOfferActiveRatio.Text = Convert.ToString(Convert.ToDouble(lblActiveCount.Text) / Convert.ToDouble(lbljoboffercount.Text));
                        }
                        else
                        {
                            lblJobOfferActiveRatio.Text = "0";
                        }
                        if (lblActiveCount.Text != "0")
                        {
                            lblActiveDeactiveRatio.Text = Convert.ToString(Convert.ToDouble(lblDeactivatedCount.Text) / Convert.ToDouble(lblActiveCount.Text));
                        }
                        else
                        {
                            lblActiveDeactiveRatio.Text = "0";
                        }

                    }
                    else
                    {
                        lbljoboffercount.Text = "0";
                        lblActiveCount.Text = "0";
                        lblRejectedCount.Text = "0";
                        lblDeactivatedCount.Text = "0";
                        lblInstallProspectCount.Text = "0";
                        lblPhoneVideoScreenedCount.Text = "0";
                        lblInterviewDateCount.Text = "0";
                        lblAppInterviewRatio.Text = "0";
                        //  lblAppHireRatio.Text = "0";
                    }
                    if (dtgridData.Rows.Count > 0)
                    {
                        Session["UserGridData"] = dtgridData;

                        BindUsers(dtgridData);

                        //grdUsers.DataSource = dtgridData;
                        //grdUsers.DataBind();

                        BindPieChart(dtgridData);
                        BindUsersCount(dtgridData);
                    }
                    else
                    {
                        Session["UserGridData"] = null;
                        grdUsers.DataSource = null;
                        grdUsers.DataBind();
                    }
                }
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "AlertBox", "alert('ToDate must be greater than FromDate');", true);
            }
        }

        private void BindPieChart(DataTable dtgridData)
        {
            DataTable dt = dtgridData;

            var query = from row in dt.AsEnumerable()
                        group row by row.Field<string>("status") into st
                        orderby st.Key
                        select new
                        {
                            Name = st.Key,
                            Total = st.Count()
                        };

            DataTable newItems = new DataTable();
            newItems.Columns.Add("Name");
            newItems.Columns.Add("Total");

            foreach (var item in query)
            {
                DataRow newRow = newItems.NewRow();
                newRow["Name"] = item.Name;
                newRow["Total"] = item.Total;

                newItems.Rows.Add(newRow);
            }

            string[] x = new string[query.Count()];
            int[] y = new int[query.Count()];

            for (int i = 0; i < query.Count(); i++)
            {

                x[i] = newItems.Rows[i]["Name"].ToString();
                y[i] = Convert.ToInt32(newItems.Rows[i]["Total"]);
            }

            Chart1.Series[0].Points.DataBindXY(x, y);
            Chart1.Series[0].ChartType = SeriesChartType.Pie;
            Chart1.ChartAreas["ChartArea1"].Area3DStyle.Enable3D = true;
            Chart1.Legends[0].Enabled = true;
        }

        private void BindUsersCount(DataTable dt)
        {
            var addedBy = from row in dt.AsEnumerable()
                          group row by row.Field<string>("AddedBy") into st
                          orderby st.Key
                          select new
                          {
                              AddedBy = st.Key,
                              Total = st.Count()
                          };

            listAddedBy.DataSource = addedBy;
            listAddedBy.DataBind();

            var desig = from row in dt.AsEnumerable()
                        group row by row.Field<string>("Designation") into st
                        orderby st.Key
                        select new
                        {
                            Designation = st.Key,
                            Total = st.Count()
                        };

            listDesignation.DataSource = desig;
            listDesignation.DataBind();

            var source = from row in dt.AsEnumerable()
                         group row by row.Field<string>("Source") into st
                         orderby st.Key
                         select new
                         {
                             Source = st.Key,
                             Total = st.Count()
                         };

            listSource.DataSource = source;
            listSource.DataBind();
        }

        //private void bindPayPeriod(DataSet dsCurrentPeriod)
        //{
        //    DataSet ds = UserBLL.Instance.getallperiod();

        //    if (ds.Tables[0].Rows.Count > 0)
        //    {
        //        drpPayPeriod.Items.Insert(0, new ListItem("Select", "0"));
        //        for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
        //        {
        //            DataRow dr = ds.Tables[0].Rows[i];
        //            drpPayPeriod.Items.Add(new ListItem(dr["Periodname"].ToString(), dr["Id"].ToString()));
        //        }
        //        drpPayPeriod.SelectedValue = dsCurrentPeriod.Tables[0].Rows[0]["Id"].ToString();
        //        txtfrmdate.Text = Convert.ToDateTime(dsCurrentPeriod.Tables[0].Rows[0]["FromDate"].ToString()).ToString("MM/dd/yyyy");
        //        txtTodate.Text = Convert.ToDateTime(dsCurrentPeriod.Tables[0].Rows[0]["ToDate"].ToString()).ToString("MM/dd/yyyy");
        //    }
        //    else
        //    {
        //        drpPayPeriod.DataSource = null;
        //        drpPayPeriod.DataBind();
        //    }

        //}

        //protected void drpPayPeriod_SelectedIndexChanged(object sender, EventArgs e)
        //{
        //    if (drpPayPeriod.SelectedIndex != -1)
        //    {
        //        DataSet ds = UserBLL.Instance.getperioddetails(Convert.ToInt16(drpPayPeriod.SelectedValue));
        //        if (ds.Tables[0].Rows.Count > 0)
        //        {
        //            txtfrmdate.Text = Convert.ToDateTime(ds.Tables[0].Rows[0]["FromDate"].ToString()).ToString("MM/dd/yyyy");
        //            txtTodate.Text = Convert.ToDateTime(ds.Tables[0].Rows[0]["ToDate"].ToString()).ToString("MM/dd/yyyy");
        //        }
        //    }
        //}

        //private string GetId(string UserType, string UserStatus)
        //{
        //    DataTable dtId;
        //    string installId = string.Empty;

        //    string newId = string.Empty;
        //    dtId = InstallUserBLL.Instance.getMaxId(UserType, UserStatus);
        //    if (dtId.Rows.Count > 0)
        //    {
        //        installId = Convert.ToString(dtId.Rows[0][0]);
        //    }
        //    if ((UserType == "ForeMan" || UserType == "Installer") && (UserStatus == "Applicant" || UserStatus == "InterviewDate" || UserStatus == "OfferMade" || UserStatus == "PhoneScreened" || UserStatus == "Rejected"))
        //    {
        //        if (installId != "")
        //        {
        //            newId = installId.Substring(10);
        //            newId = Convert.ToString(Convert.ToUInt32(newId) + 1);
        //            installId = installId.Remove(10);
        //            installId = installId + newId;
        //        }
        //        else
        //        {
        //            installId = "P-OPP-00001";
        //        }
        //    }
        //    else if ((UserType == "ForeMan" || UserType == "Installer") && (UserStatus == "Active"))
        //    {
        //        if (installId != "")
        //        {
        //            newId = installId.Substring(8);
        //            newId = Convert.ToString(Convert.ToUInt32(newId) + 1);
        //            installId = installId.Remove(8);
        //            installId = installId + newId;
        //        }
        //        else
        //        {
        //            installId = "OPP-00001";
        //        }
        //    }
        //    else if ((UserType == "ForeMan" || UserType == "Installer") && (UserStatus == "Deactive"))
        //    {
        //        if (installId != "")
        //        {
        //            newId = installId.Substring(10);
        //            newId = Convert.ToString(Convert.ToUInt32(newId) + 1);
        //            installId = installId.Remove(10);
        //            installId = installId + newId;
        //        }
        //        else
        //        {
        //            installId = "X-OPP-00001";
        //        }
        //    }
        //    else if ((UserType == "SubContractor") && (UserStatus == "Applicant" || UserStatus == "InterviewDate" || UserStatus == "OfferMade" || UserStatus == "PhoneScreened" || UserStatus == "Rejected"))
        //    {
        //        if (installId != "")
        //        {
        //            newId = installId.Substring(8);
        //            newId = Convert.ToString(Convert.ToUInt32(newId) + 1);
        //            installId = installId.Remove(8);
        //            installId = installId + newId;
        //        }
        //        else
        //        {
        //            installId = "P-SC-00001";
        //        }
        //    }
        //    else if ((UserType == "SubContractor") && (UserStatus == "Active"))
        //    {
        //        if (installId != "")
        //        {
        //            newId = installId.Substring(6);
        //            newId = Convert.ToString(Convert.ToUInt32(newId) + 1);
        //            installId = installId.Remove(6);
        //            installId = installId + newId;
        //        }
        //        else
        //        {
        //            installId = "SC-00001";
        //        }
        //    }
        //    else if ((UserType == "SubContractor") && (UserStatus == "Deactive"))
        //    {
        //        if (installId != "")
        //        {
        //            newId = installId.Substring(8);
        //            newId = Convert.ToString(Convert.ToUInt32(newId) + 1);
        //            installId = installId.Remove(8);
        //            installId = installId + newId;
        //        }
        //        else
        //        {
        //            installId = "X-SC-00001";
        //        }
        //    }
        //    Session["installId"] = installId;
        //    return installId;
        //}

        #endregion
    }
}