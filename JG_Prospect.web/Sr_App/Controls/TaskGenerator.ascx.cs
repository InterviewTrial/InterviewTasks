#region "-- using -"

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

namespace JG_Prospect.Sr_App.Controls
{
    public partial class TaskGenerator : System.Web.UI.UserControl
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

        private List<string> lstTaskUserFiles
        {
            get
            {
                if (ViewState["lstTaskUserFiles"] == null)
                {
                    ViewState["lstTaskUserFiles"] = new List<string>();
                }
                return (List<string>)ViewState["lstTaskUserFiles"];
            }
            set
            {
                ViewState["lstTaskUserFiles"] = value;
            }
        }

        private SortDirection TaskSortDirection
        {
            get
            {
                if (ViewState["TaskSortDirection"] == null)
                {
                    return SortDirection.Descending;
                }
                return (SortDirection)ViewState["TaskSortDirection"];
            }
            set
            {
                ViewState["TaskSortDirection"] = value;
            }
        }

        private string TaskSortExpression
        {
            get
            {
                if (ViewState["TaskSortExpression"] == null)
                {
                    return "CreatedOn";
                }
                return Convert.ToString(ViewState["TaskSortExpression"]);
            }
            set
            {
                ViewState["TaskSortExpression"] = value;
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

                // Add mode for task control.
                controlMode.Value = "0";
                SetControlDisplay();
                LoadFilters();
                //SearchTasks(null);
                SearchTasks(50);
                LoadPopupDropdown();
            }
        }

        #endregion

        #region "--Control Events--"

        #region Filters - Search Task

        protected void ddlDesignation_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadFilterUsersByDesgination();
            SearchTasks(null);
        }

        protected void ddlUsers_SelectedIndexChanged(object sender, EventArgs e)
        {
            SearchTasks(null);
        }

        protected void ddlTaskStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
            SearchTasks(null);
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            SearchTasks(null);
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            SearchTasks(null);
        }

        #endregion

        protected void lbtnAddNew_Click(object sender, EventArgs e)
        {
            //clearAllFormData();

            //SetTaskView();

            //cmbStatus.DataSource = CommonFunction.GetTaskStatusList();
            //cmbStatus.DataTextField = "Text";
            //cmbStatus.DataValueField = "Value";
            //cmbStatus.DataBind();

            //ddlTUStatus.DataSource = CommonFunction.GetTaskStatusList();
            //ddlTUStatus.DataTextField = "Text";
            //ddlTUStatus.DataValueField = "Value";
            //ddlTUStatus.DataBind();

            //this.LastSubTaskSequence = string.Empty;

            //ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(), "open popup", "EditTask(0,\"Add New Task\");", true);

            Response.Redirect("~/sr_app/TaskGenerator.aspx");
        }

        protected void btnLoadMore_Click(object sender, EventArgs e)
        {
            SearchTasks(50);
            ScriptManager.RegisterStartupScript((sender as Control), this.GetType(), "expand", "SetHeaderSectionHeight();", true);
        }

        #region gvTasks - Task List

        protected void gvTasks_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            //if (!this.IsAdminMode)
            //{
            //    e.Row.Cells[e.Row.Cells.Count - 1].Visible = false;
            //}

            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                HyperLink hypTask = (HyperLink)e.Row.FindControl("hypTask");
                DropDownList ddlTaskStatus = (DropDownList)e.Row.FindControl("ddlTaskStatus");
                LinkButton lbtnRequestStatus = (LinkButton)e.Row.FindControl("lbtnRequestStatus");
                HtmlAnchor hypUsers = (HtmlAnchor)e.Row.FindControl("hypUsers");
                DropDownCheckBoxes ddcbAssigned = e.Row.FindControl("ddcbAssigned") as DropDownCheckBoxes;
                HtmlAnchor hypDesg = (HtmlAnchor)e.Row.FindControl("hypDesg");

                ddlTaskStatus.DataSource = CommonFunction.GetTaskStatusList();
                ddlTaskStatus.DataTextField = "Text";
                ddlTaskStatus.DataValueField = "Value";
                ddlTaskStatus.DataBind();
                //ddlTaskStatus.Items.FindByValue(Convert.ToByte(JGConstant.TaskStatus.SpecsInProgress).ToString()).Enabled = false;

                SetStatusSelectedValue(ddlTaskStatus, DataBinder.Eval(e.Row.DataItem, "Status").ToString());

                hypTask.NavigateUrl = "~/sr_app/TaskGenerator.aspx?TaskId=" + DataBinder.Eval(e.Row.DataItem, "TaskId").ToString();

                hypDesg.InnerHtml = getSingleValueFromCommaSeperatedString(Convert.ToString(DataBinder.Eval(e.Row.DataItem, "TaskDesignations")));

                hypDesg.Attributes.Add("title", Convert.ToString(DataBinder.Eval(e.Row.DataItem, "TaskDesignations")));


                if (this.IsAdminMode)
                {
                    #region Admin User

                    if (
                        ddlTaskStatus.SelectedValue != Convert.ToByte(JGConstant.TaskStatus.Requested).ToString() &&
                        ddlTaskStatus.SelectedValue != Convert.ToByte(JGConstant.TaskStatus.InProgress).ToString() &&
                        ddlTaskStatus.SelectedValue != Convert.ToByte(JGConstant.TaskStatus.SpecsInProgress).ToString() &&
                        ddlTaskStatus.SelectedValue != Convert.ToByte(JGConstant.TaskStatus.Closed).ToString()
                       )
                    {
                        ddcbAssigned.Visible = true;
                        lbtnRequestStatus.Visible =
                        hypUsers.Visible = false;

                        DataSet dsUsers = TaskGeneratorBLL.Instance.GetInstallUsers(2, Convert.ToString(DataBinder.Eval(e.Row.DataItem, "TaskDesignations")).Trim());

                        ddcbAssigned.Items.Clear();
                        ddcbAssigned.DataSource = dsUsers;
                        ddcbAssigned.DataTextField = "FristName";
                        ddcbAssigned.DataValueField = "Id";
                        ddcbAssigned.DataBind();
                    }
                    else if (ddlTaskStatus.SelectedValue == Convert.ToByte(JGConstant.TaskStatus.Requested).ToString())
                    {
                        lbtnRequestStatus.Visible = true;
                        ddcbAssigned.Visible =
                        hypUsers.Visible = false;

                        String[] status = Convert.ToString(DataBinder.Eval(e.Row.DataItem, "TaskAssignmentRequestUsers")).Split(':');

                        if (status.Length > 1)
                        {
                            lbtnRequestStatus.Text = status[1];
                        }

                        lbtnRequestStatus.ForeColor = System.Drawing.Color.Red;
                        lbtnRequestStatus.CommandName = "approve-request";
                        lbtnRequestStatus.CommandArgument = DataBinder.Eval(e.Row.DataItem, "TaskId").ToString() + ":" + Convert.ToString(DataBinder.Eval(e.Row.DataItem, "TaskAssignmentRequestUsers")).Split(':')[0];
                    }
                    else
                    {
                        ddcbAssigned.Visible = true;
                        hypUsers.Visible =
                        lbtnRequestStatus.Visible = false;
                        DataSet dsUsers = TaskGeneratorBLL.Instance.GetInstallUsers(2, Convert.ToString(DataBinder.Eval(e.Row.DataItem, "TaskDesignations")).Trim());

                        ddcbAssigned.Items.Clear();
                        ddcbAssigned.DataSource = dsUsers;
                        ddcbAssigned.DataTextField = "FristName";
                        ddcbAssigned.DataValueField = "Id";
                        ddcbAssigned.DataBind();

                        SetTaskAssignedUsers(Convert.ToString(DataBinder.Eval(e.Row.DataItem, "TaskAssignedUsers")), ddcbAssigned);
                        hypUsers.InnerHtml = getSingleValueFromCommaSeperatedString(Convert.ToString(DataBinder.Eval(e.Row.DataItem, "TaskAssignedUsers")));
                        hypUsers.Attributes.Add("title", Convert.ToString(DataBinder.Eval(e.Row.DataItem, "TaskAssignedUsers")));
                    }

                    // set assigned user selection in dropdown.
                    if (!string.IsNullOrEmpty(DataBinder.Eval(e.Row.DataItem, "TaskAssignedUserIds").ToString()) && ddcbAssigned.Items.Count > 0)
                    {
                        string[] arrUserIds = DataBinder.Eval(e.Row.DataItem, "TaskAssignedUserIds").ToString().Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                        foreach (string strId in arrUserIds)
                        {
                            ListItem objListItem = ddcbAssigned.Items.FindByValue(strId.Trim());
                            if (objListItem != null)
                            {
                                objListItem.Selected = true;
                                ddcbAssigned.Texts.SelectBoxCaption = objListItem.Text;
                            }
                        }
                    }

                    // below attributes are used in user assignement change.
                    ddcbAssigned.Attributes.Add("TaskId", DataBinder.Eval(e.Row.DataItem, "TaskId").ToString());
                    ddcbAssigned.Attributes.Add("TaskStatus", ddlTaskStatus.SelectedValue);

                    #endregion
                }
                else
                {
                    #region Install User

                    HtmlGenericControl divAcceptRejectButtons = e.Row.FindControl("divAcceptRejectButtons") as HtmlGenericControl;

                    string strMyDesignation = Convert.ToString(Session["DesigNew"]).Trim().ToUpper();
                    string[] arrTaskDesignations = Convert.ToString(DataBinder.Eval(e.Row.DataItem, "TaskDesignations")).Split(',');

                    bool blSameDesignation = false;
                    if (arrTaskDesignations != null && arrTaskDesignations.Any(d => d.ToUpper().Trim() == strMyDesignation))
                    {
                        blSameDesignation = true;
                    }

                    // show request link when,
                    // 1. task belongs to my designation
                    // 2. task is not assigned to any user.
                    if (
                        blSameDesignation &&
                        string.IsNullOrEmpty(Convert.ToString(DataBinder.Eval(e.Row.DataItem, "TaskAssignedUsers")).Trim())
                       )
                    {
                        string strTaskAcceptanceUsers = Convert.ToString(DataBinder.Eval(e.Row.DataItem, "TaskAcceptanceUsers"));

                        // show accept - reject buttons when, acceptance log for current task does not contain current user.
                        if (
                            string.IsNullOrEmpty(strTaskAcceptanceUsers) ||
                            strTaskAcceptanceUsers.Split(',').Count(s => s.Trim() == JGSession.UserId.ToString()) == 0)
                        {
                            divAcceptRejectButtons.Visible = true;
                        }
                        else
                        {
                            divAcceptRejectButtons.Visible = false;
                        }

                        lbtnRequestStatus.Visible = true;

                        ddcbAssigned.Visible =
                        hypUsers.Visible = false;

                        lbtnRequestStatus.ForeColor = System.Drawing.Color.Green;
                        lbtnRequestStatus.CommandName = "request";
                        lbtnRequestStatus.CommandArgument = DataBinder.Eval(e.Row.DataItem, "TaskId").ToString() + ":" + DataBinder.Eval(e.Row.DataItem, "CreatedBy").ToString();
                    }
                    else
                    {
                        ddcbAssigned.Visible =
                        divAcceptRejectButtons.Visible =
                        lbtnRequestStatus.Visible = false;

                        hypUsers.Visible = true;
                        hypUsers.InnerHtml = getSingleValueFromCommaSeperatedString(Convert.ToString(DataBinder.Eval(e.Row.DataItem, "TaskAssignedUsers")));
                        hypUsers.Attributes.Add("title", Convert.ToString(DataBinder.Eval(e.Row.DataItem, "TaskAssignedUsers")));
                    }

                    #endregion
                }
                string strRowCssClass = string.Empty;

                if (e.Row.RowState == DataControlRowState.Alternate)
                {
                    strRowCssClass = "AlternateRow";
                }
                else
                {
                    strRowCssClass = "FirstRow";
                }

                switch ((JGConstant.TaskStatus)Convert.ToByte(DataBinder.Eval(e.Row.DataItem, "Status")))
                {
                    case JGConstant.TaskStatus.Open:
                        strRowCssClass += " task-open";
                        if (!string.IsNullOrEmpty(DataBinder.Eval(e.Row.DataItem, "TaskPriority").ToString()) && 
                            DataBinder.Eval(e.Row.DataItem, "TaskPriority").ToString() != "0")
                        {
                            strRowCssClass += " task-with-priority";
                        }
                        break;
                    case JGConstant.TaskStatus.Requested:
                        strRowCssClass += " task-requested";
                        break;
                    case JGConstant.TaskStatus.Assigned:
                        strRowCssClass += " task-assigned";
                        break;
                    case JGConstant.TaskStatus.InProgress:
                        strRowCssClass += " task-inprogress";
                        break;
                    case JGConstant.TaskStatus.Pending:
                        strRowCssClass += " task-pending";
                        break;
                    case JGConstant.TaskStatus.ReOpened:
                        strRowCssClass += " task-reopened";
                        break;
                    case JGConstant.TaskStatus.Closed:
                        strRowCssClass += " task-closed closed-task-bg";
                        ddcbAssigned.Enabled = false;
                    ddlTaskStatus.Enabled = false;
                        break;
                    case JGConstant.TaskStatus.SpecsInProgress:
                        strRowCssClass += " task-specsinprogress";
                        break;
                    case JGConstant.TaskStatus.Deleted:
                        strRowCssClass += " task-deleted deleted-task-bg";
                        ddcbAssigned.Enabled = false;
                    ddlTaskStatus.Enabled = false;
                        break;
                    default:
                        break;
                }

                e.Row.CssClass = strRowCssClass;
            }
        }

        protected void gvTasks_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditTask")
            {
                clearAllFormData();
                controlMode.Value = "1";
                hdnTaskId.Value = e.CommandArgument.ToString();

                cmbStatus.DataSource = CommonFunction.GetTaskStatusList();
                cmbStatus.DataTextField = "Text";
                cmbStatus.DataValueField = "Value";
                cmbStatus.DataBind();
                //cmbStatus.Items.FindByValue(Convert.ToByte(JGConstant.TaskStatus.SpecsInProgress).ToString()).Enabled = false;

                LoadTaskData(e.CommandArgument.ToString(), true);
            }
            else if (e.CommandName == "request")
            {
                Task objTask = new Task()
                {
                    TaskId = Convert.ToInt32(e.CommandArgument.ToString().Split(':')[0]),
                    Status = Convert.ToByte(JGConstant.TaskStatus.Requested)
                };

                // update task status to requested.
                if (TaskGeneratorBLL.Instance.UpdateTaskStatus(objTask) > 0)
                {
                    // insert user request.
                    if (TaskGeneratorBLL.Instance.SaveTaskAssignmentRequests(Convert.ToUInt64(objTask.TaskId), Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()].ToString()))
                    {
                        SendEmailToAdminUser(objTask.TaskId, Convert.ToInt32(e.CommandArgument.ToString().Split(':')[1]));

                        SearchTasks(null);
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
                    Status = Convert.ToByte(JGConstant.TaskStatus.Assigned)
                };

                if (TaskGeneratorBLL.Instance.UpdateTaskStatus(objTask) > 0)
                {
                    // insert user request.
                    if (TaskGeneratorBLL.Instance.AcceptTaskAssignmentRequests(Convert.ToUInt64(objTask.TaskId), e.CommandArgument.ToString().Split(':')[1]))
                    {
                        SendEmailToAssignedUsers(objTask.TaskId, e.CommandArgument.ToString().Split(':')[1]);
                        SearchTasks(null);
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
            else if (e.CommandName == "accept")
            {
                bool isSuccessful = TaskGeneratorBLL.Instance.SaveTaskAssignedUsers(Convert.ToUInt64(e.CommandArgument), JGSession.UserId.ToString());
                if (isSuccessful)
                {
                    TaskAcceptance objTaskAcceptance = new TaskAcceptance();
                    objTaskAcceptance.IsAccepted = true;
                    objTaskAcceptance.IsInstallUser = JGSession.IsInstallUser.Value;
                    objTaskAcceptance.UserId = JGSession.UserId;
                    objTaskAcceptance.TaskId = Convert.ToInt64(e.CommandArgument);

                    if (TaskGeneratorBLL.Instance.InsertTaskAcceptance(objTaskAcceptance) >= 0)
                    {
                        SearchTasks(null);
                    }
                    CommonFunction.ShowAlertFromUpdatePanel(this.Page, "Task accepted successfully");
                }
                else
                {
                    CommonFunction.ShowAlertFromUpdatePanel(this.Page, "Task acceptance was not successfull, Please try again later.");
                }
            }
            else if (e.CommandName == "reject")
            {
                TaskAcceptance objTaskAcceptance = new TaskAcceptance();
                objTaskAcceptance.IsAccepted = false;
                objTaskAcceptance.IsInstallUser = JGSession.IsInstallUser.Value;
                objTaskAcceptance.UserId = JGSession.UserId;
                objTaskAcceptance.TaskId = Convert.ToInt64(e.CommandArgument);

                if (TaskGeneratorBLL.Instance.InsertTaskAcceptance(objTaskAcceptance) >= 0)
                {
                    SearchTasks(null);

                    CommonFunction.ShowAlertFromUpdatePanel(this.Page, "Task rejected successfully");
                }
                else
                {
                    CommonFunction.ShowAlertFromUpdatePanel(this.Page, "Task rejection was not successfull, Please try again later.");
                }
            }
            //else if (e.CommandName == "RemoveTask")
            //{
            //    DeletaTask(e.CommandArgument.ToString());
            //}
        }

        protected void gvTasks_Sorting(object sender, GridViewSortEventArgs e)
        {
            if (this.TaskSortExpression == e.SortExpression)
            {
                if (this.TaskSortDirection == SortDirection.Ascending)
                {
                    this.TaskSortDirection = SortDirection.Descending;
                }
                else
                {
                    this.TaskSortDirection = SortDirection.Ascending;
                }
            }
            else
            {
                this.TaskSortExpression = e.SortExpression;
                this.TaskSortDirection = SortDirection.Ascending;
            }

            SearchTasks(null);
        }

        protected void gvTasks_ddcbAssigned_SelectedIndexChanged(object sender, EventArgs e)
        {
            DropDownCheckBoxes ddcbAssigned = (DropDownCheckBoxes)sender;
            GridViewRow objGridViewRow = (GridViewRow)ddcbAssigned.NamingContainer;
            hdnTaskId.Value = ((HiddenField)objGridViewRow.FindControl("hdnTaskId")).Value;
            DropDownList ddlTaskStatus = objGridViewRow.FindControl("ddlTaskStatus") as DropDownList;

            if (ValidateTaskStatus(ddlTaskStatus, ddcbAssigned,Convert.ToInt32(hdnTaskId.Value)))
            {
                SaveAssignedTaskUsers(ddcbAssigned, (JGConstant.TaskStatus)Convert.ToByte(ddcbAssigned.Attributes["TaskStatus"]));
            }
            hdnTaskId.Value = "0";
            SearchTasks(null);
        }

        protected void gvTasks_ddlTaskStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
            DropDownList ddlTaskStatus = (DropDownList)sender;
            GridViewRow objGridViewRow = (GridViewRow)ddlTaskStatus.NamingContainer;
            HiddenField hdnTaskId = (HiddenField)objGridViewRow.FindControl("hdnTaskId");
            DropDownCheckBoxes ddcbAssigned = objGridViewRow.FindControl("ddcbAssigned") as DropDownCheckBoxes;

            if (ValidateTaskStatus(ddlTaskStatus, ddcbAssigned,Convert.ToInt32(hdnTaskId.Value)))
            {
                Task objTask = new Task();
                objTask.TaskId = Convert.ToInt32(hdnTaskId.Value);
                objTask.Status = Convert.ToUInt16(ddlTaskStatus.SelectedItem.Value);
                TaskGeneratorBLL.Instance.UpdateTaskStatus(objTask);
            }
            SearchTasks(null);
        }

        #endregion

        #region gdTaskUsers - Task History

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

        #region Popup - Add / Edit Task

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
                string file = e.Item.DataItem.ToString();

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

                if (e.Item.ItemIndex == intTaskUserFilesCount - 1)
                {
                    e.Item.FindControl("ltrlSeprator").Visible = false;
                }
            }
        }

        protected void gvSubTasks_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                if (!String.IsNullOrEmpty(DataBinder.Eval(e.Row.DataItem, "attachment").ToString()))
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

        protected void btnSaveSubTask_Click(object sender, EventArgs e)
        {
            SaveSubTask();
            ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(), "slid up sub task", "$('#" + divSubTask.ClientID + "').slideUp('slow');", true);
        }

        protected void btnSaveTask_Click(object sender, EventArgs e)
        {
            //Save task master details
            SaveTask();

            // Save assgined designation.
            SaveTaskDesignations();

            //Save details of users to whom task is assgined.
            SaveAssignedTaskUsers(ddcbAssigned, (JGConstant.TaskStatus)Convert.ToByte(cmbStatus.SelectedItem.Value));

            if (controlMode.Value == "0" && this.lstTaskUserFiles.Any())
            {
                foreach (string strFile in this.lstTaskUserFiles)
                {
                    UploadUserAttachements(null, Convert.ToInt64(hdnTaskId.Value), strFile);
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

        protected void btnRemoveTask_Click(object sender, EventArgs e)
        {
            DeletaTask(hdnDeleteTaskId.Value);
            ScriptManager.RegisterStartupScript((sender as Control), this.GetType(), "HidePopup", "CloseTaskPopup();", true);
        }

        protected void btnAddNote_Click(object sender, EventArgs e)
        {
            SaveTaskNotesNAttachments();
            hdnAttachments.Value = "";
        }

        protected void btnAddAttachment_ClicK(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(hdnWorkFiles.Value))
            {
                if (controlMode.Value == "0")
                {
                    lstTaskUserFiles.AddRange(hdnWorkFiles.Value.Split('^'));
                }
                else
                {
                    UploadUserAttachements(null, Convert.ToInt32(hdnTaskId.Value), hdnWorkFiles.Value);
                    DataSet dsTaskUserFiles = TaskGeneratorBLL.Instance.GetTaskUserFiles(Convert.ToInt32(hdnTaskId.Value), JGConstant.TaskFileDestination.WorkSpecification, null, null);
                    if (dsTaskUserFiles != null && dsTaskUserFiles.Tables.Count > 0)
                    {
                        foreach (DataRow drFile in dsTaskUserFiles.Tables[0].Rows)
                        {
                            if (!string.IsNullOrEmpty(Convert.ToString(drFile["attachment"])))
                            {
                                lstTaskUserFiles.Add(drFile["attachment"].ToString());
                            }
                        }
                    }
                }
                intTaskUserFilesCount = lstTaskUserFiles.Count;
                rptWorkFiles.DataSource = lstTaskUserFiles;
                rptWorkFiles.DataBind();
                hdnWorkFiles.Value = "";
                upWorkSpecifications.Update();
            }
        }

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

        protected void ddlTaskType_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (ddlTaskType.SelectedValue == Convert.ToInt16(JGConstant.TaskType.Enhancement).ToString())
            {
                trDateHours.Visible = true;
            }
            else
            {
                trDateHours.Visible = false;
            }
            ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(), "slid down sub task", "$('#" + divSubTask.ClientID + "').slideDown('slow');", true);
        }


        #endregion

        #endregion

        #region "--Private Methods--"

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

        private void SetControlDisplay()
        {
            if (!this.IsAdminMode)
            {
                tdAdd.Visible = false;
                tdAddCap.Visible = false;
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

            if (dsFilters != null && dsFilters.Tables.Count > 0)
            {
                DataTable dtUsers = dsFilters.Tables[0];

                ddlTaskStatus.DataSource = CommonFunction.GetTaskStatusList();
                ddlTaskStatus.DataTextField = "Text";
                ddlTaskStatus.DataValueField = "Value";
                ddlTaskStatus.DataBind();
                ddlTaskStatus.Items.Insert(0, new ListItem("--All--", "0"));

                //if (!this.IsAdminMode)
                //{
                //    ddlTaskStatus.Items.FindByValue(Convert.ToByte(JGConstant.TaskStatus.SpecsInProgress).ToString()).Enabled = false;
                //}

                ddlUsers.DataSource = dtUsers;
                ddlUsers.DataTextField = "FirstName";
                ddlUsers.DataValueField = "Id";
                ddlUsers.DataBind();

                ddlUsers.Items.Insert(0, new ListItem("--All--", "0"));
                ddlDesignation.Items.Insert(0, new ListItem("--All--", "0"));
                HighlightInterviewUsers(dtUsers, null, ddlUsers);
            }
        }

        /// <summary>
        /// Search tasks with parameters choosen by user.
        /// </summary>
        private void SearchTasks(int? RecordstoPull)
        {

            int? UserID = null;
            string Title = String.Empty, Designation = String.Empty, Designations = String.Empty, Statuses = String.Empty;
            Int16? Status = null;
            DateTime? CreatedFrom = null, CreatedTo = null;


            // this is for paging based data fetch, in header view case it will be always page numnber 0 and page size 5
            int Start = 0, PageLimit = 5;

            if (RecordstoPull != null)
            {
                PageLimit = Convert.ToInt32(RecordstoPull);
            }

            PrepareSearchFilters(ref UserID, ref Title, ref Designation, ref Status, ref CreatedFrom, ref CreatedTo, ref Statuses, ref Designations);

            string strSortExpression = this.TaskSortExpression + " " + (this.TaskSortDirection == SortDirection.Ascending ? "ASC" : "DESC");

            DataSet dsFilters = TaskGeneratorBLL.Instance.GetTasksList(UserID, Title, Designation, Status, CreatedFrom, CreatedTo, Statuses, Designations, CommonFunction.CheckAdminAndItLeadMode(), Start, PageLimit, strSortExpression);

            if (dsFilters != null && dsFilters.Tables.Count > 0)
            {
                gvTasks.DataSource = dsFilters;
                gvTasks.DataBind();
            }

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
            hdnDeleteTaskId.Value = String.Empty;
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

        private void LoadFilterUsersByDesgination()
        {
            DataSet dsUsers;

            // DropDownCheckBoxes ddlAssign = (FindControl("ddcbAssigned") as DropDownCheckBoxes);
            // DropDownList ddlDesignation = (DropDownList)sender;
            string designation = ddlDesignation.SelectedValue;

            dsUsers = TaskGeneratorBLL.Instance.GetInstallUsers(2, designation);

            ddlUsers.DataSource = dsUsers;
            ddlUsers.DataTextField = "FristName";
            ddlUsers.DataValueField = "Id";
            ddlUsers.DataBind();

            ddlUsers.Items.Insert(0, new ListItem("--All--", "0"));

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
                    //foreach (ListItem item in ddlDesignation.Items)
                    //{
                    //    Designations += (item.Value + ","); 
                    //}
                    //Designations = Designations.Trim(',');
                    Designations =
                    Designation = "0";
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
            if (ddlTaskStatus.SelectedIndex > 0)
            {
                Status = Convert.ToInt16(ddlTaskStatus.SelectedItem.Value);
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
            txtTaskListID.Text = string.Empty;
            txtSubTaskTitle.Text =
            txtSubTaskDescription.Text =
            txtSubTaskDueDate.Text =
            txtSubTaskHours.Text = string.Empty;
            if (ddlTaskType.Items.Count > 0)
            {
                ddlTaskType.SelectedIndex = 0;
            }
            upAddSubTask.Update();
        }

        private bool ValidateTaskStatus(DropDownList ddlTaskStatus, DropDownCheckBoxes ddlAssignedUser, Int32 intTaskId)
        {
            bool blResult = true;

            string strStatus = string.Empty;
            string strMessage = string.Empty;

            if (this.IsAdminMode)
            {
                strStatus = ddlTaskStatus.SelectedValue;

                //if (
                //    strStatus != Convert.ToByte(JGConstant.TaskStatus.SpecsInProgress).ToString() &&
                //    !TaskGeneratorBLL.Instance.IsTaskWorkSpecificationApproved(intTaskId)
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

                    foreach (ListItem objItem in ddlAssignedUser.Items)
                    {
                        if (objItem.Selected)
                        {
                            blResult = true;
                            break;
                        }
                    }
                }

                if (!blResult)
                {
                    CommonFunction.ShowAlertFromUpdatePanel(this.Page, strMessage);
                }
            }

            return blResult;
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

            Int64 ItaskId = TaskGeneratorBLL.Instance.SaveOrDeleteTask(task);    // save task master details

            if (controlMode.Value == "0")
            {
                hdnTaskId.Value = ItaskId.ToString();
            }
        }

        private void SaveSubTask()
        {
            int userId = Convert.ToInt16(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
            Task task = new Task();
            task.TaskId = Convert.ToInt32(hdnSubTaskId.Value);
            task.Title = txtSubTaskTitle.Text;
            task.Description = txtSubTaskDescription.Text;
            task.Status = 1; // 1 : Open
            task.DueDate = txtSubTaskDueDate.Text;
            task.Hours = txtSubTaskHours.Text;
            task.CreatedBy = userId;
            task.Mode = 0;// Convert.ToInt32(controlMode.Value);
            //task.InstallId = GetInstallIdFromDesignation(ddlUserDesignation.SelectedItem.Text);
            task.InstallId = txtTaskListID.Text.Trim();
            task.ParentTaskId = Convert.ToInt32(hdnTaskId.Value);
            task.Attachment = hdnAttachments.Value;

            if (ddlTaskType.SelectedIndex > 0)
            {
                task.TaskType = Convert.ToInt16(ddlTaskType.SelectedValue);
            }


            if (controlMode.Value == "0")
            {
                this.lstSubTasks.Add(task);

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

                foreach (Task objSubTask in this.lstSubTasks)
                {
                    dtSubtasks.Rows.Add(objSubTask.Title, objSubTask.Description, objSubTask.Status, objSubTask.DueDate, objSubTask.Hours, objSubTask.InstallId, string.Empty, objSubTask.TaskType, objSubTask.Attachment);
                }

                gvSubTasks.DataSource = dtSubtasks;
                gvSubTasks.DataBind();
                upSubTasks.Update();

                //if (this.lstSubTasks.Count > 0)
                //{
                //    this.LastSubTaskSequence = this.lstSubTasks[this.lstSubTasks.Count - 1].InstallId.ToString();
                //}
                if (!string.IsNullOrEmpty(txtTaskListID.Text))
                {
                    this.LastSubTaskSequence = txtTaskListID.Text.Trim();
                }
            }
            else
            {
                // save task master details to database.
                Int64 ItaskId = TaskGeneratorBLL.Instance.SaveOrDeleteTask(task);
                hdnSubTaskId.Value = ItaskId.ToString();
                UploadUserAttachements(null, ItaskId, task.Attachment);
                SetSubTaskDetails(TaskGeneratorBLL.Instance.GetSubTasks(Convert.ToInt32(hdnTaskId.Value), CommonFunction.CheckAdminAndItLeadMode(), string.Empty).Tables[0]);
            }
            hdnAttachments.Value = string.Empty;
            ClearSubTaskData();
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
        private void SaveAssignedTaskUsers(DropDownCheckBoxes ddcbAssigned, JGConstant.TaskStatus objTaskStatus)
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
                        if (objTaskStatus == JGConstant.TaskStatus.Open || objTaskStatus == JGConstant.TaskStatus.Requested)
                        {
                            UpdateTaskStatus(Convert.ToInt32(hdnTaskId.Value), Convert.ToUInt16(JGConstant.TaskStatus.Assigned));
                        }

                        SendEmailToAssignedUsers(Convert.ToInt32(hdnTaskId.Value), strUsersIds);
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

                    SendEmailToAssignedUsers(Convert.ToInt32(hdnTaskId.Value), strUserIDs.TrimEnd(','));
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

                LoadTaskData(hdnTaskId.Value, false);

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

        /// <summary>
        /// send Email
        /// </summary>
        /// <param name="userID"></param>
        private void SendEmail(string Designation, int userID)
        {
            try
            {
                DataSet dsUser = TaskGeneratorBLL.Instance.GetInstallUserDetails(Convert.ToInt32(userID));

                string HTML_TAG_PATTERN = "<.*?>";
                DataSet ds = new DataSet(); //AdminBLL.Instance.GetEmailTemplate("Sales Auto Email");// AdminBLL.Instance.FetchContractTemplate(104);

                ds = AdminBLL.Instance.GetEmailTemplate(Designation);

                if (ds == null)
                {
                    if (Designation.Contains("Install"))
                    {
                        ds = AdminBLL.Instance.GetEmailTemplate("Installer - Helper");// AdminBLL.Instance.FetchContractTemplate(104);
                    }
                    else
                    {
                        ds = AdminBLL.Instance.GetEmailTemplate("SubContractor");// AdminBLL.Instance.FetchContractTemplate(104);
                    }
                }
                else if (ds.Tables[0].Rows.Count == 0)
                {
                    if (Designation.Contains("Install"))
                    {
                        ds = AdminBLL.Instance.GetEmailTemplate("Installer - Helper");// AdminBLL.Instance.FetchContractTemplate(104);
                    }
                    else
                    {
                        ds = AdminBLL.Instance.GetEmailTemplate("SubContractor");// AdminBLL.Instance.FetchContractTemplate(104);
                    }
                }

                string FName = dsUser.Tables[0].Rows[0]["FristName"].ToString();
                string emailId = dsUser.Tables[0].Rows[0]["Email"].ToString();
                string LName = dsUser.Tables[0].Rows[0]["LastName"].ToString();
                string fullname = FName + " " + LName;

                string strHeader = ds.Tables[0].Rows[0]["HTMLHeader"].ToString(); //GetEmailHeader(status);
                string strBody = ds.Tables[0].Rows[0]["HTMLBody"].ToString(); //GetEmailBody(status);
                string strFooter = ds.Tables[0].Rows[0]["HTMLFooter"].ToString(); // GetFooter(status);
                string strsubject = ds.Tables[0].Rows[0]["HTMLSubject"].ToString();

                string userName = ConfigurationManager.AppSettings["VendorCategoryUserName"].ToString();
                string password = ConfigurationManager.AppSettings["VendorCategoryPassword"].ToString();




                strBody = strBody.Replace("#Name#", FName).Replace("#name#", FName);
                /*
                 strBody = strBody.Replace("#Date#", dtInterviewDate.Text).Replace("#date#", dtInterviewDate.Text);
                 strBody = strBody.Replace("#Time#", ddlInsteviewtime.SelectedValue).Replace("#time#", ddlInsteviewtime.SelectedValue);
                  */
                strBody = strBody.Replace("#Designation#", Designation).Replace("#designation#", Designation);


                strFooter = strFooter.Replace("#Name#", FName).Replace("#name#", FName);
                /*
                strFooter = strFooter.Replace("#Date#", dtInterviewDate.Text).Replace("#date#", dtInterviewDate.Text);
                strFooter = strFooter.Replace("#Time#", ddlInsteviewtime.SelectedValue).Replace("#time#", ddlInsteviewtime.SelectedValue);
                 */
                strFooter = strFooter.Replace("#Designation#", Designation).Replace("#designation#", Designation);

                strBody = strBody.Replace("Lbl Full name", fullname);
                strBody = strBody.Replace("LBL position", Designation);
                //strBody = strBody.Replace("lbl: start date", txtHireDate.Text);
                //strBody = strBody.Replace("($ rate","$"+ txtHireDate.Text);
                /*
                strBody = strBody.Replace("Reason", Reason);
                */
                //Hi #lblFName#, <br/><br/>You are requested to appear for an interview on #lblDate# - #lblTime#.<br/><br/>Regards,<br/>
                StringBuilder Body = new StringBuilder();
                MailMessage Msg = new MailMessage();
                //Sender e-mail address.
                Msg.From = new MailAddress(userName, "JGrove Construction");
                //ds = AdminBLL.Instance.GetEmailTemplate('');
                Msg.To.Add(emailId);
                Msg.Bcc.Add(new MailAddress("shabbir.kanchwala@straitapps.com", "Shabbir Kanchwala"));
                Msg.CC.Add(new MailAddress("jgrove.georgegrove@gmail.com", "Justin Grove"));

                Msg.Subject = strsubject;// "JG Prospect Notification";
                Body.Append(strHeader);
                Body.Append(strBody);
                Body.Append(strFooter);
                /*
                if (status == "OfferMade")
                {
                    createForeMenForJobAcceptance(Convert.ToString(Body), FName, LName, Designition, emailId, HireDate, EmpType, PayRates);
                }
                if (status == "Deactive")
                {
                    CreateDeactivationAttachment(Convert.ToString(Body), FName, LName, Designition, emailId, HireDate, EmpType, PayRates);
                }
                 */
                Msg.Body = Convert.ToString(Body);
                Msg.IsBodyHtml = true;
                // your remote SMTP server IP.
                for (int i = 0; i < ds.Tables[1].Rows.Count; i++)
                {
                    string sourceDir = Server.MapPath(ds.Tables[1].Rows[i]["DocumentPath"].ToString());
                    if (File.Exists(sourceDir))
                    {
                        Attachment attachment = new Attachment(sourceDir);
                        attachment.Name = Path.GetFileName(sourceDir);
                        Msg.Attachments.Add(attachment);
                    }
                }
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
                }

                Msg = null;
                sc.Dispose();
                sc = null;

                //  Page.RegisterStartupScript("UserMsg", "<script>alert('An email notification has sent on " + emailId + ".');}</script>");

            }
            catch (Exception ex)
            {
                Console.WriteLine("{0} Exception caught.", ex);
            }
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

        private void SendEmailToAdminUser(int intTaskId, int intTaskCreatedBy)
        {
            try
            {
                if (intTaskCreatedBy > 0)
                {
                    string strHTMLTemplateName = "Task Assignment Requested";
                    DataSet dsEmailTemplate = AdminBLL.Instance.GetEmailTemplate(strHTMLTemplateName, 109);
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

        private void LoadTaskData(string TaskId, Boolean LoadPopup)
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

            String taskPopupTitle = GetTaskPopupTitle(TaskId, dtTaskMasterDetails);

            if (LoadPopup)
            {
                ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(), "open popup", "EditTask(0, \"" + taskPopupTitle + "\");", true);
            }
        }

        private void SetSubTaskSectionView(bool blnView)
        {
            trSubTaskList.Visible = blnView;
        }

        private string GetTaskPopupTitle(String TaskId, DataTable dtTaskMasterDetails)
        {

            StringBuilder taskTitle = new StringBuilder();
            taskTitle.Append("<table width='100%'>");
            taskTitle.Append("<tr>");

            // If its admin then add delete button else not delete button for normal users.
            if (this.IsAdminMode)
            {
                taskTitle.Append(String.Concat("<td width='25%' align='left'><a style='cursor: pointer;' onclick='javascript: RemoveTask(", TaskId, ");'>Delete</a>&nbsp;&nbsp;Task ID#: **ID**</td>"));
            }
            else
            {
                taskTitle.Append("<td width='25%' align='left'>Task ID#: **ID**</td>");
            }

            taskTitle.Append("<td align='center'>Date Created: **CREATED**</td>");
            taskTitle.Append("<td width='25%' align='right'>**MNGR**</td>");
            taskTitle.Append("</tr>");
            taskTitle.Append("</table>");
            taskTitle = taskTitle.Replace("**ID**", dtTaskMasterDetails.Rows[0]["InstallId"].ToString()).Replace("**CREATED**", CommonFunction.FormatDateTimeString(dtTaskMasterDetails.Rows[0]["CreatedOn"]));

            if (dtTaskMasterDetails.Rows[0]["AssigningManager"] != null && !String.IsNullOrEmpty(dtTaskMasterDetails.Rows[0]["AssigningManager"].ToString()))
            {
                taskTitle = taskTitle.Replace("**MNGR**", String.Concat("Created By: ", dtTaskMasterDetails.Rows[0]["AssigningManager"].ToString()));
            }
            else
            {
                taskTitle = taskTitle.Replace("**MNGR**", string.Empty);
            }

            return taskTitle.ToString();
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

        private void SetTaskAssignedUsers(String strAssignedUser, DropDownCheckBoxes taskUsers)
        {
            String firstAssignedUser = String.Empty;
            String[] users = strAssignedUser.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);

            foreach (string user in users)
            {

                ListItem item = taskUsers.Items.FindByText(user);

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
                taskUsers.Texts.SelectBoxCaption = firstAssignedUser;
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
            if (!string.IsNullOrEmpty(Convert.ToString(dtTaskMasterDetails.Rows[0]["attachment"])))
            {
                this.lstTaskUserFiles.AddRange(Convert.ToString(dtTaskMasterDetails.Rows[0]["attachment"]).Split(','));
                intTaskUserFilesCount = lstTaskUserFiles.Count;
                rptWorkFiles.DataSource = lstTaskUserFiles;
                rptWorkFiles.DataBind();
            }
            if (this.IsAdminMode)
            {
                txtTaskTitle.Text = Server.HtmlDecode(dtTaskMasterDetails.Rows[0]["Title"].ToString());
                txtDescription.Text = Server.HtmlDecode(dtTaskMasterDetails.Rows[0]["Description"].ToString());

                SetStatusSelectedValue(cmbStatus, dtTaskMasterDetails.Rows[0]["Status"].ToString());

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

        private void SetStatusSelectedValue(DropDownList ddlStatus, string strValue)
        {
            ddlStatus.ClearSelection();

            ListItem objListItem = ddlStatus.Items.FindByValue(strValue);
            if (objListItem != null)
            {
                //    if (objListItem.Value == Convert.ToByte(JGConstant.TaskStatus.SpecsInProgress).ToString())
                //    {
                //        ddlStatus.Enabled = false;
                //    }
                //    else
                //    {
                ddlStatus.Enabled = true;
                //    }
                objListItem.Enabled = true;
                objListItem.Selected = true;
            }
        }

        #endregion
    }
}