#region "-- using --"

using JG_Prospect.BLL;
using JG_Prospect.Common;
using JG_Prospect.Common.modal;
using Saplin.Controls;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Net;
using System.Net.Mail;
using System.Globalization;
using System.Configuration;
using Ionic.Zip;
using JG_Prospect.App_Code;
using System.Web.Services;
using Newtonsoft.Json;
using System.Linq;
using System.Web.UI.HtmlControls;
using CKEditor.NET;

#endregion

namespace JG_Prospect.Sr_App
{
    public partial class TaskGenerator : System.Web.UI.Page
    {
        #region "--Members--"

        string strSubtaskSeq = "sbtaskseq";

        #endregion

        #region "--Properties--"

        /// <summary>
        /// Set control view mode.
        /// </summary>
        public bool IsAdminMode
        {
            get
            {
                bool returnVal = false;

                if (ViewState["AMODE"] != null)
                {
                    returnVal = Convert.ToBoolean(ViewState["AMODE"]);
                }

                return returnVal;
            }
            set
            {
                ViewState["AMODE"] = value;
            }
        }

        /// <summary>
        /// Set control view mode.
        /// </summary>
        public bool IsAdminAndItLeadMode
        {
            get
            {
                bool returnVal = false;

                if (ViewState["AIMODE"] != null)
                {
                    returnVal = Convert.ToBoolean(ViewState["AIMODE"]);
                }

                return returnVal;
            }
            set
            {
                ViewState["AIMODE"] = value;
            }
        }

        public int TaskCreatedBy
        {
            get
            {
                if (ViewState["TaskCreatedBy"] == null)
                {
                    return 0;
                }
                return Convert.ToInt32(ViewState["TaskCreatedBy"]);
            }
            set
            {
                ViewState["TaskCreatedBy"] = value;
            }
        }

        private DataTable dtTaskUserFiles
        {
            get
            {
                if (ViewState["dtTaskUserFiles"] == null)
                {
                    DataTable dt = new DataTable();
                    dt.Columns.Add("attachment");
                    dt.Columns.Add("FirstName");
                    ViewState["dtTaskUserFiles"] = dt;
                }
                return (DataTable)ViewState["dtTaskUserFiles"];
            }
            set
            {
                ViewState["dtTaskUserFiles"] = value;
            }
        }

        #endregion

        #region "--Page Events--"

        protected void Page_Load(object sender, EventArgs e)
        {
            CommonFunction.AuthenticateUser();

            if (!IsPostBack)
            {
                clearAllFormData();

                this.IsAdminMode = CommonFunction.CheckAdminMode();
                this.IsAdminAndItLeadMode = CommonFunction.CheckAdminAndItLeadMode();

                SetTaskView();

                FillDropdowns();

                // edit mode, if task id is provided in query string parameter.
                if (!string.IsNullOrEmpty(Request.QueryString["TaskId"]))
                {
                    controlMode.Value = "1";
                    hdnTaskId.Value = Request.QueryString["TaskId"].ToString();
                }
                else
                {
                    controlMode.Value = "0";
                    hdnTaskId.Value = "0";

                    // set default specs in progress status for It Leads.
                    if (this.IsAdminAndItLeadMode)
                    {
                        ListItem objSpecsInProgress = cmbStatus.Items.FindByValue(Convert.ToByte(JGConstant.TaskStatus.SpecsInProgress).ToString());
                        objSpecsInProgress.Enabled = true;
                        objSpecsInProgress.Selected = true;
                        //cmbStatus.Enabled = false;
                    }
                }

                string strAction = Convert.ToString(Request.QueryString["Action"]);

                if (!string.IsNullOrEmpty(strAction) && strAction == "tws")
                {
                    ShowWorkSpecificationSection(true);
                }
            }

            #region Task Work Specifications

            objucTaskWorkSpecifications.TaskId = Convert.ToInt32(hdnTaskId.Value);
            objucTaskWorkSpecifications.TaskStatus = (JGConstant.TaskStatus)(Convert.ToInt32(cmbStatus.SelectedValue));
            objucTaskWorkSpecifications.UserAcceptance = Convert.ToBoolean(Convert.ToInt32(ddlUserAcceptance.SelectedValue));
            objucTaskWorkSpecifications.IsAdminMode = this.IsAdminMode;
            objucTaskWorkSpecifications.IsAdminAndItLeadMode = this.IsAdminAndItLeadMode;

            #endregion

            #region Sub Tasks

            int intHighlightedTaskId = 0;

            if (Request.QueryString["hstid"]!= null)
            {
                intHighlightedTaskId = Convert.ToInt32(Request.QueryString["hstid"].ToString());
            }

            objucSubTasks_Admin.TaskId = Convert.ToInt32(hdnTaskId.Value);
            objucSubTasks_Admin.TaskStatus = (JGConstant.TaskStatus)(Convert.ToInt32(cmbStatus.SelectedValue));
            objucSubTasks_Admin.UserAcceptance = Convert.ToBoolean(Convert.ToInt32(ddlUserAcceptance.SelectedValue));
            objucSubTasks_Admin.HighlightedTaskId = intHighlightedTaskId;
            objucSubTasks_Admin.IsAdminMode = this.IsAdminMode;
            objucSubTasks_Admin.controlMode = controlMode.Value;
            objucSubTasks_Admin.SetSubTaskView();

            objucSubTasks_User.TaskId = Convert.ToInt32(hdnTaskId.Value);
            objucSubTasks_User.HighlightedTaskId = intHighlightedTaskId;
            objucSubTasks_User.IsAdminMode = this.IsAdminMode;
            objucSubTasks_User.controlMode = controlMode.Value;
            objucSubTasks_User.SetSubTaskView();

            #endregion

            #region Task History

            objucTaskHistory_Admin.TaskId = Convert.ToInt64(hdnTaskId.Value);
            objucTaskHistory_Admin.TaskStatus = (JGConstant.TaskStatus)(Convert.ToInt32(cmbStatus.SelectedValue));
            objucTaskHistory_Admin.UserAcceptance = Convert.ToBoolean(Convert.ToInt32(ddlUserAcceptance.SelectedValue));
            objucTaskHistory_Admin.LoadTaskData = LoadTaskData;

            objucTaskHistory_User.TaskId = Convert.ToInt64(hdnTaskId.Value);
            objucTaskHistory_User.TaskStatus = (JGConstant.TaskStatus)(Convert.ToInt32(cmbStatus.SelectedValue));
            objucTaskHistory_User.UserAcceptance = Convert.ToBoolean(Convert.ToInt32(ddlUserAcceptance.SelectedValue));
            objucTaskHistory_User.LoadTaskData = LoadTaskData;

            #endregion

            if (!IsPostBack)
            {
                if (hdnTaskId.Value != "0")
                {
                    LoadTaskData(hdnTaskId.Value);
                }
            }
        }

        #endregion

        #region "--Control Events--"

        protected void ddlUserDesignation_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadUsersByDesgination();

            ddlAssignedUsers_SelectedIndexChanged(sender, e);

            ddlUserDesignation.Texts.SelectBoxCaption = "Select";

            foreach (ListItem item in ddlUserDesignation.Items)
            {
                if (item.Selected)
                {
                    ddlUserDesignation.Texts.SelectBoxCaption = item.Text;
                    break;
                }
            }
        }

        protected void ddlAssignedUsers_SelectedIndexChanged(object sender, EventArgs e)
        {
            ddlAssignedUsers.Texts.SelectBoxCaption = "--Open--";

            foreach (ListItem item in ddlAssignedUsers.Items)
            {
                if (item.Selected)
                {
                    ddlAssignedUsers.Texts.SelectBoxCaption = item.Text;
                    break;
                }
            }
        }

        protected void rptAttachment_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DownloadFile")
            {
                string[] files = e.CommandArgument.ToString().Split(new char[] { '@' }, StringSplitOptions.RemoveEmptyEntries);

                DownloadUserAttachment(files[0].Trim(), files[1].Trim());
            }
        }

        protected void rptAttachment_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                string file = Convert.ToString(e.Item.DataItem);

                string[] files = file.Split(new char[] { '@' }, StringSplitOptions.RemoveEmptyEntries);

                LinkButton lbtnAttchment = (LinkButton)e.Item.FindControl("lbtnDownload");

                if (files[1].Length > 13)// sort name with ....
                {
                    lbtnAttchment.Text = String.Concat(files[1].Substring(0, 12), "..");
                    lbtnAttchment.Attributes.Add("title", files[1]);

                    ScriptManager.GetCurrent(this.Page).RegisterPostBackControl(lbtnAttchment);
                }
                else
                {
                    lbtnAttchment.Text = files[1];
                }

                lbtnAttchment.CommandArgument = file;
            }
        }

        protected void btnSaveTask_Click(object sender, EventArgs e)
        {
            if (ValidateTaskStatus())
            {
                InsertUpdateTask();

                RedirectToViewTasks();
            }
        }

        protected void lbtnDeleteTask_Click(object sender, EventArgs e)
        {
            DeletaTask(hdnTaskId.Value);
            ScriptManager.RegisterStartupScript((sender as Control), this.GetType(), "HidePopup", "CloseTaskPopup();", true);
        }

        #region '--Task Acceptance--'

        protected void lbtnAcceptTask_Click(object sender, EventArgs e)
        {
            bool isSuccessful = TaskGeneratorBLL.Instance.SaveTaskAssignedUsers(Convert.ToUInt64(hdnTaskId.Value), JG_Prospect.JGSession.UserId.ToString());
            if (isSuccessful)
            {
                TaskAcceptance objTaskAcceptance = new TaskAcceptance();
                objTaskAcceptance.IsAccepted = true;
                objTaskAcceptance.IsInstallUser = JGSession.IsInstallUser.Value;
                objTaskAcceptance.UserId = JGSession.UserId;
                objTaskAcceptance.TaskId = Convert.ToInt64(hdnTaskId.Value);

                if (TaskGeneratorBLL.Instance.InsertTaskAcceptance(objTaskAcceptance) >= 0)
                {
                    divAcceptRejectButtons.Visible = false;
                }

                CommonFunction.ShowAlertFromUpdatePanel(this, "Task accepted successfully");
            }
            else
            {
                CommonFunction.ShowAlertFromUpdatePanel(this, "Task acceptance was not successfull, Please try again later.");
            }
        }

        protected void lbtnRejectTask_Click(object sender, EventArgs e)
        {
            TaskAcceptance objTaskAcceptance = new TaskAcceptance();
            objTaskAcceptance.IsAccepted = false;
            objTaskAcceptance.IsInstallUser = JGSession.IsInstallUser.Value;
            objTaskAcceptance.UserId = JGSession.UserId;
            objTaskAcceptance.TaskId = Convert.ToInt64(hdnTaskId.Value);

            if (TaskGeneratorBLL.Instance.InsertTaskAcceptance(objTaskAcceptance) >= 0)
            {
                divAcceptRejectButtons.Visible = false;

                CommonFunction.ShowAlertFromUpdatePanel(this, "Task rejected successfully");
            }
            else
            {
                CommonFunction.ShowAlertFromUpdatePanel(this, "Task rejection was not successfull, Please try again later.");
            }
        }

        protected void lbtnViewAcceptanceLog_Click(object sender, EventArgs e)
        {
            FillAcceptanceLog();

            upAcceptanceLog.Update();

            ScriptManager.RegisterStartupScript(
                                                    (sender as Control),
                                                    this.GetType(),
                                                    "ShowPopup_AcceptanceLog",
                                                    string.Format(
                                                                    "ShowPopup(\"#{0}\");",
                                                                    divAcceptanceLog.ClientID
                                                                ),
                                                    true
                                              );
        }

        #endregion

        #region '--Work Specification Section--'

        protected void lbtnShowWorkSpecificationSection_Click(object sender, EventArgs e)
        {
            if (controlMode.Value == "0")
            {
                if (ValidateTaskStatus())
                {
                    InsertUpdateTask();

                    RedirectToViewTasks("tws");
                }
            }
            else
            {
                ShowWorkSpecificationSection(false);
            }
        }

        protected void lbtnShowFinishedWorkFiles_Click(object sender, EventArgs e)
        {
            if (controlMode.Value == "0")
            {
                if (ValidateTaskStatus())
                {
                    InsertUpdateTask();

                    RedirectToViewTasks("tws");
                }
            }
            else
            {
                ShowWorkSpecificationSection(false);
            }
        }

        #region Work Specifications

        protected void repWorkSpecifications_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                HtmlTableRow trWorkSpecification = e.Item.FindControl("trWorkSpecification") as HtmlTableRow;
                LinkButton lbtnEditWorkSpecification = e.Item.FindControl("lbtnEditWorkSpecification") as LinkButton;
                Literal ltrlCustomId = e.Item.FindControl("ltrlCustomId") as Literal;
                Literal ltrlDescription = e.Item.FindControl("ltrlDescription") as Literal;
                CKEditorControl ckeWorkSpecification = e.Item.FindControl("ckeWorkSpecification") as CKEditorControl;

                if (e.Item.ItemType == ListItemType.Item)
                {
                    trWorkSpecification.Attributes.Add("class", "FirstRow");
                }
                else
                {
                    trWorkSpecification.Attributes.Add("class", "AlternateRow");
                }

                DataRowView drWorkSpecification = e.Item.DataItem as DataRowView;

                ltrlDescription.Text = HttpUtility.HtmlDecode(drWorkSpecification["Description"].ToString());
                ltrlDescription.Text = (new System.Text.RegularExpressions.Regex(@"(<[\w\s\=\""\-\/\:\:]*/>)|(<[\w\s\=\""\-\/\:\:]*>)|(</[\w\s\=\""\-\/\:\:]*>)")).Replace(ltrlDescription.Text, " ").Trim();

                ckeWorkSpecification.Text = HttpUtility.HtmlDecode(drWorkSpecification["Description"].ToString());

                if (this.IsAdminAndItLeadMode)
                {
                    if (!string.IsNullOrEmpty(drWorkSpecification["AdminStatus"].ToString()))
                    {
                        // do not allow edit for specifications freezed by both.
                        if (Convert.ToBoolean(drWorkSpecification["AdminStatus"]) && Convert.ToBoolean(drWorkSpecification["TechLeadStatus"]))
                        {
                            lbtnEditWorkSpecification.Visible = false;
                        }
                        else
                        {
                            ltrlCustomId.Visible = false;
                        }
                    }
                    else
                    {
                        ltrlCustomId.Visible =
                        lbtnEditWorkSpecification.Visible = false;
                    }
                }
                else
                {
                    lbtnEditWorkSpecification.Visible = false;
                }
            }
        }

        protected void txtPasswordToFreezeSpecification_TextChanged(object sender, EventArgs e)
        {
            //if (this.IsAdminAndItLeadMode)
            {
                #region Freeze Based On Password

                TextBox txtPassword = sender as TextBox;

                if (txtPassword != null && !string.IsNullOrEmpty(txtPassword.Text))
                {
                    if (!txtPassword.Text.Equals(Convert.ToString(Session["loginpassword"])))
                    {
                        CommonFunction.ShowAlertFromUpdatePanel(this, "Specification cannot be freezed as password is not valid.");
                    }
                    else
                    {
                        // Freeze all specifications
                        TaskWorkSpecification objTaskWorkSpecification = new TaskWorkSpecification();
                        objTaskWorkSpecification.TaskId = Convert.ToInt64(hdnTaskId.Value);

                        bool blIsAdmin, blIsTechLead, blIsUser;

                        blIsAdmin = blIsTechLead = blIsUser = false;
                        if (HttpContext.Current.Session["DesigNew"].ToString().ToUpper().Equals("ADMIN"))
                        {
                            objTaskWorkSpecification.AdminUserId = Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
                            objTaskWorkSpecification.IsAdminInstallUser = JGSession.IsInstallUser.Value;
                            objTaskWorkSpecification.AdminStatus = true;
                            blIsAdmin = true;
                        }
                        else if (HttpContext.Current.Session["DesigNew"].ToString().ToUpper().Equals("ITLEAD"))
                        {
                            objTaskWorkSpecification.TechLeadUserId = Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
                            objTaskWorkSpecification.IsTechLeadInstallUser = JGSession.IsInstallUser.Value;
                            objTaskWorkSpecification.TechLeadStatus = true;
                            blIsTechLead = true;
                        }
                        else
                        {
                            objTaskWorkSpecification.OtherUserId = Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
                            objTaskWorkSpecification.IsOtherUserInstallUser = JGSession.IsInstallUser.Value;
                            objTaskWorkSpecification.OtherUserStatus = true;
                            blIsUser = true;
                        }

                        TaskGeneratorBLL.Instance.UpdateTaskWorkSpecificationStatusByTaskId
                                                    (
                                                        objTaskWorkSpecification,
                                                        blIsAdmin,
                                                        blIsTechLead,
                                                        blIsUser
                                                    );

                        CommonFunction.ShowAlertFromUpdatePanel(this, "Specification freezed successfully.");
                    }
                }

                #endregion

                #region Update Task and Status

                // change status only after freezing all specifications.
                // this will change disabled "specs in progress" status to open on feezing.
                SetPasswordToFreezeWorkSpecificationUI();

                // update task status.
                Task objTask = new Task();
                objTask.TaskId = Convert.ToInt32(hdnTaskId.Value);
                objTask.Status = Convert.ToByte(cmbStatus.SelectedValue);

                TaskGeneratorBLL.Instance.UpdateTaskStatus(objTask);

                #endregion

                ScriptManager.RegisterStartupScript(
                                                    (sender as Control),
                                                    this.GetType(),
                                                    "Initialize_WorkSpecifications_Script",
                                                    "Initialize_WorkSpecifications();",
                                                    true
                                                   );
            }
        }

        #endregion

        #region Work Specification Attachments

        protected void grdWorkSpecificationAttachments_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                string file = Convert.ToString(DataBinder.Eval(e.Item.DataItem, "attachment"));

                string[] files = file.Split(new char[] { '@' }, StringSplitOptions.RemoveEmptyEntries);

                LinkButton lbtnAttchment = (LinkButton)e.Item.FindControl("lbtnDownload");

                if (files[1].Length > 40)// sort name with ....
                {
                    lbtnAttchment.Text = String.Concat(files[1].Substring(0, 40), "..");
                    lbtnAttchment.Attributes.Add("title", files[1]);
                }
                else
                {
                    lbtnAttchment.Text = files[1];
                }
                ScriptManager.GetCurrent(this.Page).RegisterPostBackControl(lbtnAttchment);
                lbtnAttchment.CommandArgument = file;

                if (CommonFunction.IsImageFile(files[0].Trim()))
                {
                    ((HtmlImage)e.Item.FindControl("imgIcon")).Src = String.Concat("~/TaskAttachments/", Server.UrlEncode(files[0].Trim()));
                }
                else
                {
                    ((HtmlImage)e.Item.FindControl("imgIcon")).Src = CommonFunction.GetFileTypeIcon(files[0].Trim());
                }
            }
        }

        protected void grdWorkSpecificationAttachments_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "download-attachment")
            {
                string[] files = e.CommandArgument.ToString().Split(new char[] { '@' }, StringSplitOptions.RemoveEmptyEntries);

                DownloadUserAttachment(files[0].Trim(), files[1].Trim());
            }
            else if (e.CommandName == "delete-attachment")
            {
                DeleteWorkSpecificationFile(e.CommandArgument.ToString());
            }
        }

        private void DeleteWorkSpecificationFile(string parameter)
        {
            // Seperate DB Id and Filename from parameter.
            string[] parameters = parameter.Split('|');

            if (parameter.Length > 0)
            {
                string id = parameters[0];
                string[] fileNames = parameters[1].Split('@');//Id

                TaskUser taskUserFiles = new TaskUser();

                //Remove file from database
                bool blnFileDeletedFromDb = TaskGeneratorBLL.Instance.DeleteTaskUserFile(Convert.ToInt64(id));  // save task files

                //if file removed from database, remove from server file system.
                if (fileNames.Length > 0 && blnFileDeletedFromDb)
                {
                    string filetodelete = fileNames[0];
                    DeletefilefromServer(filetodelete);
                }

            }

            //Reload records.
            FillWorkSpecificationAttachments();
        }

        private void DeletefilefromServer(string filetodelete)
        {
            if (!String.IsNullOrEmpty(filetodelete))
            {
                var originalDirectory = new DirectoryInfo(Server.MapPath("~/TaskAttachments"));


                string pathString = System.IO.Path.Combine(originalDirectory.ToString(), filetodelete);

                bool isExists = System.IO.File.Exists(pathString);

                if (isExists)
                    File.Delete(pathString);


            }


        }

        protected void btnAddAttachment_ClicK(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(hdnWorkFiles.Value))
            {
                if (controlMode.Value == "0")
                {
                    #region '-- Save To Viewstate --'

                    foreach (string strAttachment in hdnWorkFiles.Value.Split('^'))
                    {
                        DataRow drTaskUserFiles = dtTaskUserFiles.NewRow();
                        drTaskUserFiles["attachment"] = strAttachment;
                        drTaskUserFiles["FirstName"] = Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.Username.ToString()]);
                        dtTaskUserFiles.Rows.Add(drTaskUserFiles);
                    }

                    #endregion
                }
                else
                {
                    #region '-- Save To Database --'

                    UploadUserAttachements(null, Convert.ToInt32(hdnTaskId.Value), hdnWorkFiles.Value, JGConstant.TaskFileDestination.WorkSpecification);

                    FillWorkSpecificationAttachments();
                    #endregion
                }

                hdnWorkFiles.Value = "";
            }
        }

        protected void grdWorkSpecificationAttachments_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                string file = Convert.ToString(DataBinder.Eval(e.Row.DataItem, "attachment"));

                string[] files = file.Split(new char[] { '@' }, StringSplitOptions.RemoveEmptyEntries);

                LinkButton lbtnAttchment = (LinkButton)e.Row.FindControl("lbtnDownload");

                if (files[1].Length > 40)// sort name with ....
                {
                    lbtnAttchment.Text = String.Concat(files[1].Substring(0, 40), "..");
                    lbtnAttchment.Attributes.Add("title", files[1]);
                }
                else
                {
                    lbtnAttchment.Text = files[1];
                }
                ScriptManager.GetCurrent(this.Page).RegisterPostBackControl(lbtnAttchment);
                lbtnAttchment.CommandArgument = file;
            }
        }

        protected void grdWorkSpecificationAttachments_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "DownloadFile")
            {
                string[] files = e.CommandArgument.ToString().Split(new char[] { '@' }, StringSplitOptions.RemoveEmptyEntries);

                DownloadUserAttachment(files[0].Trim(), files[1].Trim());
            }
        }

        #endregion

        #endregion

        #endregion

        #region "--Private Methods--"

        private void RedirectToViewTasks(string strAction = "")
        {
            Response.Redirect("~/sr_app/TaskGenerator.aspx?TaskId=" + hdnTaskId.Value + "&Action=" + strAction);
        }

        /// <summary>
        /// To load Designation to popup dropdown
        /// </summary>
        private void FillDropdowns()
        {
            cmbStatus.DataSource = CommonFunction.GetTaskStatusList();
            cmbStatus.DataTextField = "Text";
            cmbStatus.DataValueField = "Value";
            cmbStatus.DataBind();
            //cmbStatus.Items.FindByValue(Convert.ToByte(JGConstant.TaskStatus.SpecsInProgress).ToString()).Enabled = false;

            ddlTaskPriority.DataSource = CommonFunction.GetTaskPriorityList();
            ddlTaskPriority.DataTextField = "Text";
            ddlTaskPriority.DataValueField = "Value";
            ddlTaskPriority.DataBind();

            ddlTUStatus.DataSource = CommonFunction.GetTaskStatusList();
            ddlTUStatus.DataTextField = "Text";
            ddlTUStatus.DataValueField = "Value";
            ddlTUStatus.DataBind();
            //ddlTUStatus.Items.FindByValue(Convert.ToByte(JGConstant.TaskStatus.SpecsInProgress).ToString()).Enabled = false;
        }

        private void DeletaTask(string TaskId)
        {
            TaskGeneratorBLL.Instance.DeleteTask(Convert.ToUInt64(TaskId));
            hdnTaskId.Value = string.Empty;
            RedirectToViewTasks();
        }

        private void UpdateTaskStatus(Int32 taskId, UInt16 Status)
        {
            Task task = new Task();
            task.TaskId = taskId;
            task.Status = Status;

            int result = TaskGeneratorBLL.Instance.UpdateTaskStatus(task);    // save task master details

            RedirectToViewTasks();

            String AlertMsg;

            if (result > 0)
            {
                AlertMsg = "Status changed successfully!";

            }
            else
            {
                AlertMsg = "Status change was not successfull, Please try again later.";
            }

            CommonFunction.ShowAlertFromUpdatePanel(this.Page, AlertMsg);

        }

        private string GetInstallIdFromDesignation(string designame)
        {
            string prefix = "";
            switch (designame)
            {
                case "Admin":
                    prefix = "ADM";
                    break;
                case "Jr. Sales":
                    prefix = "JSL";
                    break;
                case "Jr Project Manager":
                    prefix = "JPM";
                    break;
                case "Office Manager":
                    prefix = "OFM";
                    break;
                case "Recruiter":
                    prefix = "REC";
                    break;
                case "Sales Manager":
                    prefix = "SLM";
                    break;
                case "Sr. Sales":
                    prefix = "SSL";
                    break;
                case "IT - Network Admin":
                    prefix = "ITNA";
                    break;
                case "IT - Jr .Net Developer":
                    prefix = "ITJN";
                    break;
                case "IT - Sr .Net Developer":
                    prefix = "ITSN";
                    break;
                case "IT - Android Developer":
                    prefix = "ITAD";
                    break;
                case "IT - PHP Developer":
                    prefix = "ITPH";
                    break;
                case "IT - SEO / BackLinking":
                    prefix = "ITSB";
                    break;
                case "Installer - Helper":
                    prefix = "INH";
                    break;
                case "Installer – Journeyman":
                    prefix = "INJ";
                    break;
                case "Installer – Mechanic":
                    prefix = "INM";
                    break;
                case "Installer - Lead mechanic":
                    prefix = "INLM";
                    break;
                case "Installer – Foreman":
                    prefix = "INF";
                    break;
                case "Commercial Only":
                    prefix = "COM";
                    break;
                case "SubContractor":
                    prefix = "SBC";
                    break;
                default:
                    prefix = "TSK";
                    break;
            }
            return prefix;
        }

        private void LoadUsersByDesgination()
        {
            DataSet dsUsers;

            // DropDownCheckBoxes ddlAssign = (FindControl("ddlAssignedUsers") as DropDownCheckBoxes);
            // DropDownList ddlDesignation = (DropDownList)sender;

            string designations = GetSelectedDesignationsString();

            dsUsers = TaskGeneratorBLL.Instance.GetInstallUsers(2, designations);

            ddlAssignedUsers.Items.Clear();
            ddlAssignedUsers.DataSource = dsUsers;
            ddlAssignedUsers.DataTextField = "FristName";
            ddlAssignedUsers.DataValueField = "Id";
            ddlAssignedUsers.DataBind();

            HighlightInterviewUsers(dsUsers.Tables[0], ddlAssignedUsers, null);
        }

        private void HighlightInterviewUsers(DataTable dtUsers, DropDownCheckBoxes ddlUsers, DropDownList ddlFilterUsers)
        {
            if (dtUsers.Rows.Count > 0)
            {
                var rows = dtUsers.AsEnumerable();

                //get all users comma seperated ids with interviewdate status
                String InterviewDateUsers = String.Join(",", (from r in rows where (r.Field<string>("Status") == "InterviewDate" || r.Field<string>("Status") == "Interview Date") select r.Field<Int32>("Id").ToString()));

                // for each userid find it into user dropdown list and apply red color to it.
                foreach (String user in InterviewDateUsers.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
                {
                    ListItem item;

                    if (ddlUsers != null)
                    {
                        item = ddlUsers.Items.FindByValue(user);
                    }
                    else
                    {
                        item = ddlFilterUsers.Items.FindByValue(user);
                    }

                    if (item != null)
                    {
                        item.Attributes.Add("style", "color:red;");
                    }
                }

            }
        }

        private string GetSelectedDesignationsString()
        {
            String returnVal = string.Empty;
            StringBuilder sbDesignations = new StringBuilder();

            foreach (ListItem item in ddlUserDesignation.Items)
            {
                if (item.Selected)
                {
                    sbDesignations.Append(String.Concat(item.Text, ","));
                }
            }

            if (sbDesignations.Length > 0)
            {
                returnVal = sbDesignations.ToString().Substring(0, sbDesignations.ToString().Length - 1);
            }

            return returnVal;
        }

        private bool ValidateTaskStatus()
        {
            bool blResult = true;

            string strStatus = string.Empty;
            string strMessage = string.Empty;

            if (this.IsAdminMode)
            {
                strStatus = cmbStatus.SelectedValue;

                if (!string.IsNullOrEmpty(strStatus))
                {
                    //if (
                    //    strStatus != Convert.ToByte(JGConstant.TaskStatus.SpecsInProgress).ToString() && 
                    //    !TaskGeneratorBLL.Instance.IsTaskWorkSpecificationApproved(Convert.ToInt32(hdnTaskId.Value))
                    //   )
                    //{
                    //    blResult = false;
                    //    strMessage = "Task work specifications must be approved, to change status from Specs In Progress.";
                    //}
                    //else 
                    // if task is in assigned status. it should have assigned user selected there in dropdown. 
                    if (strStatus == Convert.ToByte(JGConstant.TaskStatus.Assigned).ToString())
                    {
                        blResult = false;
                        strMessage = "Task must be assigned to one or more users, to change status to assigned.";

                        foreach (ListItem objItem in ddlAssignedUsers.Items)
                        {
                            if (objItem.Selected)
                            {
                                blResult = true;
                                break;
                            }
                        }
                    }
                }

                if (!blResult)
                {
                    CommonFunction.ShowAlertFromUpdatePanel(this, strMessage);
                }
            }

            return blResult;
        }

        /// <summary>
        /// To clear the popup details after save
        /// </summary>
        private void clearAllFormData()
        {
            this.TaskCreatedBy = 0;
            objucSubTasks_Admin.ClearSubTaskData();
            objucSubTasks_User.ClearSubTaskData();
            txtTaskTitle.Text = string.Empty;
            txtDescription.Text = string.Empty;
            ddlUserDesignation.ClearSelection();
            ddlUserDesignation.Texts.SelectBoxCaption = "Select";
            ddlAssignedUsers.Items.Clear();
            ddlAssignedUsers.Texts.SelectBoxCaption = "--Open--";
            cmbStatus.ClearSelection();
            ddlUserAcceptance.ClearSelection();
            ddlTaskPriority.SelectedValue = "0";
            txtDueDate.Text = string.Empty;
            txtHours.Text = string.Empty;
            hdnTaskId.Value = "0";
            controlMode.Value = "0";
        }

        private void InsertUpdateTask()
        {
            // save task master details
            SaveTask();

            //if (controlMode.Value == "0")
            //{
            //    // save task description as a first note.
            //    objucTaskHistory_Admin.SaveTaskNote(Convert.ToInt64(hdnTaskId.Value), true, null, string.Empty, txtDescription.Text);
            //}

            // save assgined designation.
            SaveTaskDesignations();

            // save details of users to whom task is assgined.
            SaveAssignedTaskUsers(ddlAssignedUsers, (JGConstant.TaskStatus)Convert.ToByte(cmbStatus.SelectedItem.Value));

            if (controlMode.Value == "0")
            {
                foreach (DataRow drTaskUserFiles in this.dtTaskUserFiles.Rows)
                {
                    UploadUserAttachements(null, Convert.ToInt64(hdnTaskId.Value), Convert.ToString(drTaskUserFiles["attachment"]), JGConstant.TaskFileDestination.Task);
                }

                objucSubTasks_Admin.SaveSubTasks(Convert.ToInt32(hdnTaskId.Value));
            }

            if (controlMode.Value == "0")
            {
                CommonFunction.ShowAlertFromUpdatePanel(this.Page, "Task created successfully!");
            }
            else
            {
                CommonFunction.ShowAlertFromUpdatePanel(this.Page, "Task updated successfully!");
            }
        }

        /// <summary>
        /// Save task master details, user information and user attachments.
        /// Created By: Yogesh Keraliya
        /// </summary>
        private void SaveTask()
        {
            SetPasswordToFreezeWorkSpecificationUI();

            int userId = Convert.ToInt16(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
            Task objTask = new Task();
            objTask.TaskId = Convert.ToInt32(hdnTaskId.Value);
            objTask.Title = Server.HtmlEncode(txtTaskTitle.Text);
            // objTask.Description = Server.HtmlEncode(txtDescription.Text);
            objTask.Description = objucTaskHistory_Admin.ucTaskDescription;
            objTask.Status = Convert.ToUInt16(cmbStatus.SelectedItem.Value);
            if (ddlTaskPriority.SelectedValue == "0")
            {
                objTask.TaskPriority = null;
            }
            else
            {
                objTask.TaskPriority = Convert.ToByte(ddlTaskPriority.SelectedItem.Value);
            }
            objTask.DueDate = txtDueDate.Text;
            objTask.Hours = txtHours.Text;
            objTask.CreatedBy = userId;
            objTask.Mode = Convert.ToInt32(controlMode.Value);
            objTask.InstallId = GetInstallIdFromDesignation(ddlUserDesignation.SelectedItem.Text);
            objTask.IsTechTask = chkTechTask.Checked;

            Int64 ItaskId = TaskGeneratorBLL.Instance.SaveOrDeleteTask(objTask);    // save task master details

            if (controlMode.Value == "0")
            {
                hdnTaskId.Value = ItaskId.ToString();
            }
        }

        private void SaveTaskDesignations()
        {
            //if task id is available to save its note and attachement.
            if (hdnTaskId.Value != "0")
            {
                String designations = GetSelectedDesignationsString();
                if (!string.IsNullOrEmpty(designations))
                {
                    int indexofComma = designations.IndexOf(',');
                    int copyTill = indexofComma > 0 ? indexofComma : designations.Length;

                    string designationcode = GetInstallIdFromDesignation(designations.Substring(0, copyTill));

                    TaskGeneratorBLL.Instance.SaveTaskDesignations(Convert.ToUInt64(hdnTaskId.Value), designations, designationcode);
                }
            }
        }

        /// <summary>
        /// Save user's to whom task is assigned. 
        /// </summary>
        private void SaveAssignedTaskUsers(DropDownCheckBoxes ddlAssigned, JGConstant.TaskStatus objTaskStatus)
        {
            //if task id is available to save its note and attachement.
            if (hdnTaskId.Value != "0")
            {
                string strUsersIds = string.Empty;

                foreach (ListItem item in ddlAssigned.Items)
                {
                    if (item.Selected)
                    {
                        strUsersIds = strUsersIds + (item.Value + ",");
                    }
                }

                // removes any extra comma "," from the end of the string.
                strUsersIds = strUsersIds.TrimEnd(',');

                // save (insert / delete) assigned users.
                bool isSuccessful = TaskGeneratorBLL.Instance.SaveTaskAssignedUsers(Convert.ToUInt64(hdnTaskId.Value), strUsersIds);

                // send email to selected users.
                if (strUsersIds.Length > 0)
                {
                    if (isSuccessful)
                    {
                        // Change task status to assigned = 3.
                        if (objTaskStatus == JGConstant.TaskStatus.Open || objTaskStatus == JGConstant.TaskStatus.Requested)
                        {
                            UpdateTaskStatus(Convert.ToInt32(hdnTaskId.Value), Convert.ToUInt16(JGConstant.TaskStatus.Assigned));
                        }

                        SendEmailToAssignedUsers(strUsersIds);
                    }
                }
                // send email to all users of the department as task is assigned to designation, but not to any specific user.
                //else
                //{
                //    string strUserIDs = "";

                //    foreach (ListItem item in ddlAssignedUsers.Items)
                //    {
                //        strUserIDs += string.Concat(item.Value, ",");
                //    }

                //    SendEmailToAssignedUsers(strUserIDs.TrimEnd(','));
                //}
            }
        }

        ///// <summary>
        ///// Save user's to whom task is assigned. 
        ///// </summary>
        //private void SaveAssignedTaskUsers()
        //{
        //    //if task id is available to save its note and attachement.
        //    if (hdnTaskId.Value != "0")
        //    {
        //        Boolean? isCreatorUser = null;

        //        foreach (ListItem item in ddlAssignedUsers.Items)
        //        {
        //            if (item.Selected)
        //            {
        //                // Save task notes and user information, returns TaskUpdateId for reference to add in user attachments.
        //                Int32 TaskUpdateId = SaveTaskNote(Convert.ToInt64(hdnTaskId.Value), isCreatorUser, Convert.ToInt32(item.Value), item.Text);
        //            }

        //        }


        //    }

        //}

        private void UploadUserAttachements(int? taskUpdateId, long? TaskId, string attachments, JG_Prospect.Common.JGConstant.TaskFileDestination objTaskFileDestination)
        {
            //User has attached file than save it to database.
            if (!String.IsNullOrEmpty(attachments))
            {
                TaskUser taskUserFiles = new TaskUser();

                if (!string.IsNullOrEmpty(attachments))
                {
                    String[] files = attachments.Split(new char[] { '^' }, StringSplitOptions.RemoveEmptyEntries);

                    foreach (String attachment in files)
                    {
                        String[] attachements = attachment.Split('@');

                        taskUserFiles.Attachment = attachements[0];
                        taskUserFiles.OriginalFileName = attachements[1];
                        taskUserFiles.Mode = 0; // insert data.
                        taskUserFiles.TaskId = TaskId ?? Convert.ToInt64(hdnTaskId.Value);
                        taskUserFiles.UserId = Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
                        taskUserFiles.TaskUpdateId = taskUpdateId;
                        taskUserFiles.UserType = JGSession.IsInstallUser ?? false;
                        taskUserFiles.TaskFileDestination = objTaskFileDestination;
                        TaskGeneratorBLL.Instance.SaveOrDeleteTaskUserFiles(taskUserFiles);  // save task files
                    }
                }
            }
        }

        private void SendEmailToAssignedUsers(string strInstallUserIDs)
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
                    strBody = strBody.Replace("#TaskLink#", string.Format("{0}?TaskId={1}", Request.Url.ToString().Split('?')[0], hdnTaskId.Value));

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

        private void LoadTaskData(Int64 intTaskId)
        {
            LoadTaskData(intTaskId.ToString());
        }

        private void LoadTaskData(string TaskId)
        {
            DataSet dsTaskDetails = TaskGeneratorBLL.Instance.GetTaskDetails(Convert.ToInt32(TaskId));

            DataTable dtTaskMasterDetails = dsTaskDetails.Tables[0];

            DataTable dtTaskDesignationDetails = dsTaskDetails.Tables[1];

            DataTable dtTaskAssignedUserDetails = dsTaskDetails.Tables[2];

            DataTable dtTaskNotesDetails = dsTaskDetails.Tables[3];

            DataTable dtSubTaskDetails = dsTaskDetails.Tables[4];

            SetSubTaskSectionView(true);

            SetMasterTaskDetails(dtTaskMasterDetails);
            SetTaskDesignationDetails(dtTaskDesignationDetails);
            bool blUserAssigned = SetTaskAssignedUsers(dtTaskAssignedUserDetails);
            objucTaskHistory_Admin.SetTaskUserNNotesDetails(dtTaskNotesDetails, dtTaskMasterDetails.Rows[0]["Description"].ToString());
            objucTaskHistory_User.SetTaskUserNNotesDetails(dtTaskNotesDetails, dtTaskMasterDetails.Rows[0]["Description"].ToString());
            objucSubTasks_Admin.SetSubTaskDetails();
            objucSubTasks_User.SetSubTaskDetails();

            SetTaskPopupTitle(TaskId, dtTaskMasterDetails);

            SetPasswordToFreezeWorkSpecificationUI(false);

            // show accept / reject task links for normal users, only if 
            // 1. task belogs to the same designation as user.
            // 2. task is not assigned to any user.
            if (!this.IsAdminMode)
            {
                bool blSameDesignation = ltlTUDesig.Text
                                                   .Split(',')
                                                   .FirstOrDefault
                                                    (
                                                        d => d.ToUpper() == HttpContext.Current.Session["DesigNew"].ToString().ToUpper()
                                                    ) != null;

                if (!blUserAssigned && blSameDesignation)
                {
                    DataSet dsTaskUserFiles = TaskGeneratorBLL.Instance.GetTaskAcceptances(Convert.ToInt64(hdnTaskId.Value));
                    if (dsTaskUserFiles != null)
                    {
                        DataView dv = dsTaskUserFiles.Tables[0].AsDataView();
                        dv.RowFilter = string.Format("UserId={0}", JGSession.UserId);
                        divAcceptRejectButtons.Visible = dv.ToTable().Rows.Count == 0;
                    }
                    else
                    {
                        divAcceptRejectButtons.Visible = true;
                    }
                }
                else
                {
                    divAcceptRejectButtons.Visible = false;
                }
            }
        }

        private void FillWorkSpecificationAttachments()
        {
            DataTable dtTaskUserFiles = null;

            if (controlMode.Value == "0")
            {
                dtTaskUserFiles = this.dtTaskUserFiles;
            }
            else
            {
                DataSet dsTaskUserFiles = TaskGeneratorBLL.Instance.GetTaskUserFiles(Convert.ToInt32(hdnTaskId.Value), JGConstant.TaskFileDestination.WorkSpecification, null, null);
                if (dsTaskUserFiles != null)
                {
                    dtTaskUserFiles = dsTaskUserFiles.Tables[0];
                    //Convert.ToInt32(dsTaskUserFiles.Tables[1].Rows[0]["TotalRecordCount"]);
                }
            }

            grdWorkSpecificationAttachments.DataSource = dtTaskUserFiles;
            grdWorkSpecificationAttachments.DataBind();

            upnlAttachments.Update();
        }

        private void ShowWorkSpecificationSection(bool IsOnPageLoad)
        {
            string strScript = string.Format(
                                                "Initialize_WorkSpecifications();ShowPopup(\"#{0}\");ShowPopup(\"#{1}\");",
                                                divWorkSpecificationSection.ClientID,
                                                divFinishedWorkFiles.ClientID
                                            );

            if (IsOnPageLoad)
            {
                strScript = "$(document).ready(function(){" + strScript + "});";
            }

            FillWorkSpecificationAttachments();

            upWorkSpecificationSection.Update();

            ScriptManager.RegisterStartupScript(
                                                    this.Page,
                                                    this.GetType(),
                                                    "ShowPopup",
                                                    strScript,
                                                    true
                                              );
        }

        private void SetSubTaskSectionView(bool blnView)
        {
            trSubTaskList.Visible = blnView;
        }

        private void SetTaskPopupTitle(String TaskId, DataTable dtTaskMasterDetails)
        {
            // If its admin then add delete button else not delete button for normal users.
            lbtnDeleteTask.Visible = this.IsAdminMode;
            ltrlInstallId.Text = dtTaskMasterDetails.Rows[0]["InstallId"].ToString();
            ltrlDateCreated.Text = CommonFunction.FormatDateTimeString(dtTaskMasterDetails.Rows[0]["CreatedOn"]);

            if (dtTaskMasterDetails.Rows[0]["AssigningManager"] != null && !String.IsNullOrEmpty(dtTaskMasterDetails.Rows[0]["AssigningManager"].ToString()))
            {
                ltrlAssigningManager.Text = string.Concat("Created By: ", dtTaskMasterDetails.Rows[0]["AssigningManager"].ToString());
            }

            tblTaskHeader.Visible = true;
        }

        private bool SetTaskAssignedUsers(DataTable dtTaskAssignedUserDetails)
        {
            string firstAssignedUser = string.Empty;
            foreach (DataRow row in dtTaskAssignedUserDetails.Rows)
            {

                ListItem item = ddlAssignedUsers.Items.FindByValue(row["UserId"].ToString());

                if (item != null)
                {
                    item.Selected = true;

                    if (string.IsNullOrEmpty(firstAssignedUser))
                    {
                        firstAssignedUser = item.Text;
                    }
                }
            }

            if (!string.IsNullOrEmpty(firstAssignedUser))
            {
                ddlAssignedUsers.Texts.SelectBoxCaption = firstAssignedUser;
                return true;
            }
            else
            {
                ddlAssignedUsers.Texts.SelectBoxCaption = "--Open--";
                return false;
            }
        }

        private void SetTaskDesignationDetails(DataTable dtTaskDesignationDetails)
        {
            String firstDesignation = string.Empty;
            if (this.IsAdminMode)
            {
                foreach (DataRow row in dtTaskDesignationDetails.Rows)
                {
                    ListItem item = ddlUserDesignation.Items.FindByText(row["Designation"].ToString());

                    if (item != null)
                    {
                        item.Selected = true;

                        if (string.IsNullOrEmpty(firstDesignation))
                        {
                            firstDesignation = item.Text;
                        }
                    }
                }

                ddlUserDesignation.Texts.SelectBoxCaption = firstDesignation;

                LoadUsersByDesgination();
            }
            else
            {
                StringBuilder designations = new StringBuilder(string.Empty);

                foreach (DataRow row in dtTaskDesignationDetails.Rows)
                {
                    designations.Append(String.Concat(row["Designation"].ToString(), ","));
                }

                ltlTUDesig.Text = string.IsNullOrEmpty(designations.ToString()) == true ? string.Empty : designations.ToString().Substring(0, designations.ToString().Length - 1);
            }
        }

        private void SetMasterTaskDetails(DataTable dtTaskMasterDetails)
        {
            this.TaskCreatedBy = Convert.ToInt32(dtTaskMasterDetails.Rows[0]["CreatedBy"]);
            chkTechTask.Checked = Convert.ToBoolean(dtTaskMasterDetails.Rows[0]["IsTechTask"]);
            if (this.IsAdminMode)
            {
                txtTaskTitle.Text = Server.HtmlDecode(dtTaskMasterDetails.Rows[0]["Title"].ToString());
                txtDescription.Text = Server.HtmlDecode(dtTaskMasterDetails.Rows[0]["Description"].ToString());

                //Get selected index of task status
                ListItem item = cmbStatus.Items.FindByValue(dtTaskMasterDetails.Rows[0]["Status"].ToString());

                if (item != null)
                {
                    item.Enabled = true;
                    cmbStatus.SelectedIndex = cmbStatus.Items.IndexOf(item);

                    // disable dropdown and do not allow user to change status
                    // status will be changed only after freezing the specifications.
                    //if (item.Value == Convert.ToByte(JGConstant.TaskStatus.SpecsInProgress).ToString())
                    //{
                    //    cmbStatus.Enabled = false;
                    //}
                    //else
                    //{
                    //    cmbStatus.Enabled = true;
                    //}
                }
                else
                {
                    cmbStatus.SelectedIndex = 0;
                }

                item = ddlTaskPriority.Items.FindByValue(dtTaskMasterDetails.Rows[0]["TaskPriority"].ToString());

                if (item != null)
                {
                    ddlTaskPriority.SelectedIndex = ddlTaskPriority.Items.IndexOf(item);
                }
                else
                {
                    ddlTaskPriority.SelectedIndex = 0;
                }

                txtDueDate.Text = CommonFunction.FormatToShortDateString(dtTaskMasterDetails.Rows[0]["DueDate"]);
                txtHours.Text = dtTaskMasterDetails.Rows[0]["Hours"].ToString();

                //hide user view table.
                tblUserTaskView.Visible = false;
            }
            else
            {
                //hide admin view table.
                tblAdminTaskView.Visible = false;
                toggleValidators(false);

                ltlTUTitle.Text = dtTaskMasterDetails.Rows[0]["Title"].ToString();
                txtTUDesc.Text = dtTaskMasterDetails.Rows[0]["Description"].ToString();

                //Get selected index of task status
                ListItem item = ddlTUStatus.Items.FindByValue(dtTaskMasterDetails.Rows[0]["Status"].ToString());

                if (item != null)
                {
                    item.Enabled = true;
                    ddlTUStatus.SelectedIndex = ddlTUStatus.Items.IndexOf(item);

                    // disable dropdown and do not allow user to change status
                    // status will be changed only after freezing the specifications.
                    //if (item.Value == Convert.ToByte(JGConstant.TaskStatus.SpecsInProgress).ToString())
                    //{
                    //    ddlTUStatus.Enabled = false;
                    //}
                    //else
                    //{
                    //    ddlTUStatus.Enabled = true;
                    //}
                }
                else
                {
                    ddlTUStatus.SelectedIndex = 0;
                }

                if (!string.IsNullOrEmpty(dtTaskMasterDetails.Rows[0]["TaskPriority"].ToString()))
                {
                    ltrlTaskPriority.Text = ((JGConstant.TaskPriority)Convert.ToByte(dtTaskMasterDetails.Rows[0]["TaskPriority"])).ToString();
                }
                ltlTUDueDate.Text = CommonFunction.FormatToShortDateString(dtTaskMasterDetails.Rows[0]["DueDate"]);
                ltlTUHrsTask.Text = dtTaskMasterDetails.Rows[0]["Hours"].ToString();
            }
            // ddlUserDesignation.SelectedValue = dtTaskMasterDetails.Rows[0]["Designation"].ToString();
            //LoadUsersByDesgination();
        }

        private void FillAcceptanceLog()
        {
            DataTable dtAcceptanceLog = null;

            if (controlMode.Value == "0")
            {
                dtAcceptanceLog = null;
            }
            else
            {
                DataSet dsTaskUserFiles = TaskGeneratorBLL.Instance.GetTaskAcceptances(Convert.ToInt64(hdnTaskId.Value));
                if (dsTaskUserFiles != null)
                {
                    dtAcceptanceLog = dsTaskUserFiles.Tables[0];
                }
            }

            gvAcceptanceLog.DataSource = dtAcceptanceLog;
            gvAcceptanceLog.DataBind();

            upAcceptanceLog.Update();
        }

        private void toggleValidators(bool flag)
        {
            rfvTaskTitle.Visible = flag;
            //rfvDesc.Visible = flag;
            cvDesignations.Visible = flag;
        }

        private void DownloadUserAttachments(String CommaSeperatedFiles)
        {
            string[] files = CommaSeperatedFiles.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);

            using (ZipFile zip = new ZipFile())
            {
                foreach (var file in files)
                {
                    string filePath = Server.MapPath("~/TaskAttachments/" + file);
                    zip.AddFile(filePath, "files");
                }

                Response.Clear();
                Response.AddHeader("Content-Disposition", "attachment; filename=DownloadedFile.zip");
                Response.ContentType = "application/zip";
                zip.Save(Response.OutputStream);

                Response.End();


            }
        }

        private void DownloadUserAttachment(String File, String OriginalFileName)
        {
            Response.Clear();
            Response.ContentType = "application/octet-stream";
            Response.AppendHeader("Content-Disposition", String.Concat("attachment; filename=", OriginalFileName));
            Response.WriteFile(Server.MapPath("~/TaskAttachments/" + File));
            Response.Flush();
            Response.End();
        }

        private void SetTaskView()
        {
            if (this.IsAdminMode)
            {
                tblAdminTaskView.Visible = true;
                tblUserTaskView.Visible = false;
            }
            else
            {
                tblAdminTaskView.Visible = false;
                tblUserTaskView.Visible = true;
            }
        }

        private void SetPasswordToFreezeWorkSpecificationUI(bool blResetStatus = true)
        {
            // show link to download working copy for preview for admin users only.
            //if (this.IsAdminAndItLeadMode)
            {
                txtITLeadPasswordToFreezeSpecificationMain.Visible =
                txtITLeadPasswordToFreezeSpecificationPopup.Visible =
                txtAdminPasswordToFreezeSpecificationMain.Visible =
                txtAdminPasswordToFreezeSpecificationPopup.Visible =
                txtUserPasswordToFreezeSpecificationMain.Visible =
                txtUserPasswordToFreezeSpecificationPopup.Visible = true;

                DataSet dsTaskSpecificationStatus = TaskGeneratorBLL.Instance.GetPendingTaskWorkSpecificationCount(Convert.ToInt32(hdnTaskId.Value));

                // change status only after freezing all specifications.
                // this will change disabled "specs in progress" status to open on feezing.
                if (
                    blResetStatus &&
                    Convert.ToInt32(dsTaskSpecificationStatus.Tables[0].Rows[0]["TotalRecordCount"]) > 0 &&
                    Convert.ToInt32(dsTaskSpecificationStatus.Tables[1].Rows[0]["PendingRecordCount"]) > 0
                   )
                {
                    SetStatusSelectedValue(cmbStatus, Convert.ToByte(JGConstant.TaskStatus.SpecsInProgress).ToString());
                }
                else
                {
                    //SetStatusSelectedValue(cmbStatus, Convert.ToByte(JGConstant.TaskStatus.Open).ToString());
                }

                if (HttpContext.Current.Session["DesigNew"].ToString().ToUpper().Equals("ITLEAD"))
                {
                    txtITLeadPasswordToFreezeSpecificationMain.AutoPostBack =
                    txtITLeadPasswordToFreezeSpecificationPopup.AutoPostBack =
                    txtUserPasswordToFreezeSpecificationMain.AutoPostBack =
                    txtUserPasswordToFreezeSpecificationPopup.AutoPostBack = false;
                }
                else if (HttpContext.Current.Session["DesigNew"].ToString().ToUpper().Equals("ITLEAD"))
                {
                    txtAdminPasswordToFreezeSpecificationMain.AutoPostBack =
                    txtAdminPasswordToFreezeSpecificationPopup.AutoPostBack =
                    txtUserPasswordToFreezeSpecificationMain.AutoPostBack =
                    txtUserPasswordToFreezeSpecificationPopup.AutoPostBack = false;
                }
                else
                {
                    txtAdminPasswordToFreezeSpecificationMain.AutoPostBack =
                    txtAdminPasswordToFreezeSpecificationPopup.AutoPostBack =
                    txtITLeadPasswordToFreezeSpecificationMain.AutoPostBack =
                    txtITLeadPasswordToFreezeSpecificationPopup.AutoPostBack = false;
                }

                if (dsTaskSpecificationStatus.Tables[2].Rows.Count > 0)
                {
                    string strLinkText = string.Empty;

                    #region Prepare Profile Links And Password

                    if (Convert.ToBoolean(dsTaskSpecificationStatus.Tables[2].Rows[0]["AdminStatus"].ToString()))
                    {
                        strLinkText += string.Format(
                                                    "<a href='CreatesalesUser.aspx?id={0}' target='_blank' style='margin-right:10px;'>{1} #{0} : {2}</a>",
                                                    dsTaskSpecificationStatus.Tables[2].Rows[0]["AdminUserId"].ToString(),
                                                    string.Concat
                                                            (
                                                                dsTaskSpecificationStatus.Tables[2].Rows[0]["AdminUserFirstName"].ToString(),
                                                                " ",
                                                                dsTaskSpecificationStatus.Tables[2].Rows[0]["AdminUserLastName"].ToString()
                                                            ),
                                                    Convert.ToDateTime(dsTaskSpecificationStatus.Tables[2].Rows[0]["AdminStatusUpdated"]).ToString("MM/dd/yyyy hh:mm tt")
                                                   );

                        txtAdminPasswordToFreezeSpecificationMain.Visible =
                        txtAdminPasswordToFreezeSpecificationPopup.Visible = false;
                    }

                    if (Convert.ToBoolean(dsTaskSpecificationStatus.Tables[2].Rows[0]["TechLeadStatus"].ToString()))
                    {
                        strLinkText += string.Format(
                                                       "<a href='CreatesalesUser.aspx?id={0}' target='_blank' style='margin-right:10px;'>{1} #{0} : {2}</a>",
                                                       dsTaskSpecificationStatus.Tables[2].Rows[0]["TechLeadUserId"].ToString(),
                                                       string.Concat
                                                               (
                                                                   dsTaskSpecificationStatus.Tables[2].Rows[0]["TechLeadUserFirstName"].ToString(),
                                                                   " ",
                                                                   dsTaskSpecificationStatus.Tables[2].Rows[0]["TechLeadUserLastName"].ToString()
                                                               ),
                                                        Convert.ToDateTime(dsTaskSpecificationStatus.Tables[2].Rows[0]["TechLeadStatusUpdated"]).ToString("MM/dd/yyyy hh:mm tt")
                                                    );

                        txtITLeadPasswordToFreezeSpecificationMain.Visible =
                        txtITLeadPasswordToFreezeSpecificationPopup.Visible = false;
                    }

                    if (Convert.ToBoolean(dsTaskSpecificationStatus.Tables[2].Rows[0]["OtherUserStatus"].ToString()))
                    {
                        strLinkText += string.Format(
                                                       "<a href='CreatesalesUser.aspx?id={0}' target='_blank' style='margin-right:10px;'>{1} #{0} : {2}</a>",
                                                       dsTaskSpecificationStatus.Tables[2].Rows[0]["OtherUserId"].ToString(),
                                                       string.Concat
                                                               (
                                                                   dsTaskSpecificationStatus.Tables[2].Rows[0]["OtherUserFirstName"].ToString(),
                                                                   " ",
                                                                   dsTaskSpecificationStatus.Tables[2].Rows[0]["OtherUserLastName"].ToString()
                                                               ),
                                                        Convert.ToDateTime(dsTaskSpecificationStatus.Tables[2].Rows[0]["OtherUserStatusUpdated"]).ToString("MM/dd/yyyy hh:mm tt")
                                                    );

                        txtUserPasswordToFreezeSpecificationMain.Visible =
                        txtUserPasswordToFreezeSpecificationPopup.Visible = false;
                    }

                    #endregion

                    if (this.IsAdminAndItLeadMode)
                    {
                        ltrlFreezedSpecificationByUserLinkMain.Text =
                        ltrlFreezedSpecificationByUserLinkPopup.Text = strLinkText;
                    }
                }
                else
                {
                    ltrlFreezedSpecificationByUserLinkMain.Text =
                    ltrlFreezedSpecificationByUserLinkPopup.Text = string.Empty;
                }
            }
        }

        private void SetStatusSelectedValue(DropDownList ddlStatus, string strValue)
        {
            ddlStatus.ClearSelection();

            ListItem objListItem = ddlStatus.Items.FindByValue(strValue);
            if (objListItem != null)
            {
                if (objListItem.Value == Convert.ToByte(JGConstant.TaskStatus.SpecsInProgress).ToString())
                {
                    //ddlStatus.Enabled = false;
                }
                else
                {
                    ddlStatus.Enabled = true;
                }
                objListItem.Enabled = true;
                objListItem.Selected = true;
            }
        }

        #endregion
    }
}