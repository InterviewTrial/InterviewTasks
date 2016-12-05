#region '--Using--'

using JG_Prospect.BLL;
using System;
using System.Data;
using JG_Prospect.Common.modal;
using JG_Prospect.Common;
using System.Web.UI;
using System.IO;

#endregion

namespace JG_Prospect.Sr_App.Controls
{
    public partial class ucTaskWorkSpecifications : System.Web.UI.UserControl
    {
        #region '--Members--'


        #endregion

        #region '--Properties--'

        public Int32 TaskId
        {
            get
            {
                if (ViewState["TaskId"] == null)
                    return 0;
                return Convert.ToInt32(ViewState["TaskId"]);
            }
            set
            {
                ViewState["TaskId"] = value;
            }
        }

        public bool IsAdminAndItLeadMode
        {
            get
            {
                if (ViewState["IsAdminAndItLeadMode"] == null)
                    return false;
                return Convert.ToBoolean(ViewState["IsAdminAndItLeadMode"]);
            }
            set
            {
                ViewState["IsAdminAndItLeadMode"] = value;
            }
        }

        /// <summary>
        /// Set control view mode.
        /// </summary>
        public bool IsAdminMode
        {
            get
            {
                if (ViewState["IsAdminMode"] == null)
                    return false;
                return Convert.ToBoolean(ViewState["IsAdminMode"]);
            }
            set
            {
                ViewState["IsAdminMode"] = value;
            }
        }

        public JGConstant.TaskStatus TaskStatus
        {
            get;
            set;
        }

        public bool UserAcceptance
        {
            get;
            set;
        }

        #endregion

        #region '--Page Events--'

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        #endregion

        #region '--Control Events--'

        protected void btnUpdateTaskStatus_Click(object sender, EventArgs e)
        {
            DataSet dsTaskSpecificationStatus = TaskGeneratorBLL.Instance.GetPendingTaskWorkSpecificationCount(TaskId);

            Task objTask = new Task();
            objTask.TaskId = TaskId;

            // change status only after freezing all specifications.
            // this will change disabled "specs in progress" status to open on feezing.
            if (
                Convert.ToInt32(dsTaskSpecificationStatus.Tables[0].Rows[0]["TotalRecordCount"]) == 0 ||
                Convert.ToInt32(dsTaskSpecificationStatus.Tables[1].Rows[0]["PendingRecordCount"]) > 0
               )
            {
                objTask.Status = Convert.ToByte(JGConstant.TaskStatus.SpecsInProgress);
            }
            else
            {
                objTask.Status = Convert.ToByte(JGConstant.TaskStatus.Open);
            }

            TaskGeneratorBLL.Instance.UpdateTaskStatus(objTask);
        }

        protected void btnShowFeedbackPopup_Click(object sender, EventArgs e)
        {
            //ltrlTwsFeedbackTitle.Text = "Sub Task : " + gvSubTasks.DataKeys[Convert.ToInt32(e.CommandArgument)]["InstallId"].ToString();

            if (this.IsAdminMode)
            {
                tblAddEditTwsFeedback.Visible = true;
            }
            else
            {
                tblAddEditTwsFeedback.Visible = false;
            }
            upTwsFeedbackPopup.Update();
            ScriptManager.RegisterStartupScript(
                                                this.Page,
                                                this.Page.GetType(),
                                                "ShowPopup",
                                                string.Format(
                                                                "ShowPopup(\"#{0}\");",
                                                                divTwsFeedbackPopup.ClientID
                                                            ),
                                                true
                                          );
        }

        protected void btnSaveTwsFeedback_Click(object sender, EventArgs e)
        {
            string notes = txtTwsComment.Text;

            if (string.IsNullOrEmpty(notes))
                return;

            SaveTaskNotesNAttachments();

            ScriptManager.RegisterStartupScript(
                                                   (sender as Control),
                                                   this.GetType(),
                                                   "HidePopup",
                                                   string.Format(
                                                                   "HidePopup(\"#{0}\");",
                                                                   divTwsFeedbackPopup.ClientID
                                                               ),
                                                   true
                                             );

            //Response.Redirect("~/Sr_App/TaskGenerator.aspx?TaskId=" + TaskId.ToString());

        }

        protected void btnSaveTwsAttachment_Click(object sender, EventArgs e)
        {
            UploadUserAttachements(null, hdnTwsAttachments.Value);

            hdnTwsAttachments.Value = "";

            //Response.Redirect("~/Sr_App/TaskGenerator.aspx?TaskId=" + TaskId.ToString());

        }

        #endregion

        #region '--Methods--'

        protected string GetPasswordPlaceholder()
        {
            string strPlaceholder = string.Empty;
            if (Session["DesigNew"].ToString().ToUpper().Equals("ADMIN"))
            {
                strPlaceholder = "Admin Password";
            }
            else if (Session["DesigNew"].ToString().ToUpper().Equals("ITLEAD"))
            {
                strPlaceholder = "IT Lead Password";
            }
            else
            {
                strPlaceholder = "User Password";
            }
            return strPlaceholder;
        }

        protected string GetPasswordCheckBoxChangeEvent(bool blAdmin, bool blITLead, bool blUser)
        {
            string strOnChange = "javascript: return false;";
            if (Session["DesigNew"].ToString().ToUpper().Equals("ADMIN"))
            {
                if (blAdmin)
                {
                    strOnChange = "javascript: OnApprovalCheckBoxChanged(this);";
                }
            }
            else if (Session["DesigNew"].ToString().ToUpper().Equals("ITLEAD"))
            {
                if (blITLead)
                {
                    strOnChange = "javascript: OnApprovalCheckBoxChanged(this);";
                }
            }
            else if (blUser)
            {
                strOnChange = "javascript: OnApprovalCheckBoxChanged(this);";
            }
            return strOnChange;
        }

        private void UploadUserAttachements(int? taskUpdateId, string attachments)
        {
            //User has attached file than save it to database.
            if (!string.IsNullOrEmpty(attachments))
            {
                TaskUser taskUserFiles = new TaskUser();

                string[] files = attachments.Split(new char[] { '^' }, StringSplitOptions.RemoveEmptyEntries);

                foreach (String attachment in files)
                {
                    String[] attachements = attachment.Split('@');
                    string fileExtension = Path.GetExtension(attachment);

                    if (
                        fileExtension.ToLower() == ".mpeg" ||
                        fileExtension.ToLower() == ".mp4" ||
                        fileExtension.ToLower() == ".3gpp" ||
                        fileExtension.ToLower() == ".wmv" ||
                        fileExtension.ToLower() == ".mkv"
                       )
                    {

                        taskUserFiles.FileType = Convert.ToString((int)JGConstant.TaskUserFileType.Video);
                    }
                    else if (
                         fileExtension.ToLower() == ".mp3" ||
                         fileExtension.ToLower() == ".mp4" ||
                         fileExtension.ToLower() == ".wma"
                        )
                    {
                        taskUserFiles.FileType = Convert.ToString((int)JGConstant.TaskUserFileType.Audio);
                    }
                    else if (
                         fileExtension.ToLower() == ".jpg" ||
                         fileExtension.ToLower() == ".jpeg" ||
                         fileExtension.ToLower() == ".png"
                        )
                    {
                        taskUserFiles.FileType = Convert.ToString((int)JGConstant.TaskUserFileType.Images);
                    }
                    else if (
                         fileExtension.ToLower() == ".doc" ||
                         fileExtension.ToLower() == ".docx" ||
                         fileExtension.ToLower() == ".xlx" ||
                         fileExtension.ToLower() == ".xlsx" ||
                         fileExtension.ToLower() == ".pdf" ||
                         fileExtension.ToLower() == ".txt" ||
                         fileExtension.ToLower() == ".csv"
                        )
                    {
                        taskUserFiles.FileType = Convert.ToString((int)JGConstant.TaskUserFileType.Docu);
                    }
                    taskUserFiles.Attachment = attachements[0];
                    taskUserFiles.OriginalFileName = attachements[1];
                    taskUserFiles.Mode = 0; // insert data.
                    taskUserFiles.TaskId = TaskId;
                    taskUserFiles.UserId = Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
                    taskUserFiles.TaskUpdateId = taskUpdateId;
                    taskUserFiles.UserType = JGSession.IsInstallUser ?? false;
                    TaskGeneratorBLL.Instance.SaveOrDeleteTaskUserFiles(taskUserFiles);  // save task files
                }
            }
        }

        private void SaveTaskNotesNAttachments()
        {
            //if task id is available to save its note and attachement.
            if (TaskId > 0)
            {
                // Save task notes and user information, returns TaskUpdateId for reference to add in user attachments.\
                Int32 TaskUpdateId = SaveTaskNote(TaskId, null, null, string.Empty, string.Empty);

                txtTwsComment.Text = string.Empty;
            }
        }

        public Int32 SaveTaskNote(long ItaskId, Boolean? IsCreated, Int32? UserId, String UserName, String taskDescription)
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


            taskUser.Id = 0;

            if (string.IsNullOrEmpty(taskDescription))
            {
                taskUser.Notes = txtTwsComment.Text;
            }
            else
            {
                taskUser.Notes = taskDescription;
            }

            if (!string.IsNullOrEmpty(taskUser.Notes))
            {
                taskUser.FileType = Convert.ToString((int)JGConstant.TaskUserFileType.Notes);
            }

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

            taskUser.Status = Convert.ToInt16(TaskStatus);

            taskUser.UserAcceptance = UserAcceptance;

            taskUser.TaskFileDestination = JGConstant.TaskFileDestination.WorkSpecification;

            if (taskUser.Id == 0)
            {
                TaskGeneratorBLL.Instance.SaveOrDeleteTaskNotes(ref taskUser);
                TaskUpdateId = Convert.ToInt32(taskUser.TaskUpdateId);
            }
            else
            {
                TaskGeneratorBLL.Instance.UpadateTaskNotes(ref taskUser);
            }


            return TaskUpdateId;
        }

        #endregion
    }
}