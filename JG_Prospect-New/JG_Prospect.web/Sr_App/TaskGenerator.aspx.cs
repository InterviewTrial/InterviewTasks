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

#endregion

namespace JG_Prospect.Sr_App
{
    public partial class TaskGenerator : System.Web.UI.Page
    {
        #region "--Properties--"

        int intTaskUserFilesCount = 0;

        string strSubtaskSeq = "sbtaskseq";

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

        public String LastSubTaskSequence
        {
            get
            {
                String val = string.Empty;

                if (ViewState[strSubtaskSeq] != null && !string.IsNullOrEmpty(ViewState[strSubtaskSeq].ToString()))
                {
                    val = ViewState[strSubtaskSeq].ToString();
                }
                return val;
            }
            set
            {
                ViewState[strSubtaskSeq] = value;
            }
        }

        private List<Task> lstSubTasks
        {
            get
            {
                if (ViewState["lstSubTasks"] == null)
                {
                    ViewState["lstSubTasks"] = new List<Task>();
                }
                return (List<Task>)ViewState["lstSubTasks"];
            }
            set
            {
                ViewState["lstSubTasks"] = value;
            }
        }

        private DataTable dtTaskUserFiles
        {
            get
            {
                if (ViewState["dtTaskUserFiles"] != null)
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

        #region "--Page methods--"

        protected void Page_Load(object sender, EventArgs e)
        {
            ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
            scriptManager.RegisterPostBackControl(this.gdTaskUsers);

                if (!IsPostBack)
            {
                this.IsAdminMode = CommonFunction.CheckAdminMode();

                clearAllFormData();

                SetTaskView();

                LoadPopupDropdown();

                cmbStatus.DataSource = CommonFunction.GetTaskStatusList();
                cmbStatus.DataTextField = "Text";
                cmbStatus.DataValueField = "Value";
                cmbStatus.DataBind();

                ddlSubTaskStatus.DataSource = CommonFunction.GetTaskStatusList();
                ddlSubTaskStatus.DataTextField = "Text";
                ddlSubTaskStatus.DataValueField = "Value";
                ddlSubTaskStatus.DataBind();

                ddlTUStatus.DataSource = CommonFunction.GetTaskStatusList();
                ddlTUStatus.DataTextField = "Text";
                ddlTUStatus.DataValueField = "Value";
                ddlTUStatus.DataBind();

                this.LastSubTaskSequence = string.Empty;

                // edit mode, if task id is provided in query string parameter.
                if (!string.IsNullOrEmpty(Request.QueryString["TaskId"]))
                {
                    controlMode.Value = "1";
                    hdnTaskId.Value = Request.QueryString["TaskId"].ToString();
                    LoadTaskData(hdnTaskId.Value);
                }
                else
                {
                    controlMode.Value = "0";
                }
            }
        }

        #endregion

        #region "--Control Events--"

        protected void ddlUserDesignation_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadUsersByDesgination();

            ddcbAssigned_SelectedIndexChanged(sender, e);

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

        protected void ddcbAssigned_SelectedIndexChanged(object sender, EventArgs e)
        {
            #region 'Commented as Not needed'
            /*
            if (controlMode.Value == "0")
            {
                DataSet dsUsers = new DataSet();
                DataSet tempDs;
                List<string> SelectedUsersID = new List<string>();
                List<string> SelectedUsers = new List<string>();
                foreach (System.Web.UI.WebControls.ListItem item in ddcbAssigned.Items)
                {
                    if (item.Selected)
                    {
                        SelectedUsersID.Add(item.Value);
                        SelectedUsers.Add(item.Text);
                        tempDs = TaskGeneratorBLL.Instance.GetInstallUserDetails(Convert.ToInt32(item.Value));
                        dsUsers.Merge(tempDs);
                    }
                }
                if (dsUsers.Tables.Count != 0)
                {
                    gdTaskUsers.DataSource = dsUsers;
                    gdTaskUsers.DataBind();
                }
                else
                {
                    gdTaskUsers.DataSource = null;
                    gdTaskUsers.DataBind();
                }
            } 
            */
            #endregion

            ddcbAssigned.Texts.SelectBoxCaption = "--Open--";

            foreach (ListItem item in ddcbAssigned.Items)
            {
                if (item.Selected)
                {
                    ddcbAssigned.Texts.SelectBoxCaption = item.Text;
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

                //if (e.Item.ItemIndex == intTaskUserFilesCount - 1)
                //{
                //    e.Item.FindControl("ltrlSeprator").Visible = false;
                //}
            }
        }

        #region '--Sub Tasks--'

        #region '--gvSubTasks--'

        protected void gvSubTasks_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                DropDownList ddlStatus = e.Row.FindControl("ddlStatus") as DropDownList;
                ddlStatus.DataSource = CommonFunction.GetTaskStatusList();
                ddlStatus.DataTextField = "Text";
                ddlStatus.DataValueField = "Value";
                ddlStatus.DataBind();

                if (!string.IsNullOrEmpty(DataBinder.Eval(e.Row.DataItem, "Status").ToString()))
                {
                    ddlStatus.SelectedValue = DataBinder.Eval(e.Row.DataItem, "Status").ToString();
                }

                if (!this.IsAdminMode)
                {
                    if (!ddlStatus.SelectedValue.Equals(Convert.ToByte(TaskStatus.ReOpened).ToString()))
                    {
                        ddlStatus.Items.FindByValue(Convert.ToByte(TaskStatus.ReOpened).ToString()).Enabled = false;
                    }
                }

                if (controlMode.Value == "0")
                {
                    ddlStatus.Attributes.Add("SubTaskIndex", e.Row.RowIndex.ToString());
                }
                else
                {
                    ddlStatus.Attributes.Add("TaskId", DataBinder.Eval(e.Row.DataItem, "TaskId").ToString());
                }

                if (!string.IsNullOrEmpty(DataBinder.Eval(e.Row.DataItem, "attachment").ToString()))
                {
                    string attachments = DataBinder.Eval(e.Row.DataItem, "attachment").ToString();
                    string[] attachment = attachments.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);

                    intTaskUserFilesCount = attachment.Length;

                    Repeater rptAttachments = (Repeater)e.Row.FindControl("rptAttachment");
                    rptAttachments.DataSource = attachment;
                    rptAttachments.DataBind();
                }
            }
        }

        protected void gvSubTasks_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName.Equals("edit-sub-task"))
            {
                ClearSubTaskData();

                hdnSubTaskId.Value = "0";
                hdnSubTaskIndex.Value = "-1";

                if (controlMode.Value == "0")
                {
                    hdnSubTaskIndex.Value = e.CommandArgument.ToString();

                    Task objTask = this.lstSubTasks[Convert.ToInt32(hdnSubTaskIndex.Value)];

                    txtTaskListID.Text = objTask.InstallId.ToString();
                    txtSubTaskTitle.Text = Server.HtmlDecode(objTask.Title);
                    txtSubTaskDescription.Text = Server.HtmlDecode(objTask.Description);

                    if (objTask.TaskType.HasValue && ddlTaskType.Items.FindByValue(objTask.TaskType.Value.ToString()) != null)
                    {
                        ddlTaskType.SelectedValue = objTask.TaskType.Value.ToString();
                    }

                    txtSubTaskDueDate.Text = CommonFunction.FormatToShortDateString(objTask.DueDate);
                    txtSubTaskHours.Text = objTask.Hours;
                    ddlSubTaskStatus.SelectedValue = objTask.Status.ToString();
                }
                else
                {
                    hdnSubTaskId.Value = gvSubTasks.DataKeys[Convert.ToInt32(e.CommandArgument)]["TaskId"].ToString();

                    DataSet dsTaskDetails = TaskGeneratorBLL.Instance.GetTaskDetails(Convert.ToInt32(hdnSubTaskId.Value));

                    DataTable dtTaskMasterDetails = dsTaskDetails.Tables[0];

                    txtTaskListID.Text = dtTaskMasterDetails.Rows[0]["InstallId"].ToString();
                    txtSubTaskTitle.Text = Server.HtmlDecode(dtTaskMasterDetails.Rows[0]["Title"].ToString());
                    txtSubTaskDescription.Text = Server.HtmlDecode(dtTaskMasterDetails.Rows[0]["Description"].ToString());

                    ListItem item = ddlTaskType.Items.FindByValue(dtTaskMasterDetails.Rows[0]["TaskType"].ToString());

                    if (item != null)
                    {
                        ddlTaskType.SelectedIndex = ddlTaskType.Items.IndexOf(item);
                    }

                    txtSubTaskDueDate.Text = CommonFunction.FormatToShortDateString(dtTaskMasterDetails.Rows[0]["DueDate"]);
                    txtSubTaskHours.Text = dtTaskMasterDetails.Rows[0]["Hours"].ToString();
                    ddlSubTaskStatus.SelectedValue = dtTaskMasterDetails.Rows[0]["Status"].ToString();
                    if (!this.IsAdminMode)
                    {
                        if (!ddlSubTaskStatus.SelectedValue.Equals(Convert.ToByte(TaskStatus.ReOpened).ToString()))
                        {
                            ddlSubTaskStatus.Items.FindByValue(Convert.ToByte(TaskStatus.ReOpened).ToString()).Enabled = false;
                        }
                    }
                    trSubTaskStatus.Visible = true;
                }

                upAddSubTask.Update();

                ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(), "slid down sub task", "$('#" + divSubTask.ClientID + "').slideDown('slow');", true);
            }
        }

        protected void gvSubTasks_ddlStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
            DropDownList ddlStatus = sender as DropDownList;
            if (controlMode.Value == "0")
            {
                this.lstSubTasks[Convert.ToInt32(ddlStatus.Attributes["SubTaskIndex"].ToString())].Status = Convert.ToInt32(ddlStatus.SelectedValue);

                SetSubTaskDetails(this.lstSubTasks);
            }
            else
            {
                TaskGeneratorBLL.Instance.UpdateTaskStatus
                                            (
                                                new Task()
                                                {
                                                    TaskId = Convert.ToInt32(ddlStatus.Attributes["TaskId"].ToString()),
                                                    Status = Convert.ToInt32(ddlStatus.SelectedValue)
                                                }
                                            );

                SetSubTaskDetails(TaskGeneratorBLL.Instance.GetSubTasks(Convert.ToInt32(hdnTaskId.Value)).Tables[0]);
            }
        }

        #endregion

        protected void lbtnAddNewSubTask_Click(object sender, EventArgs e)
        {
            ClearSubTaskData();
            string[] subtaskListIDSuggestion = CommonFunction.getSubtaskSequencing(this.LastSubTaskSequence);
            if (subtaskListIDSuggestion.Length > 0)
            {
                if (subtaskListIDSuggestion.Length > 1)
                {
                    if (String.IsNullOrEmpty(subtaskListIDSuggestion[1]))
                    {
                        txtTaskListID.Text = subtaskListIDSuggestion[0];

                    }
                    else
                    {
                        txtTaskListID.Text = subtaskListIDSuggestion[1];
                        listIDOpt.Text = subtaskListIDSuggestion[0];

                    }

                }
                else
                {
                    txtTaskListID.Text = subtaskListIDSuggestion[0];
                    //listIDOpt.Text = subtaskListIDSuggestion[0];
                }
            }
            ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(), "slid down sub task", "$('#" + divSubTask.ClientID + "').slideDown('slow');", true);
        }

        protected void ddlTaskType_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (ddlTaskType.SelectedValue == Convert.ToInt16(TaskType.Enhancement).ToString())
            {
                trDateHours.Visible = true;
            }
            else
            {
                trDateHours.Visible = false;
            }
            ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(), "slid down sub task", "$('#" + divSubTask.ClientID + "').slideDown('slow');", true);
        }

        protected void btnSaveSubTask_Click(object sender, EventArgs e)
        {
            SaveSubTask();
            ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(), "slid up sub task", "$('#" + divSubTask.ClientID + "').slideUp('slow');", true);
        }

        #endregion

        protected void btnSaveTask_Click(object sender, EventArgs e)
        {
            //Save task master details
            SaveTask();

            // Save assgined designation.
            SaveTaskDesignations();

            //Save details of users to whom task is assgined.
            SaveAssignedTaskUsers(ddcbAssigned, (TaskStatus)Convert.ToByte(cmbStatus.SelectedItem.Value));

            if (controlMode.Value == "0")
            {
                foreach (DataRow drTaskUserFiles in this.dtTaskUserFiles.Rows)
                {
                    UploadUserAttachements(null, Convert.ToInt64(hdnTaskId.Value), Convert.ToString(drTaskUserFiles["attachment"]));
                }
            }

            if (this.lstSubTasks.Any())
            {
                foreach (Task objSubTask in this.lstSubTasks)
                {
                    objSubTask.ParentTaskId = Convert.ToInt32(hdnTaskId.Value);
                    // save task master details to database.
                    hdnSubTaskId.Value = TaskGeneratorBLL.Instance.SaveOrDeleteTask(objSubTask).ToString();

                    UploadUserAttachements(null, Convert.ToInt64(hdnSubTaskId.Value), objSubTask.Attachment);
                }
            }

            if (controlMode.Value == "0")
            {
                ScriptManager.RegisterStartupScript(this.Page, GetType(), "closepopup", "CloseTaskPopup();", true);
            }
            else
            {
                CommonFunction.ShowAlertFromUpdatePanel(this.Page, "Task updated successfully!");
            }

            SearchTasks(null);
        }

        protected void lbtnDeleteTask_Click(object sender, EventArgs e)
        {
            DeletaTask(hdnTaskId.Value);
            ScriptManager.RegisterStartupScript((sender as Control), this.GetType(), "HidePopup", "CloseTaskPopup();", true);
        }

        #region '--Task History--'

        protected void btnAddNote_Click(object sender, EventArgs e)
        {
            SaveTaskNotesNAttachments();
            hdnAttachments.Value = "";
        }

        protected void gdTaskUsers_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                if (String.IsNullOrEmpty(DataBinder.Eval(e.Row.DataItem, "attachments").ToString()))
                {
                    LinkButton lbtnAttachment = (LinkButton)e.Row.FindControl("lbtnAttachment");
                    lbtnAttachment.Visible = false;
                }

                Label lblStatus = (Label)e.Row.FindControl("lblStatus");

                int TaskStatus = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "Status"));
                lblStatus.Text = CommonFunction.GetTaskStatusList().FindByValue(TaskStatus.ToString()).Text;
            }
        }

        protected void gdTaskUsers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "DownLoadFiles")
            {
                // Allow download only if files are attached.
                if (!String.IsNullOrEmpty(e.CommandArgument.ToString()))
                {
                    DownloadUserAttachments(e.CommandArgument.ToString());
                }
            }

        }

        #endregion

        #region '--Work Specification - Popup--'

        protected void btnAddAttachment_ClicK(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(hdnWorkFiles.Value))
            {
                if (controlMode.Value == "0")
                {
                    #region '-- Save And Refresh Viewstate --'

                    foreach (string strAttachment in hdnWorkFiles.Value.Split('^'))
                    {
                        DataRow drTaskUserFiles = dtTaskUserFiles.NewRow();
                        drTaskUserFiles["attachment"] = strAttachment;
                        drTaskUserFiles["FirstName"] = Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.Username.ToString()]);
                        dtTaskUserFiles.Rows.Add(drTaskUserFiles);
                    }

                    FillrptWorkFiles(dtTaskUserFiles);

                    #endregion
                }
                else
                {
                    #region '-- Save And Refresh Database --'

                    UploadUserAttachements(null, Convert.ToInt32(hdnTaskId.Value), hdnWorkFiles.Value);

                    DataSet dsTaskUserFiles = TaskGeneratorBLL.Instance.GetTaskUserFiles(Convert.ToInt32(hdnTaskId.Value));

                    FillrptWorkFiles(dsTaskUserFiles.Tables[0]);

                    #endregion
                }

                hdnWorkFiles.Value = "";
                upFinishedWorkFiles.Update();
            }
        }

        protected void lbtnWorkSpecificationFiles_Click(object sender, EventArgs e)
        {
            string strLastCheckedInBy = "";
            string strLastVersionUpdateBy = "";

            DataSet dsLatestTaskWorkSpecification = TaskGeneratorBLL.Instance.GetLatestTaskWorkSpecification
                                                                                (
                                                                                    Convert.ToInt32(hdnTaskId.Value),
                                                                                    true
                                                                                );

            trFreezeWorkSpecification.Visible =
            trSaveWorkSpecification.Visible =
            lbtnDownloadWorkSpecificationFilePreview.Visible =
            lbtnDownloadWorkSpecificationFile.Visible = false;

            if (
                dsLatestTaskWorkSpecification != null &&
                dsLatestTaskWorkSpecification.Tables.Count == 2
               )
            {
                // main / last freezed copy.
                if (dsLatestTaskWorkSpecification.Tables[0].Rows.Count > 0)
                {
                    if (!string.IsNullOrEmpty(Convert.ToString(dsLatestTaskWorkSpecification.Tables[0].Rows[0]["LastUsername"])))
                    {
                        strLastCheckedInBy = dsLatestTaskWorkSpecification.Tables[0].Rows[0]["LastUsername"].ToString();

                        ltrlLastCheckedInBy.Text = string.Format(
                                                                "Last freeze by \'{0}\'.&nbsp;",
                                                                strLastCheckedInBy
                                                                );
                        // show link to download freezed copy.
                        lbtnDownloadWorkSpecificationFile.Visible = true;
                    }
                }

                // current / working copy.
                if (dsLatestTaskWorkSpecification.Tables[1].Rows.Count > 0)
                {
                    hdnWorkSpecificationId.Value = Convert.ToString(dsLatestTaskWorkSpecification.Tables[1].Rows[0]["Id"]);

                    txtWorkSpecification.Text = Convert.ToString(dsLatestTaskWorkSpecification.Tables[1].Rows[0]["Content"]);

                    if (!string.IsNullOrEmpty(Convert.ToString(dsLatestTaskWorkSpecification.Tables[1].Rows[0]["CurrentUsername"])))
                    {
                        strLastVersionUpdateBy = dsLatestTaskWorkSpecification.Tables[1].Rows[0]["CurrentUsername"].ToString();
                        //ltrlLastVersionUpdateBy.Text = string.Format(
                        //                                            "Last version updated by \'{0}\'",
                        //                                            strLastVersionUpdateBy
                        //                                            );
                    }
                }
            }
            else
            {
                hdnWorkSpecificationId.Value = "0";
            }


            // show link to download working copy for preview for admin users only.
            if (this.IsAdminMode)
            {
                trFreezeWorkSpecification.Visible =
                trSaveWorkSpecification.Visible =
                lbtnDownloadWorkSpecificationFilePreview.Visible = true;
            }

            upWorkSpecificationFiles.Update();
            ScriptManager.RegisterStartupScript(
                                                    (sender as Control),
                                                    this.GetType(),
                                                    "ShowPopup",
                                                    string.Format(
                                                                    "ShowPopupWithTitle(\"#{0}\", \"{1}\");",
                                                                    divWorkSpecifications.ClientID,
                                                                    GetWorkSpecificationFilePopupTitle(strLastCheckedInBy, strLastVersionUpdateBy)
                                                                ),
                                                    true
                                              );
        }


        protected void btnSaveWorkSpecification_Click(object sender, EventArgs e)
        {
            ScriptManager.RegisterStartupScript(
                                                      (sender as Control),
                                                      this.GetType(),
                                                      "ShowPopupForPasswordAuthentication",
                                                      string.Format(
                                                                      "ShowPopupForPasswordAuthentication(\"#{0}\", \"{1}\");",
                                                                      divFreez.ClientID,
                                                                      ""
                                                                  ),
                                                      true
                                                );
            //old code
            //TaskWorkSpecification objTaskWorkSpecification = new TaskWorkSpecification();
            //objTaskWorkSpecification.Id = Convert.ToInt32(hdnWorkSpecificationId.Value);
            //objTaskWorkSpecification.TaskId = Convert.ToInt64(hdnTaskId.Value);

            //TaskWorkSpecificationVersions objTaskWorkSpecificationVersions = new TaskWorkSpecificationVersions();
            //objTaskWorkSpecificationVersions.TaskWorkSpecificationId = objTaskWorkSpecification.Id;
            //objTaskWorkSpecificationVersions.UserId = Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
            //objTaskWorkSpecificationVersions.Content = txtWorkSpecification.Text;
            //objTaskWorkSpecificationVersions.IsInstallUser = JGSession.IsInstallUser.Value;
            //objTaskWorkSpecificationVersions.Status = chkFreeze.Checked;

            //objTaskWorkSpecification.TaskWorkSpecificationVersions.Add(objTaskWorkSpecificationVersions);

            //if (objTaskWorkSpecification.Id == 0)
            //{
            //    TaskGeneratorBLL.Instance.InsertTaskWorkSpecification(objTaskWorkSpecification);
            //}
            //else
            //{
            //    TaskGeneratorBLL.Instance.UpdateTaskWorkSpecification(objTaskWorkSpecification);
            //}
            //ScriptManager.RegisterStartupScript((sender as Control), this.GetType(), "HidePopup", string.Format("HidePopup('#{0}');", divWorkSpecifications.ClientID), true);
        }

        private void SendEmailToManagerNUsers(string strUserIDs)
        {
            try
            {
                string strHTMLTemplateName = "Work Speciication Auto Email";
                DataSet dsEmailTemplate = AdminBLL.Instance.GetEmailTemplate(strHTMLTemplateName, 108);
                foreach (string userID in strUserIDs.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
                {
                    DataSet dsUser = TaskGeneratorBLL.Instance.GetTaskUserFiles(Convert.ToInt32(userID));

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

        protected void lbtnDownloadWorkSpecificationFilePreview_Click(object sender, EventArgs e)
        {
            DownloadPdf(
                        CommonFunction.ConvertHtmlToPdf(txtWorkSpecification.Text),
                        string.Format("Task-Preview-{0} {1}.pdf", ltrlInstallId.Text, DateTime.Now.ToString("dd-MM-yyyy hh-mm-ss-tt"))
                       );
        }

        protected void lbtnDownloadWorkSpecificationFile_Click(object sender, EventArgs e)
        {
            DataSet dsLatestTaskWorkSpecification = TaskGeneratorBLL.Instance.GetLatestTaskWorkSpecification
                                                                                (
                                                                                    Convert.ToInt32(hdnTaskId.Value),
                                                                                    true
                                                                                );
            if (
                dsLatestTaskWorkSpecification != null &&
                dsLatestTaskWorkSpecification.Tables.Count == 2 &&
                dsLatestTaskWorkSpecification.Tables[0].Rows.Count > 0
               )
            {
                // main / last freezed copy.
                if (!string.IsNullOrEmpty(Convert.ToString(dsLatestTaskWorkSpecification.Tables[0].Rows[0]["Content"])))
                {
                    DownloadPdf(
                                    CommonFunction.ConvertHtmlToPdf(dsLatestTaskWorkSpecification.Tables[0].Rows[0]["Content"].ToString()),
                                    string.Format("Task-{0} {1}.pdf", ltrlInstallId.Text, DateTime.Now.ToString("dd-MM-yyyy hh-mm-ss-tt"))
                                );
                }
            }
        }
        protected void btnSetApproval_Click(object sender, EventArgs e)
        {
            try
            {
                if (!string.IsNullOrEmpty(txtAuthenticateUser.Text.Trim()))
                {
                    //check accesibility with KERConsultancy and jmgrove 
                    string jmPass = string.Empty;
                    string KerPass = string.Empty;
                    jmPass = TaskGeneratorBLL.Instance.GetAdminUserPass("jgrove@jmgroveconstruction.com").Tables[0].Rows[0][0].ToString();
                    KerPass = TaskGeneratorBLL.Instance.GetInstallUserDetailByLogin("kerconsultancy@hotmail.com").Tables[0].Rows[0][0].ToString();
                    if (txtAuthenticateUser.Text.Trim() == KerPass || txtAuthenticateUser.Text.Trim() == jmPass)
                    {
                        TaskWorkSpecification objTaskWorkSpecification = new TaskWorkSpecification();
                        objTaskWorkSpecification.Id = Convert.ToInt32(hdnWorkSpecificationId.Value);
                        objTaskWorkSpecification.TaskId = Convert.ToInt64(hdnTaskId.Value);

                        TaskWorkSpecificationVersions objTaskWorkSpecificationVersions = new TaskWorkSpecificationVersions();
                        objTaskWorkSpecificationVersions.TaskWorkSpecificationId = objTaskWorkSpecification.Id;
                        objTaskWorkSpecificationVersions.UserId = Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
                        objTaskWorkSpecificationVersions.Content = txtWorkSpecification.Text;
                        objTaskWorkSpecificationVersions.IsInstallUser = JGSession.IsInstallUser.Value;
                        objTaskWorkSpecificationVersions.Status = chkFreeze.Checked;

                        objTaskWorkSpecification.TaskWorkSpecificationVersions.Add(objTaskWorkSpecificationVersions);

                        if (objTaskWorkSpecification.Id == 0)
                        {
                            TaskGeneratorBLL.Instance.InsertTaskWorkSpecification(objTaskWorkSpecification);
                        }
                        else
                        {
                            TaskGeneratorBLL.Instance.UpdateTaskWorkSpecification(objTaskWorkSpecification);
                        }
                        //Send Notification to concern user and manager
                        string stremail = "jgrove@jmgroveconstruction.com" + "," + "ratn8177@gmail.com";
                        SendEmailToManagerNUsers(stremail);
                        ScriptManager.RegisterStartupScript((sender as Control), this.GetType(), "HidePopup1", string.Format("HidePopup1('#{0}');", divFreez.ClientID), true);
                        ScriptManager.RegisterStartupScript((sender as Control), this.GetType(), "HidePopup", string.Format("HidePopup('#{0}');", divWorkSpecifications.ClientID), true);
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this.Page, GetType(), "al", "alert('UnAthorised Password');", true);

                    }

                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("{0} Exception caught.", ex);
            }

        }
        protected void rptWorkFiles_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DownloadFile")
            {
                string[] files = e.CommandArgument.ToString().Split(new char[] { '@' }, StringSplitOptions.RemoveEmptyEntries);

                DownloadUserAttachment(files[0].Trim(), files[1].Trim());
            }
        }

        protected void rptWorkFiles_ItemDataBound(object sender, RepeaterItemEventArgs e)
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
            }
        }

        #endregion

        #region '--Finished Work - Popup--'

        protected void lbtnFinishedWorkFiles_Click(object sender, EventArgs e)
        {
            upFinishedWorkFiles.Update();
            ScriptManager.RegisterStartupScript((sender as Control), this.GetType(), "ShowPopup", string.Format("ShowPopup('#{0}');", divFinishedWorkFiles.ClientID), true);
        }

        #endregion

        #endregion

        #region "--Private Methods--"

        private void SearchTasks(object o) { }

        private string getSingleValueFromCommaSeperatedString(string commaSeperatedString)
        {
            String strReturnVal;

            if (commaSeperatedString.Contains(","))
            {
                strReturnVal = String.Concat(commaSeperatedString.Substring(0, commaSeperatedString.IndexOf(",")), "..");
            }
            else
            {
                strReturnVal = commaSeperatedString;
            }

            return strReturnVal;
        }

        /// <summary>
        /// To load Designation to popup dropdown
        /// </summary>
        private void LoadPopupDropdown()
        {
            BindTaskTypeDropDown();
            //DataSet dsdesign = TaskGeneratorBLL.Instance.GetInstallUsers(1, "");
            //DataSet ds = TaskGeneratorBLL.Instance.GetTaskUserDetails(1);
            //ddlUserDesignation.DataSource = dsdesign;
            //ddlUserDesignation.DataTextField = "Designation";
            //ddlUserDesignation.DataValueField = "Designation";
            //ddlUserDesignation.DataBind();
        }

        private void BindTaskTypeDropDown()
        {
            ddlTaskType.DataSource = CommonFunction.GetTaskTypeList();

            ddlTaskType.DataTextField = "Text";
            ddlTaskType.DataValueField = "Value";
            ddlTaskType.DataBind();
        }

        private void DeletaTask(string TaskId)
        {
            TaskGeneratorBLL.Instance.DeleteTask(Convert.ToUInt64(TaskId));
            hdnTaskId.Value = string.Empty;
            SearchTasks(null);
        }

        private void doSearch(object sender, EventArgs e)
        {

        }

        private void UpdateTaskStatus(Int32 taskId, UInt16 Status)
        {
            Task task = new Task();
            task.TaskId = taskId;
            task.Status = Status;

            int result = TaskGeneratorBLL.Instance.UpdateTaskStatus(task);    // save task master details

            SearchTasks(null);

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

            // DropDownCheckBoxes ddlAssign = (FindControl("ddcbAssigned") as DropDownCheckBoxes);
            // DropDownList ddlDesignation = (DropDownList)sender;

            string designations = GetSelectedDesignationsString();

            dsUsers = TaskGeneratorBLL.Instance.GetInstallUsers(2, designations);

            ddcbAssigned.Items.Clear();
            ddcbAssigned.DataSource = dsUsers;
            ddcbAssigned.DataTextField = "FristName";
            ddcbAssigned.DataValueField = "Id";
            ddcbAssigned.DataBind();

            HighlightInterviewUsers(dsUsers.Tables[0], ddcbAssigned, null);
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

        /// <summary>
        /// To clear the popup details after save
        /// </summary>
        private void clearAllFormData()
        {
            this.TaskCreatedBy = 0;
            this.lstSubTasks = null;
            txtTaskTitle.Text = string.Empty;
            txtDescription.Text = string.Empty;
            ddlUserDesignation.ClearSelection();
            ddlUserDesignation.Texts.SelectBoxCaption = "Select";
            ddcbAssigned.Items.Clear();
            ddcbAssigned.Texts.SelectBoxCaption = "--Open--";
            cmbStatus.ClearSelection();
            ddlUserAcceptance.ClearSelection();
            txtDueDate.Text = string.Empty;
            txtHours.Text = string.Empty;
            gdTaskUsers.DataSource = null;
            gdTaskUsers.DataBind();
            txtNote.Text = string.Empty;
            hdnTaskId.Value = "0";
            controlMode.Value = "0";
        }

        private void ClearSubTaskData()
        {
            hdnSubTaskId.Value = "0";
            hdnSubTaskIndex.Value = "-1";
            txtTaskListID.Text = string.Empty;
            txtSubTaskTitle.Text =
            txtSubTaskDescription.Text =
            txtSubTaskDueDate.Text =
            txtSubTaskHours.Text = string.Empty;
            if (ddlTaskType.Items.Count > 0)
            {
                ddlTaskType.SelectedIndex = 0;
            }
            trSubTaskStatus.Visible = false;
            ddlSubTaskStatus.Items.FindByValue(Convert.ToByte(TaskStatus.Open).ToString()).Selected = true;
            ddlSubTaskStatus.Items.FindByValue(Convert.ToByte(TaskStatus.ReOpened).ToString()).Enabled = true;
            upAddSubTask.Update();
        }

        /// <summary>
        /// Save task master details, user information and user attachments.
        /// Created By: Yogesh Keraliya
        /// </summary>
        private void SaveTask()
        {
            int userId = Convert.ToInt16(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
            Task task = new Task();
            task.TaskId = Convert.ToInt32(hdnTaskId.Value);
            task.Title = Server.HtmlEncode(txtTaskTitle.Text);
            task.Description = Server.HtmlEncode(txtDescription.Text);
            task.Status = Convert.ToUInt16(cmbStatus.SelectedItem.Value);
            task.DueDate = txtDueDate.Text;
            task.Hours = txtHours.Text;
            task.CreatedBy = userId;
            task.Mode = Convert.ToInt32(controlMode.Value);
            task.InstallId = GetInstallIdFromDesignation(ddlUserDesignation.SelectedItem.Text);

            task.IsTechTask = chkTechTask.Checked;

            Int64 ItaskId = TaskGeneratorBLL.Instance.SaveOrDeleteTask(task);    // save task master details

            if (controlMode.Value == "0")
            {
                hdnTaskId.Value = ItaskId.ToString();
            }
        }

        private void SaveSubTask()
        {
            Task objTask = null;
            if (hdnSubTaskIndex.Value == "-1")
            {
                objTask = new Task();
                objTask.TaskId = Convert.ToInt32(hdnSubTaskId.Value);
            }
            else
            {
                objTask = this.lstSubTasks[Convert.ToInt32(hdnSubTaskIndex.Value)];
            }

            if (objTask.TaskId > 0)
            {
                objTask.Mode = 1;
            }
            else
            {
                objTask.Mode = 0;
            }

            objTask.Title = txtSubTaskTitle.Text;
            objTask.Description = txtSubTaskDescription.Text;
            objTask.Status = Convert.ToInt32(ddlSubTaskStatus.SelectedValue);
            objTask.DueDate = txtSubTaskDueDate.Text;
            objTask.Hours = txtSubTaskHours.Text;
            objTask.CreatedBy = Convert.ToInt16(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
            //task.InstallId = GetInstallIdFromDesignation(ddlUserDesignation.SelectedItem.Text);
            objTask.InstallId = txtTaskListID.Text.Trim();
            objTask.ParentTaskId = Convert.ToInt32(hdnTaskId.Value);
            objTask.Attachment = hdnAttachments.Value;

            if (ddlTaskType.SelectedIndex > 0)
            {
                objTask.TaskType = Convert.ToInt16(ddlTaskType.SelectedValue);
            }

            if (controlMode.Value == "0")
            {
                this.lstSubTasks.Add(objTask);

                SetSubTaskDetails(this.lstSubTasks);

                if (!string.IsNullOrEmpty(txtTaskListID.Text))
                {
                    this.LastSubTaskSequence = txtTaskListID.Text.Trim();
                }
            }
            else
            {
                // save task master details to database.
                if (hdnSubTaskId.Value == "0")
                {
                    hdnSubTaskId.Value = TaskGeneratorBLL.Instance.SaveOrDeleteTask(objTask).ToString();
                }
                else
                {
                    TaskGeneratorBLL.Instance.SaveOrDeleteTask(objTask);
                }

                UploadUserAttachements(null, Convert.ToInt64(hdnSubTaskId.Value), objTask.Attachment);
                SetSubTaskDetails(TaskGeneratorBLL.Instance.GetSubTasks(Convert.ToInt32(hdnTaskId.Value)).Tables[0]);
            }
            hdnAttachments.Value = string.Empty;
            ClearSubTaskData();
        }

        private void SetSubTaskDetails(List<Task> lstSubtasks)
        {
            // Title, [Description], [Status], DueDate,Tasks.[Hours], Tasks.CreatedOn, Tasks.InstallId, Tasks.CreatedBy, @AssigningUser AS AssigningManager
            DataTable dtSubtasks = new DataTable();
            dtSubtasks.Columns.Add("Title");
            dtSubtasks.Columns.Add("Description");
            dtSubtasks.Columns.Add("Status");
            dtSubtasks.Columns.Add("DueDate");
            dtSubtasks.Columns.Add("Hours");
            dtSubtasks.Columns.Add("InstallId");
            dtSubtasks.Columns.Add("FristName");
            dtSubtasks.Columns.Add("TaskType");
            dtSubtasks.Columns.Add("attachment");

            foreach (Task objSubTask in lstSubtasks)
            {
                dtSubtasks.Rows.Add(objSubTask.Title, objSubTask.Description, objSubTask.Status, objSubTask.DueDate, objSubTask.Hours, objSubTask.InstallId, string.Empty, objSubTask.TaskType, objSubTask.Attachment);
            }

            gvSubTasks.DataSource = dtSubtasks;
            gvSubTasks.DataBind();
            upSubTasks.Update();
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
        private void SaveAssignedTaskUsers(DropDownCheckBoxes ddcbAssigned, TaskStatus objTaskStatus)
        {
            //if task id is available to save its note and attachement.
            if (hdnTaskId.Value != "0")
            {
                string strUsersIds = string.Empty;

                foreach (ListItem item in ddcbAssigned.Items)
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
                        if (objTaskStatus == TaskStatus.Open || objTaskStatus == TaskStatus.Requested)
                        {
                            UpdateTaskStatus(Convert.ToInt32(hdnTaskId.Value), Convert.ToUInt16(TaskStatus.Assigned));
                        }

                        SendEmailToAssignedUsers(strUsersIds);
                    }
                }
                // send email to all users of the department as task is assigned to designation, but not to any specific user.
                else
                {
                    string strUserIDs = "";

                    foreach (ListItem item in ddcbAssigned.Items)
                    {
                        strUserIDs += string.Concat(item.Value, ",");
                    }

                    SendEmailToAssignedUsers(strUserIDs.TrimEnd(','));
                }
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

        //        foreach (ListItem item in ddcbAssigned.Items)
        //        {
        //            if (item.Selected)
        //            {
        //                // Save task notes and user information, returns TaskUpdateId for reference to add in user attachments.
        //                Int32 TaskUpdateId = SaveTaskNote(Convert.ToInt64(hdnTaskId.Value), isCreatorUser, Convert.ToInt32(item.Value), item.Text);
        //            }

        //        }


        //    }

        //}

        /// <summary>
        /// Save task note and attachment added by user.
        /// </summary>
        private void SaveTaskNotesNAttachments()
        {
            //if task id is available to save its note and attachement.
            if (hdnTaskId.Value != "0")
            {
                Boolean? isCreatorUser = null;

                //if it is task is created than control mode will be 0 and Admin user has created task.
                if (controlMode.Value == "0")
                {
                    isCreatorUser = true;
                }

                // Save task notes and user information, returns TaskUpdateId for reference to add in user attachments.
                Int32 TaskUpdateId = SaveTaskNote(Convert.ToInt64(hdnTaskId.Value), isCreatorUser, null, string.Empty);

                // Save task related user's attachment.
                UploadUserAttachements(TaskUpdateId, null, string.Empty);

                LoadTaskData(hdnTaskId.Value);

                txtNote.Text = string.Empty;

                //clearAllFormData();

                // Refresh task list on top header.
                //SearchTasks(null);

                //if (controlMode.Value == "0")
                //{
                //    ScriptManager.RegisterStartupScript(this.Page, GetType(), "al", "alert('Task created successfully');", true);
                //}
                //else
                //{
                //   ScriptManager.RegisterStartupScript(this.Page, GetType(), "al", "alert('Task updated successfully');", true);
                //}

            }
        }

        private void UploadUserAttachements(int? taskUpdateId, long? TaskId, string attachments)
        {
            //User has attached file than save it to database.
            if (!String.IsNullOrEmpty(attachments))
            {
                TaskUser taskUserFiles = new TaskUser();
                String[] files;

                if (!string.IsNullOrEmpty(attachments))
                {
                    files = attachments.Split(new char[] { '^' }, StringSplitOptions.RemoveEmptyEntries);
                }
                else
                {
                    files = hdnAttachments.Value.Split(new char[] { '^' }, StringSplitOptions.RemoveEmptyEntries);
                }


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
                    TaskGeneratorBLL.Instance.SaveOrDeleteTaskUserFiles(taskUserFiles);  // save task files
                }
            }
        }

        /// <summary>
        /// Save task user information.
        /// </summary>
        /// <param name="Designame"></param>
        /// <param name="ItaskId"></param>
        private Int32 SaveTaskNote(long ItaskId, Boolean? IsCreated, Int32? UserId, String UserName)
        {
            Int32 TaskUpdateId = 0;

            TaskUser taskUser = new TaskUser();

            if (UserId == null)
            {
                // Take logged in user's id for logging note in database.
                taskUser.UserId = Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
                taskUser.UserFirstName = Session["Username"].ToString();
            }
            else
            {
                taskUser.UserId = Convert.ToInt32(UserId);
                taskUser.UserFirstName = UserName;
            }



            //taskUser.UserType = userType.Text;
            taskUser.Notes = txtNote.Text;

            // if user has just created task then send entry with iscreator= true to distinguish record from other user's log.

            if (IsCreated != null)
            {
                taskUser.IsCreatorUser = true;
            }
            else
            {
                taskUser.IsCreatorUser = false;
            }

            taskUser.TaskId = ItaskId;

            taskUser.Status = Convert.ToInt16(cmbStatus.SelectedItem.Value);

            int userAcceptance = Convert.ToInt32(ddlUserAcceptance.SelectedItem.Value);

            taskUser.UserAcceptance = Convert.ToBoolean(userAcceptance);

            TaskGeneratorBLL.Instance.SaveOrDeleteTaskNotes(ref taskUser);

            TaskUpdateId = Convert.ToInt32(taskUser.TaskUpdateId);

            //for (int i = 0; i < gdTaskUsers.Rows.Count; i++)
            //{

            //    TaskUser taskUser = new TaskUser();
            //    Label userID = (Label)gdTaskUsers.Rows[i].Cells[1].FindControl("lbluserId");
            //    Label userType = (Label)gdTaskUsers.Rows[i].Cells[1].FindControl("lbluserType");
            //    Label notes = (Label)gdTaskUsers.Rows[i].Cells[1].FindControl("lblNotes");
            //    taskUser.UserId = Convert.ToInt32(userID.Text);
            //    //taskUser.UserType = userType.Text;
            //    taskUser.Notes = notes.Text;
            //    taskUser.TaskId = ItaskId;

            //    taskUser.Status = Convert.ToInt16(cmbStatus.SelectedItem.Value);
            //    int userAcceptance = Convert.ToInt32(ddlUserAcceptance.SelectedItem.Value);
            //    taskUser.UserAcceptance = Convert.ToBoolean(userAcceptance);
            //    TaskGeneratorBLL.Instance.SaveOrDeleteTaskUser(ref taskUser);

            //    TaskUpdateId = taskUser.TaskUpdateId;

            //    //Inform user by email about task assgignment.
            //    //SendEmail(Designame, taskUser.UserId); // send auto email to selected users

            //}

            return TaskUpdateId;
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
            SetTaskAssignedUsers(dtTaskAssignedUserDetails);
            SetTaskUserNNotesDetails(dtTaskNotesDetails);
            SetSubTaskDetails(dtSubTaskDetails);
            FillrptWorkFiles(dsTaskDetails.Tables[5]);

            SetTaskPopupTitle(TaskId, dtTaskMasterDetails);
        }

        private void FillrptWorkFiles(DataTable dtTaskUserFiles)
        {
            if (dtTaskUserFiles != null)
            {
                intTaskUserFilesCount = dtTaskUserFiles.Rows.Count;
            }
            rptWorkFiles.DataSource = dtTaskUserFiles;
            rptWorkFiles.DataBind();
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

        private void SetTaskAssignedUsers(DataTable dtTaskAssignedUserDetails)
        {
            String firstAssignedUser = String.Empty;
            foreach (DataRow row in dtTaskAssignedUserDetails.Rows)
            {

                ListItem item = ddcbAssigned.Items.FindByValue(row["UserId"].ToString());

                if (item != null)
                {
                    item.Selected = true;

                    if (string.IsNullOrEmpty(firstAssignedUser))
                    {
                        firstAssignedUser = item.Text;
                    }
                }
            }

            if (!String.IsNullOrEmpty(firstAssignedUser))
            {
                ddcbAssigned.Texts.SelectBoxCaption = firstAssignedUser;
            }
            else
            {
                ddcbAssigned.Texts.SelectBoxCaption = "--Open--";
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

                ltlTUDesig.Text = String.IsNullOrEmpty(designations.ToString()) == true ? string.Empty : designations.ToString().Substring(0, designations.ToString().Length - 1);
            }
        }

        private void SetTaskUserNNotesDetails(DataTable dtTaskUserDetails)
        {
            gdTaskUsers.DataSource = dtTaskUserDetails;
            gdTaskUsers.DataBind();
        }

        private void SetSubTaskDetails(DataTable dtSubTaskDetails)
        {
            gvSubTasks1.DataSource = dtSubTaskDetails;
            gvSubTasks1.DataBind();

            gvSubTasks.DataSource = dtSubTaskDetails;
            gvSubTasks.DataBind();
            upSubTasks.Update();

            if (dtSubTaskDetails.Rows.Count > 0)
            {
                this.LastSubTaskSequence = dtSubTaskDetails.Rows[dtSubTaskDetails.Rows.Count - 1]["InstallId"].ToString();
            }
            else
            {
                this.LastSubTaskSequence = String.Empty;
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
                    cmbStatus.SelectedIndex = cmbStatus.Items.IndexOf(item);
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
                    ddlTUStatus.SelectedIndex = cmbStatus.Items.IndexOf(item);
                }

                ltlTUDueDate.Text = CommonFunction.FormatToShortDateString(dtTaskMasterDetails.Rows[0]["DueDate"]);
                ltlTUHrsTask.Text = dtTaskMasterDetails.Rows[0]["Hours"].ToString();


            }
            // ddlUserDesignation.SelectedValue = dtTaskMasterDetails.Rows[0]["Designation"].ToString();
            //LoadUsersByDesgination();
        }

        private void toggleValidators(bool flag)
        {
            rfvTaskTitle.Visible = flag;
            rfvDesc.Visible = flag;
            cvDesignations.Visible = flag;
        }

        private void DownloadUserAttachments(String CommaSeperatedFiles)
        {
            string[] files = CommaSeperatedFiles.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);

            //var archive = Server.MapPath("~/TaskAttachments/archive.zip");
            //var temp = Server.MapPath("~/TaskAttachments/temp");

            //// clear any existing archive
            //if (System.IO.File.Exists(archive))
            //{
            //    System.IO.File.Delete(archive);
            //}

            //// empty the temp folder
            //Directory.EnumerateFiles(temp).ToList().ForEach(f => System.IO.File.Delete(f));

            //// copy the selected files to the temp folder
            //foreach (var file in files)
            //{
            //    System.IO.File.Copy(file, Path.Combine(temp, Path.GetFileName(file)));
            //}

            //// create a new archive
            //ZipFile.CreateFromDirectory(temp, archive);

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

                gvSubTasks.DataSource = this.lstSubTasks;
                gvSubTasks.DataBind();
            }
            else
            {
                tblAdminTaskView.Visible = false;
                tblUserTaskView.Visible = true;
            }
        }

        private void DownloadPdf(byte[] arrPdf, string strFileName)
        {
            if (arrPdf != null)
            {
                Response.Clear();
                Response.ContentType = "application/pdf";
                Response.AddHeader("content-disposition", "attachment;filename=" + strFileName);
                Response.Buffer = true;
                (new MemoryStream(arrPdf)).WriteTo(Response.OutputStream);
                Response.End();
            }
        }

        private string GetWorkSpecificationFilePopupTitle(string strFreezeUserName, string strLastUpdatedUserName)
        {
            string strTitle = string.Empty;
            strTitle += "<div style='width:100%;'>";
            strTitle += "<div style='float:left;max-width:180px;'>";
            strTitle += "Work Specification Files";
            strTitle += "</div>";
            strTitle += "<div style='float:right; font-size:12px; font-weight:normal;max-width:330px;'>";
            if (!string.IsNullOrEmpty(strFreezeUserName))
            {
                strTitle += string.Concat("Specs freezed by: ", strFreezeUserName);
            }
            if (!string.IsNullOrEmpty(strLastUpdatedUserName))
            {
                strTitle += string.Concat(", Last updated by: ", strLastUpdatedUserName);
            }
            strTitle += "</div>";
            strTitle += "</div>";

            return strTitle;
        }


        #endregion
    }
}