#region "-- Using --"

using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using JG_Prospect.Common;
using JG_Prospect.BLL;
using System.Data;
using JG_Prospect.App_Code;
using Saplin.Controls;
using JG_Prospect.Common.modal;
using System.Collections.Generic;
using System.Net.Mail;
using System.IO;
#endregion

namespace JG_Prospect.Sr_App
{
    public partial class TaskList : System.Web.UI.Page
    {
        #region '--Members--'

        private static string strAdminMode = "ADMINMODE";

        #endregion

        #region "-- Properties --"

        /// <summary>
        /// Set control view mode.
        /// </summary>
        public bool IsAdminMode
        {
            get
            {
                bool returnVal = false;

                if (ViewState[strAdminMode] != null)
                {
                    returnVal = Convert.ToBoolean(ViewState[strAdminMode]);
                }

                return returnVal;
            }
            set
            {
                ViewState[strAdminMode] = value;
            }

        }

        #endregion

        #region "--Page methods--"

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                CheckIsAdmin();
                SetControlDisplay();
                LoadFilters();
                SearchTasks();
            }
        }

        #endregion

        #region "-Control Events-"

        #region Filters - Search Task

        protected void ddlDesignation_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadFilterUsersByDesgination();
            SearchTasks();
        }

        protected void ddlUsers_SelectedIndexChanged(object sender, EventArgs e)
        {
            SearchTasks();
        }

        protected void ddlTaskStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
            SearchTasks();
        }

        protected void btnSearch_Click(object sender, ImageClickEventArgs e)
        {
            SearchTasks();
        }

        #endregion

        #region gvTasks - Task List

        protected void gvTasks_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                DataRowView drTask = e.Row.DataItem as DataRowView;

                HyperLink hypTask = e.Row.FindControl("hypTask") as HyperLink;
                Label lblDesignation = e.Row.FindControl("lblDesignation") as Label;
                Label lblAssignedUser = e.Row.FindControl("lblAssignedUser") as Label;
                DropDownCheckBoxes ddcbAssignedUser = e.Row.FindControl("ddcbAssignedUser") as DropDownCheckBoxes;
                LinkButton lbtnRequestStatus = e.Row.FindControl("lbtnRequestStatus") as LinkButton;
                Literal ltrlStatus = e.Row.FindControl("ltrlStatus") as Literal;
                DropDownList ddlStatus = e.Row.FindControl("ddlStatus") as DropDownList;
                Literal ltrlDueDate = e.Row.FindControl("ltrlDueDate") as Literal;

                hypTask.Text = drTask["Title"].ToString();
                if (hypTask.Text.Length > 55)
                {
                    hypTask.ToolTip = hypTask.Text;
                    hypTask.Text = hypTask.Text.Substring(0, 55) + "..";
                }
                hypTask.NavigateUrl = "~/sr_app/TaskGenerator.aspx?TaskId=" + drTask["TaskId"].ToString();

                lblDesignation.Text = drTask["TaskDesignations"].ToString();
                if (lblDesignation.Text.Length > 30)
                {
                    lblDesignation.ToolTip = lblDesignation.Text;
                    lblDesignation.Text = lblDesignation.Text.Substring(0, 30) + "..";
                }

                lblAssignedUser.Text = drTask["TaskAssignedUsers"].ToString();
                if (lblAssignedUser.Text.Length > 30)
                {
                    lblAssignedUser.ToolTip = lblAssignedUser.Text;
                    lblAssignedUser.Text = lblAssignedUser.Text.Substring(0, 30) + "..";
                }

                ltrlStatus.Text = ((TaskStatus)Convert.ToInt32(drTask["Status"])).ToString();
                ddlStatus.DataSource = CommonFunction.GetTaskStatusList();
                ddlStatus.DataTextField = "Text";
                ddlStatus.DataValueField = "Value";
                ddlStatus.DataBind();
                ddlStatus.SelectedValue = drTask["Status"].ToString();

                if (!string.IsNullOrEmpty(Convert.ToString(drTask["DueDate"])))
                {
                    ltrlDueDate.Text = Convert.ToDateTime(drTask["DueDate"]).ToString("MM-dd-yyyy");
                }

                if (this.IsAdminMode)
                {
                    #region Admin User

                    if (
                        ddlStatus.SelectedValue == Convert.ToByte(TaskStatus.Open).ToString() &&
                        string.IsNullOrEmpty(Convert.ToString(drTask["TaskAssignedUsers"]))
                       )
                    {
                        ddcbAssignedUser.Visible = true;
                        lbtnRequestStatus.Visible =
                        lblAssignedUser.Visible = false;

                        ddcbAssignedUser.Items.Clear();
                        ddcbAssignedUser.DataSource = TaskGeneratorBLL.Instance.GetInstallUsers(2, Convert.ToString(drTask["TaskDesignations"]).Trim());
                        ddcbAssignedUser.DataTextField = "FristName";
                        ddcbAssignedUser.DataValueField = "Id";
                        ddcbAssignedUser.DataBind();

                        ddcbAssignedUser.Attributes.Add("TaskId", drTask["TaskId"].ToString());
                        ddcbAssignedUser.Attributes.Add("TaskStatus", ddlStatus.SelectedValue);
                    }
                    else if (ddlStatus.SelectedValue == Convert.ToByte(TaskStatus.Requested).ToString())
                    {
                        lbtnRequestStatus.Visible = true;
                        ddcbAssignedUser.Visible =
                        lblAssignedUser.Visible = false;

                        string[] arrTaskAssignmentRequest = Convert.ToString(drTask["TaskAssignmentRequestUsers"]).Split(':');

                        if (arrTaskAssignmentRequest.Length > 1)
                        {
                            lbtnRequestStatus.Text = arrTaskAssignmentRequest[1];
                        }

                        lbtnRequestStatus.ForeColor = System.Drawing.Color.Red;
                        lbtnRequestStatus.CommandName = "approve-request";
                        lbtnRequestStatus.CommandArgument = string.Format(
                                                                            "{0}:{1}",
                                                                            drTask["TaskId"].ToString(),
                                                                            arrTaskAssignmentRequest[0]
                                                                          );
                    }
                    else
                    {
                        lblAssignedUser.Visible = true;
                        ddcbAssignedUser.Visible =
                        lbtnRequestStatus.Visible = false;
                    }

                    #endregion
                }
                else
                {
                    #region Install User

                    string strMyDesignation = Convert.ToString(Session["DesigNew"]).Trim().ToLower();

                    // show request link when,
                    // task status is open
                    // task assigned to my designation
                    if (ddlStatus.SelectedValue == Convert.ToByte(TaskStatus.Open).ToString() &&
                        strMyDesignation == Convert.ToString(drTask["TaskDesignations"]).Trim().ToLower())
                    {
                        lbtnRequestStatus.Visible = true;
                        ddcbAssignedUser.Visible =
                        lblAssignedUser.Visible = false;
                        lbtnRequestStatus.ForeColor = System.Drawing.Color.Green;
                        lbtnRequestStatus.CommandName = "request";
                        lbtnRequestStatus.CommandArgument = string.Format(
                                                                            "{0}:{1}",
                                                                            drTask["TaskId"].ToString(),
                                                                            drTask["CreatedBy"].ToString()
                                                                        );
                    }
                    else
                    {
                        ddcbAssignedUser.Visible =
                        lbtnRequestStatus.Visible = false;
                        lblAssignedUser.Visible = true;
                    }

                    #endregion
                }
            }
        }

        protected void gvTasks_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "request")
            {
                Task objTask = new Task()
                {
                    TaskId = Convert.ToInt32(e.CommandArgument.ToString().Split(':')[0]),
                    Status = Convert.ToByte(TaskStatus.Requested)
                };

                // update task status to requested.
                if (TaskGeneratorBLL.Instance.UpdateTaskStatus(objTask) > 0)
                {
                    // insert user request.
                    if (TaskGeneratorBLL.Instance.SaveTaskAssignmentRequests(Convert.ToUInt64(objTask.TaskId), Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()].ToString()))
                    {
                        SendEmailToAdminUser(objTask.TaskId, Convert.ToInt32(e.CommandArgument.ToString().Split(':')[1]));
                        SearchTasks();
                        CommonFunction.ShowAlertFromUpdatePanel(this.Page, "Task requested successfully!");
                    }
                    else
                    {
                        CommonFunction.ShowAlertFromUpdatePanel(this.Page, "Task was not requested successfully! Please try again later.");
                    }
                }
                else
                {
                    CommonFunction.ShowAlertFromUpdatePanel(this.Page, "Task was not requested successfully! Please try again later.");
                }
            }
            else if (e.CommandName == "approve-request")
            {
                Task objTask = new Task()
                {
                    TaskId = Convert.ToInt32(e.CommandArgument.ToString().Split(':')[0]),
                    Status = Convert.ToByte(TaskStatus.Assigned)
                };

                if (TaskGeneratorBLL.Instance.UpdateTaskStatus(objTask) > 0)
                {
                    // insert user request.
                    if (TaskGeneratorBLL.Instance.AcceptTaskAssignmentRequests(Convert.ToUInt64(objTask.TaskId), e.CommandArgument.ToString().Split(':')[1]))
                    {
                        SendEmailToAssignedUsers(objTask.TaskId,e.CommandArgument.ToString().Split(':')[1]);
                        SearchTasks();
                        CommonFunction.ShowAlertFromUpdatePanel(this.Page, "Task assigned successfully!");
                    }
                    else
                    {
                        CommonFunction.ShowAlertFromUpdatePanel(this.Page, "Task was not assigned successfully! Please try again later.");
                    }
                    CommonFunction.ShowAlertFromUpdatePanel(this.Page, "Task assigned successfully!");
                }
                else
                {
                    CommonFunction.ShowAlertFromUpdatePanel(this.Page, "Task was not assigned successfully! Please try again later.");
                }
            }
            //else if (e.CommandName == "RemoveTask")
            //{
            //    DeletaTask(e.CommandArgument.ToString());
            //}
        }

        protected void gvTasks_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvTasks.PageIndex = e.NewPageIndex;
            SearchTasks();
        }

        protected void gvTasks_ddcbAssignedUser_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        protected void gvTasks_ddlStatus_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        #endregion

        #endregion

        #region "--Methods--"

        private void CheckIsAdmin()
        {
            this.IsAdminMode = CommonFunction.CheckAdminMode();
        }

        private void SetControlDisplay()
        {
            if (!this.IsAdminMode)
            {
                tdDesig.Visible = false;
                tdDesigCap.Visible = false;
                tdUserCap.Visible = false;
                tdUsers.Visible = false;
            }
        }

        /// <summary>
        /// Load filter dropdowns for task
        /// </summary>
        private void LoadFilters()
        {

            DataSet dsFilters = TaskGeneratorBLL.Instance.GetAllUsersNDesignationsForFilter();

            ddlTaskStatus.DataSource = CommonFunction.GetTaskStatusList();
            ddlTaskStatus.DataTextField = "Text";
            ddlTaskStatus.DataValueField = "Value";
            ddlTaskStatus.DataBind();
            ddlTaskStatus.Items.Insert(0, new ListItem("--All--", "0"));

            ddlUsers.DataSource = dsFilters.Tables[0];
            ddlUsers.DataTextField = "FirstName";
            ddlUsers.DataValueField = "Id";
            ddlUsers.DataBind();
            ddlUsers.Items.Insert(0, new ListItem("--All--", "0"));
        }

        /// <summary>
        /// Search tasks with parameters choosen by user.
        /// </summary>
        private void SearchTasks()
        {
            int? UserID = null;
            string Title = String.Empty, Designation = String.Empty, Designations = String.Empty, Statuses = String.Empty;
            Int16? Status = null;
            DateTime? CreatedFrom = null, CreatedTo = null;

            // this is for paging based data fetch, in header view case it will be always page numnber 0 and page size 5
            int Start = gvTasks.PageIndex, PageLimit = gvTasks.PageSize;

            PrepareSearchFilters(ref UserID, ref Title, ref Designation, ref Status, ref CreatedFrom, ref CreatedTo, ref Statuses, ref Designations);

            DataSet dsResult = TaskGeneratorBLL.Instance.GetTasksList(UserID, Title, Designation, Status, CreatedFrom, CreatedTo, Statuses, Designations, this.IsAdminMode, Start, PageLimit);

            gvTasks.VirtualItemCount = Convert.ToInt32(dsResult.Tables[1].Rows[0]["VirtualCount"].ToString());

            gvTasks.DataSource = dsResult;
            gvTasks.DataBind();
        }

        /// <summary>
        /// Prepare search filters choosen by users before performing search
        /// </summary>
        /// <param name="UserID"></param>
        /// <param name="Title"></param>
        /// <param name="Designation"></param>
        /// <param name="Status"></param>
        /// <param name="CreatedOn"></param>
        private void PrepareSearchFilters(ref int? UserID, ref string Title, ref string Designation, ref short? Status, ref DateTime? CreatedFrom, ref DateTime? CreatedTo, ref string Statuses, ref string Designations)
        {
            if (this.IsAdminMode)
            {
                if (ddlUsers.SelectedIndex > 0)
                {
                    UserID = Convert.ToInt32(ddlUsers.SelectedItem.Value);
                }

                if (ddlDesignation.SelectedIndex > 0)
                {
                    Designations =
                    Designation = ddlDesignation.SelectedItem.Value;
                }
                else
                {
                    Designations =
                    Designation = "0";
                }

                if (ddlTaskStatus.SelectedIndex > 0)
                {
                    Status = Convert.ToInt16(ddlTaskStatus.SelectedItem.Value);
                }
            }
            else
            {
                UserID = Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);

                Designation =
                Designations = GetUserDepartmentAllDesignations(Session["DesigNew"].ToString());

                //search all status for now, later if requirement changed can remove status accordingly.
                Statuses = "1,2,3,4,5,6";
            }

            if (!String.IsNullOrEmpty(txtSearch.Text))
            {
                Title = txtSearch.Text;
            }

            if (!String.IsNullOrEmpty(txtFromDate.Text) && !String.IsNullOrEmpty(txtToDate.Text))
            {
                CreatedFrom = Convert.ToDateTime(txtFromDate.Text);
                CreatedTo = Convert.ToDateTime(txtToDate.Text);
            }
        }

        /// <summary>
        /// Get all designations from department to which user's designation belongs to.
        /// Ex. if user has designation IT - Network Admin , here all IT related task will be listed.
        /// </summary>
        /// <param name="UserDesignation"></param>
        /// <returns></returns>
        private string GetUserDepartmentAllDesignations(string UserDesignation)
        {
            string returnString = string.Empty;
            const string ITDesignations = "IT - Network Admin,IT - Jr .Net Developer,IT - Sr .Net Developer,IT - Android Developer,IT - PHP Developer,IT - SEO / BackLinking";

            if (UserDesignation.Contains("IT"))
            {
                returnString = ITDesignations;
            }
            else
            {
                returnString = UserDesignation;
            }

            return returnString;
        }

        private void LoadFilterUsersByDesgination()
        {
            ddlUsers.DataSource = TaskGeneratorBLL.Instance.GetInstallUsers(2, ddlDesignation.SelectedValue);
            ddlUsers.DataTextField = "FristName";
            ddlUsers.DataValueField = "Id";
            ddlUsers.DataBind();

            ddlUsers.Items.Insert(0, new ListItem("--All--", "0"));
        }

        private void SendEmailToAssignedUsers(int intTaskId, string strInstallUserIDs)
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
                    strBody = strBody.Replace("#TaskLink#", string.Format("{0}://{1}/sr_app/TaskGenerator.aspx?TaskId={2}", Request.Url.Scheme, Request.Url.Host.ToString(), intTaskId));

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

        private void SendEmailToAdminUser(int intTaskId,int intTaskCreatedBy)
        {
            try
            {
                if (intTaskCreatedBy > 0)
                {
                    string strHTMLTemplateName = "Task Assignment Requested";
                    DataSet dsEmailTemplate = AdminBLL.Instance.GetEmailTemplate(strHTMLTemplateName,109);
                    DataSet dsUser = TaskGeneratorBLL.Instance.GetUserDetails(intTaskCreatedBy);
                    if (dsUser == null || dsUser.Tables.Count == 0 || dsUser.Tables[0].Rows.Count == 0)
                    {
                        dsUser = TaskGeneratorBLL.Instance.GetInstallUserDetails(intTaskCreatedBy);
                    }

                    string emailId = dsUser.Tables[0].Rows[0]["Email"].ToString();
                    string FName = dsUser.Tables[0].Rows[0]["FristName"].ToString();
                    string LName = dsUser.Tables[0].Rows[0]["LastName"].ToString();
                    string fullname = FName + " " + LName;

                    string strHeader = dsEmailTemplate.Tables[0].Rows[0]["HTMLHeader"].ToString();
                    string strBody = dsEmailTemplate.Tables[0].Rows[0]["HTMLBody"].ToString();
                    string strFooter = dsEmailTemplate.Tables[0].Rows[0]["HTMLFooter"].ToString();
                    string strsubject = dsEmailTemplate.Tables[0].Rows[0]["HTMLSubject"].ToString();

                    strBody = strBody.Replace("#Fname#", fullname);
                    strBody = strBody.Replace("#TaskLink#", string.Format("{0}://{1}/sr_app/TaskGenerator.aspx?TaskId={2}", Request.Url.Scheme, Request.Url.Host.ToString(), intTaskId));

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
    }
}