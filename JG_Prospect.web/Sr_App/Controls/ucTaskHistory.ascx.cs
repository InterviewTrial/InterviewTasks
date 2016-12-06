using JG_Prospect.BLL;
using JG_Prospect.Common.modal;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using JG_Prospect.Common;
using Ionic.Zip;
using System.IO;
using System.Data;
using System.Web.UI.HtmlControls;
using JG_Prospect.App_Code;

namespace JG_Prospect.Sr_App.Controls
{
    public partial class ucTaskHistory : System.Web.UI.UserControl
    {
        public delegate void OnLoadTaskData(Int64 intTaskId);

        public OnLoadTaskData LoadTaskData;

        public Int64 TaskId
        {
            get
            {
                if (ViewState["TaskId"] != null)
                {
                    return Convert.ToInt64(ViewState["TaskId"]);
                }
                return 0;
            }
            set
            {
                ViewState["TaskId"] = value;
            }
        }

        public String ucTaskDescription
        {
            get
            {
                return txtTaskDesc.Text.Trim();
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

        protected void Page_Load(object sender, EventArgs e)
        {
            ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
            scriptManager.RegisterPostBackControl(this.gdTaskUsers);
            hdnTaskID.Value = TaskId.ToString();

            if (!IsPostBack)
            {
                String HelpHtml = UtilityBAL.Instance.GetContentSetting(JGConstant.ContentSettings.TASK_HELP_TEXT);
                divHelpText.InnerHtml = Server.HtmlDecode(HelpHtml);
                txtHelpTextEditor.InnerHtml = HelpHtml;

                txtHelpTextEditor.Visible =
                btnSaveHelpText.Visible = CommonFunction.CheckAdminMode();
            }
        }

        protected void linkDownLoadFiles_Click(object sender, EventArgs e)
        {
            LinkButton button = (sender as LinkButton);
            DownLoadFileFromServer(button.CommandName, button.CommandArgument);
        }

        protected void gdTaskUsersNotes_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gdTaskUsersNotes.EditIndex = e.NewEditIndex;
            LoadTaskData(TaskId);
        }

        protected void gdTaskUsersNotes_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            TaskUser taskUser = new TaskUser();

            TextBox note = (TextBox)gdTaskUsersNotes.Rows[e.RowIndex].FindControl("txtNotes");
            Label NoteId = (Label)gdTaskUsersNotes.Rows[e.RowIndex].FindControl("lblNoteId");

            hdnNoteId.Value = NoteId.Text;
            taskUser.Notes = note.Text;
            taskUser.UserId = Convert.ToInt32(Session[SessionKey.Key.UserId.ToString()]);
            taskUser.UserFirstName = Session["Username"].ToString();
            taskUser.Id = Convert.ToInt64(hdnNoteId.Value);
            if (!string.IsNullOrEmpty(taskUser.Notes))
                taskUser.FileType = Convert.ToString((int)JGConstant.TaskUserFileType.Notes);
            taskUser.IsCreatorUser = false;
            taskUser.TaskId = TaskId;
            taskUser.Status = Convert.ToInt16(TaskStatus);
            taskUser.UserAcceptance = UserAcceptance;
            TaskGeneratorBLL.Instance.UpadateTaskNotes(ref taskUser);

            gdTaskUsersNotes.EditIndex = -1;
            LoadTaskData(TaskId);
        }

        protected void gdTaskUsersNotes_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gdTaskUsersNotes.EditIndex = -1;
            LoadTaskData(TaskId);
        }

        protected void gdTaskUsers_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gdTaskUsers.EditIndex = e.NewEditIndex;
            LoadTaskData(TaskId);
        }

        protected void gdTaskUsers_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            TaskUser taskUser = new TaskUser();

            TextBox note = (TextBox)gdTaskUsers.Rows[e.RowIndex].FindControl("txtNotes");
            Label NoteId = (Label)gdTaskUsers.Rows[e.RowIndex].FindControl("lblNoteId");

            hdnNoteId.Value = NoteId.Text;
            taskUser.Notes = note.Text;
            taskUser.UserId = Convert.ToInt32(Session[SessionKey.Key.UserId.ToString()]);
            taskUser.UserFirstName = Session["Username"].ToString();
            taskUser.Id = Convert.ToInt64(hdnNoteId.Value);
            if (!string.IsNullOrEmpty(taskUser.Notes))
                taskUser.FileType = Convert.ToString((int)Common.JGConstant.TaskUserFileType.Notes);
            taskUser.IsCreatorUser = false;
            taskUser.TaskId = Convert.ToInt64(TaskId);
            taskUser.Status = Convert.ToInt16(TaskStatus);
            taskUser.UserAcceptance = UserAcceptance;
            TaskGeneratorBLL.Instance.UpadateTaskNotes(ref taskUser);

            gdTaskUsers.EditIndex = -1;
            LoadTaskData(TaskId);
        }

        protected void gdTaskUsers_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gdTaskUsers.EditIndex = -1;
            LoadTaskData(TaskId);
        }

        public void DownLoadFileFromServer(string fileOrinalName, string fileActualFile)
        {
            Response.Clear();
            Response.AppendHeader("content-disposition", "attachment; filename=" + fileOrinalName);
            Response.ContentType = "application/octet-stream";
            Response.WriteFile(Server.MapPath("~/TaskAttachments/" + fileActualFile));
            Response.Flush();
            Response.End();
            HttpContext.Current.ApplicationInstance.CompleteRequest();
        }

        #region '--Task History--'

        protected void btnAddNote_Click(object sender, EventArgs e)
        {
            string notes = txtNote.Text;

            if (string.IsNullOrEmpty(notes))
                return;

            SaveTaskNotesNAttachments();

            hdnNoteId.Value = "";
        }

        protected void btnUploadLogFiles_Click(object sender, EventArgs e)
        {
            UploadUserAttachements(null, hdnNoteAttachments.Value);
            LoadTaskData(TaskId);
            hdnNoteAttachments.Value = "";
        }

        protected void gdTaskUsers_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                string notes = Convert.ToString(DataBinder.Eval(e.Row.DataItem, "Notes"));
                string filefullName = Convert.ToString(DataBinder.Eval(e.Row.DataItem, "Attachment"));
                string FileType = Convert.ToString(DataBinder.Eval(e.Row.DataItem, "FileType"));
                string AttachmentOriginal = Convert.ToString(DataBinder.Eval(e.Row.DataItem, "AttachmentOriginal"));

                Label labelNotes = (Label)e.Row.FindControl("lblNotes");
                HtmlImage imgFile = (HtmlImage)e.Row.FindControl("imgFile");
                //LinkButton linkOriginalfileName = (LinkButton)e.Row.FindControl("linkOriginalfileName");
                //Label lableOriginalfileName = (Label)e.Row.FindControl("lableOriginalfileName");
                // Button btnEdit = (Button)e.Row.FindControl("ButtonEdit");
                LinkButton linkDownLoadFiles = (LinkButton)e.Row.FindControl("linkDownLoadFiles");



                if (labelNotes != null)
                {
                    if (!string.IsNullOrEmpty(notes))
                    {
                        labelNotes.Visible = true;
                        imgFile.Visible = false;
                        linkDownLoadFiles.Visible = false;
                        // linkOriginalfileName.Visible = false;
                    }
                    else
                    {
                        labelNotes.Visible = false;
                        e.Row.FindControl("divFile").Visible = 
                        imgFile.Visible = true;
                        linkDownLoadFiles.Visible = true;
                        
                        if (Convert.ToString((int)JGConstant.TaskUserFileType.Images) == FileType)
                        {
                            string filePath = String.Concat("~/TaskAttachments/", Server.UrlEncode(filefullName));
                            imgFile.Src = filePath;
                            //linkOriginalfileName.Visible = true;
                            //lableOriginalfileName.Visible = false;
                        }
                        else
                        {
                            string iconFile = string.Empty;

                            // some older data of file table might not have file type.
                            if (CommonFunction.IsImageFile(AttachmentOriginal))
                            {
                                string filePath = String.Concat("~/TaskAttachments/" + Server.UrlEncode(filefullName));
                                imgFile.Src = filePath;
                            }
                            else
                            {
                                imgFile.Src = CommonFunction.GetFileTypeIcon(filefullName);
                            }

                            //linkOriginalfileName.Visible = false;
                            //lableOriginalfileName.Visible = true;
                        }

                        //if (Convert.ToString((int)JGConstant.TaskUserFileType.Images) == FileType)
                        //{
                        //    string filePath = "~/TaskAttachments/" + filefullName;
                        //    imgFile.Src = filePath;
                        //    //linkOriginalfileName.Visible = true;
                        //    //lableOriginalfileName.Visible = false;
                        //}
                        //if (Convert.ToString((int)JGConstant.TaskUserFileType.Docu) == FileType)
                        //{
                        //    string fileExtension = Path.GetExtension(AttachmentOriginal);
                        //    if (fileExtension.ToLower().Equals(".doc") || fileExtension.ToLower().Equals(".docx"))
                        //        imgFile.Src = "~/img/word.jpg";
                        //    else if (fileExtension.ToLower().Equals(".xlx") || fileExtension.ToLower().Equals(".xlsx"))
                        //        imgFile.Src = "~/img/xls.png";
                        //    else if (fileExtension.ToLower().Equals(".pdf"))
                        //        imgFile.Src = "~/img/pdf.jpg";
                        //    else if (fileExtension.ToLower().Equals(".csv"))
                        //        imgFile.Src = "~/img/csv.png";
                        //    else
                        //        imgFile.Src = "~/img/file.jpg";
                        //    //linkOriginalfileName.Visible = false;
                        //    //lableOriginalfileName.Visible = true;
                        //}
                        //if (Convert.ToString((int)JGConstant.TaskUserFileType.Audio) == FileType)
                        //{
                        //    imgFile.Src = "~/img/audio.png";
                        //    //linkOriginalfileName.Visible = true;
                        //    //lableOriginalfileName.Visible = false;
                        //}
                        //if (Convert.ToString((int)JGConstant.TaskUserFileType.Video) == FileType)
                        //{
                        //    imgFile.Src = "~/img/video.png";

                        //   // linkOriginalfileName.Visible = true;
                        //    //lableOriginalfileName.Visible = false;
                        //}
                    }

                    //if (Session[JG_Prospect.Common.SessionKey.Key.usertype.ToString()].ToString() == "Admin" || Session[JG_Prospect.Common.SessionKey.Key.usertype.ToString()].ToString() == "IT Lead")
                    //{
                    //    if (!string.IsNullOrEmpty(notes))
                    //    {
                    //        if (notes.Contains("Task Description :"))
                    //        {
                    //            btnEdit.Visible = false;
                    //        }
                    //        else
                    //        {
                    //            btnEdit.Visible = true;
                    //        }
                    //    }
                    //    else
                    //    {
                    //        btnEdit.Visible = false;
                    //    }
                    //}
                    ScriptManager.GetCurrent(this.Page).RegisterPostBackControl(linkDownLoadFiles);
                }
            }
        }

        protected void gdTaskUsers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "DownLoadFile")
            {
                // Allow download only if files are attached.
                if (!String.IsNullOrEmpty(e.CommandArgument.ToString()))
                {
                    DownloadUserAttachment(e.CommandArgument.ToString());
                }
            }

            if (e.CommandName == "viewFile")
            {
                LinkButton btndetails = (LinkButton)e.CommandSource;
                GridViewRow gvrow = (GridViewRow)btndetails.NamingContainer;
                LinkButton txtAttachment = (LinkButton)gvrow.FindControl("linkOriginalfileName");
                Label FileType = (Label)gvrow.FindControl("lableFileType");
                string fileExtension = Path.GetExtension(txtAttachment.Text);

                imgPreview.ImageUrl = "";
                imgPreview.Visible = false;
                divAudio.Visible = false;
                divVideo.Visible = false;

                if (Convert.ToString((int)JGConstant.TaskUserFileType.Images) == FileType.Text)
                {
                    imgPreview.ImageUrl = "../TaskAttachments/" + txtAttachment.CommandArgument.ToString();
                    imgPreview.Visible = true;
                    divAudio.Visible = false;
                    divVideo.Visible = false;
                }

                if (Convert.ToString((int)JGConstant.TaskUserFileType.Audio) == FileType.Text)
                {
                    imgPreview.Visible = false;
                    divAudio.Visible = true;
                    divVideo.Visible = false;

                    if (fileExtension.ToLower().Equals(".mp3"))
                        audiomp3.Src = "../TaskAttachments/" + txtAttachment.CommandArgument.ToString();

                    if (fileExtension.ToLower().Equals(".mp4"))
                        audiomp4.Src = "../TaskAttachments/" + txtAttachment.CommandArgument.ToString();

                    if (fileExtension.ToLower().Equals(".wma"))
                        audiowma.Src = "../TaskAttachments/" + txtAttachment.CommandArgument.ToString();
                }
                if (Convert.ToString((int)JGConstant.TaskUserFileType.Video) == FileType.Text)
                {
                    imgPreview.Visible = false;
                    divAudio.Visible = false;
                    divVideo.Visible = true;


                    if (fileExtension.ToLower().Equals(".mkv"))
                        videomp4.Src = "../TaskAttachments/" + txtAttachment.CommandArgument.ToString();

                    if (fileExtension.ToLower().Equals(".mp4"))
                        videomp4.Src = "../TaskAttachments/" + txtAttachment.CommandArgument.ToString();

                    if (fileExtension.ToLower().Equals(".3gpp"))
                        video3gpp.Src = "../TaskAttachments/" + txtAttachment.CommandArgument.ToString();

                    if (fileExtension.ToLower().Equals(".mpeg"))
                        videompeg.Src = "../TaskAttachments/" + txtAttachment.CommandArgument.ToString();

                    if (fileExtension.ToLower().Equals(".wmv"))
                        videowmv.Src = "../TaskAttachments/" + txtAttachment.CommandArgument.ToString();

                    if (fileExtension.ToLower().Equals(".webm"))
                        videowebm.Src = "../TaskAttachments/" + txtAttachment.CommandArgument.ToString();

                }
                lblFileName.Text = txtAttachment.Text;

                ScriptManager.RegisterStartupScript(
                                                    (sender as Control),
                                                    this.GetType(),
                                                    "ShowFilePreviewPopup",
                                                    string.Format(
                                                                    "ShowPopup(\"#{0}\");",
                                                                    divFilePreviewPopup.ClientID
                                                                ),
                                                    true
                                              );
            }
        }

        protected void gdTaskUsersNotes_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                string notes = Convert.ToString(DataBinder.Eval(e.Row.DataItem, "Notes"));
                Button btnEdit = (Button)e.Row.FindControl("ButtonEdit");
                //if (Session[JG_Prospect.Common.SessionKey.Key.usertype.ToString()] == "Admin" || Session[JG_Prospect.Common.SessionKey.Key.usertype.ToString()] == "IT Lead")
                //{
                if (btnEdit != null)
                {
                    if (!string.IsNullOrEmpty(notes))
                    {
                        if (notes.Contains("Task Description :"))
                        {
                            btnEdit.Visible = false;
                        }
                        else
                        {
                            btnEdit.Visible = true;
                        }
                    }
                    else
                    {
                        btnEdit.Visible = false;
                    }
                }
                //}
            }
        }

        protected void reapeaterLogImages_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DownLoadFiles")
            {
                //var linkAttachment = e.Item.FindControl("linkOriginalfileName") as LinkButton;

                // Allow download only if files are attached.
                if (!String.IsNullOrEmpty(e.CommandArgument.ToString()))
                {
                    DownloadUserAttachment(e.CommandArgument.ToString());
                }
            }

            if (e.CommandName == "viewFile")
            {
                LinkButton btndetails = (LinkButton)e.CommandSource;

                var linkAttachment = e.Item.FindControl("linkOriginalfileName") as LinkButton;
                var FileType = e.Item.FindControl("lableFileType") as Label;

                lblFileName.Text = linkAttachment.Text;

                ScriptManager.RegisterStartupScript(
                                                    (source as Control),
                                                    this.GetType(),
                                                    "ShowFilePreviewPopup",
                                                    string.Format(
                                                                    "ShowPopup(\"#{0}\");",
                                                                    divFilePreviewPopup.ClientID
                                                                ),
                                                    true
                                              );
            }
        }

        //protected void btnUpdateLogNotes_Click(object sender, EventArgs e)
        //{
        //    LinkButton btnEdit = (LinkButton)sender;
        //    GridViewRow Grow = (GridViewRow)btnEdit.NamingContainer;
        //    Label txtNotesId = (Label)Grow.FindControl("lblNoteId");
        //    Label txtNotes = (Label)Grow.FindControl("lblNotes");

        //    if (!string.IsNullOrEmpty(txtNotes.Text))
        //    {
        //        txtNote.Text = txtNotes.Text;
        //        hdnNoteId.Value = txtNotesId.Text;
        //        btnAddNote.Text = "Update Note";
        //        btnAddNote1.Text = "Update Note";
        //        btnCancelUpdateNote.Visible = true;
        //        btnCancelUpdateNote1.Visible = true;
        //        upTaskHistory.Update();
        //    }

        //    if (this.IsAdminMode)
        //    {
        //        txtNote.Focus();
        //    }
        //    else
        //    {
        //        txtNote1.Focus();
        //    }
        //}

        //protected void btnCancelUpdateNote_Click(object sender, EventArgs e)
        //{
        //    txtNote.Text = "";
        //    hdnNoteId.Value = "";
        //    btnAddNote.Text = "Save Note";
        //    btnAddNote1.Text = "Save Note";
        //    btnCancelUpdateNote.Visible = false;
        //    btnCancelUpdateNote1.Visible = false;
        //    upTaskHistory.Update();
        //}
        #endregion

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
                //Test
                Response.End();
            }
        }

        private void DownloadUserAttachment(String File)
        {
            Response.Clear();
            Response.ContentType = "application/octet-stream";
            Response.AppendHeader("Content-Disposition", String.Concat("attachment; filename=", File));
            Response.WriteFile(Server.MapPath("~/TaskAttachments/" + File));
            Response.Flush();
            Response.End();
        }

        /// <summary>
        /// Save task note and attachment added by user.
        /// </summary>
        private void SaveTaskNotesNAttachments()
        {
            //if task id is available to save its note and attachement.
            if (TaskId > 0)
            {
                // Save task notes and user information, returns TaskUpdateId for reference to add in user attachments.\
                Int32 TaskUpdateId = SaveTaskNote(TaskId, null, null, string.Empty, string.Empty);

                LoadTaskData(TaskId);

                txtNote.Text = string.Empty;
            }
        }

        /// <summary>
        /// Save task user information.
        /// </summary>
        /// <param name="Designame"></param>
        /// <param name="ItaskId"></param>
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

            if (!string.IsNullOrEmpty(hdnNoteId.Value))
                taskUser.Id = Convert.ToInt64(hdnNoteId.Value);
            else
                taskUser.Id = 0;

            if (string.IsNullOrEmpty(taskDescription))
            {
                taskUser.Notes = txtNote.Text;
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

        private void BindTaskUsersNotes(DataTable dt)
        {
            DataTable dttaskNotes = new DataTable();
            DataTable dttaskNotesDoc = new DataTable();
            DataTable dttaskNotesImg = new DataTable();
            DataTable dttaskNotesAudio = new DataTable();
            DataTable dttaskNotesVideo = new DataTable();


            dttaskNotes.Columns.Add("ID");
            dttaskNotes.Columns.Add("FristName");
            dttaskNotes.Columns.Add("LastName");
            dttaskNotes.Columns.Add("UserFirstName");
            dttaskNotes.Columns.Add("UserId");
            dttaskNotes.Columns.Add("UpdatedOn");
            dttaskNotes.Columns.Add("Notes");
            dttaskNotes.Columns.Add("Picture");
            dttaskNotes.Columns.Add("UserInstallId");

            dttaskNotesDoc.Columns.Add("ID");
            dttaskNotesDoc.Columns.Add("FristName");
            dttaskNotesDoc.Columns.Add("LastName");
            dttaskNotesDoc.Columns.Add("UserFirstName");
            dttaskNotesDoc.Columns.Add("UserId");
            dttaskNotesDoc.Columns.Add("Attachment");
            dttaskNotesDoc.Columns.Add("AttachmentOriginal");
            dttaskNotesDoc.Columns.Add("UpdatedOn");
            dttaskNotesDoc.Columns.Add("FileType");
            dttaskNotesDoc.Columns.Add("FilePath");
            dttaskNotesDoc.Columns.Add("Picture");
            dttaskNotesDoc.Columns.Add("UserInstallId");

            dttaskNotesImg.Columns.Add("ID");
            dttaskNotesImg.Columns.Add("FristName");
            dttaskNotesImg.Columns.Add("LastName");
            dttaskNotesImg.Columns.Add("UserFirstName");
            dttaskNotesImg.Columns.Add("UserId");
            dttaskNotesImg.Columns.Add("Attachment");
            dttaskNotesImg.Columns.Add("AttachmentOriginal");
            dttaskNotesImg.Columns.Add("UpdatedOn");
            dttaskNotesImg.Columns.Add("FileType");
            dttaskNotesImg.Columns.Add("FilePath");
            dttaskNotesImg.Columns.Add("Picture");

            dttaskNotesAudio.Columns.Add("ID");
            dttaskNotesAudio.Columns.Add("FristName");
            dttaskNotesAudio.Columns.Add("LastName");
            dttaskNotesAudio.Columns.Add("UserFirstName");
            dttaskNotesAudio.Columns.Add("UserId");
            dttaskNotesAudio.Columns.Add("Attachment");
            dttaskNotesAudio.Columns.Add("AttachmentOriginal");
            dttaskNotesAudio.Columns.Add("UpdatedOn");
            dttaskNotesAudio.Columns.Add("FileType");
            dttaskNotesAudio.Columns.Add("FilePath");
            dttaskNotesAudio.Columns.Add("Picture");

            dttaskNotesVideo.Columns.Add("ID");
            dttaskNotesVideo.Columns.Add("FristName");
            dttaskNotesVideo.Columns.Add("LastName");
            dttaskNotesVideo.Columns.Add("UserFirstName");
            dttaskNotesVideo.Columns.Add("UserId");
            dttaskNotesVideo.Columns.Add("Attachment");
            dttaskNotesVideo.Columns.Add("AttachmentOriginal");
            dttaskNotesVideo.Columns.Add("UpdatedOn");
            dttaskNotesVideo.Columns.Add("FileType");
            dttaskNotesVideo.Columns.Add("FilePath");
            dttaskNotesVideo.Columns.Add("Picture");


            for (int i = 0; i < dt.Rows.Count; i++)
            {
                string fileExtension = Path.GetExtension(Convert.ToString(dt.Rows[i]["AttachmentOriginal"]));
                string FilePath = string.Empty;

                if (string.IsNullOrEmpty(Convert.ToString(dt.Rows[i]["FileType"])))
                {
                    dttaskNotes.Rows.Add(dt.Rows[i]["ID"],
                        Convert.ToString(dt.Rows[i]["FristName"]),
                        Convert.ToString(dt.Rows[i]["LastName"]),
                        Convert.ToString(dt.Rows[i]["UserFirstName"]),
                        Convert.ToString(dt.Rows[i]["UserId"]),
                        Convert.ToString(dt.Rows[i]["UpdatedOn"]),
                        Convert.ToString(dt.Rows[i]["Notes"]),
                        Convert.ToString(dt.Rows[i]["Picture"]),
                        Convert.ToString(dt.Rows[i]["UserInstallId"]));
                }
                if (Convert.ToString(dt.Rows[i]["FileType"]) == Convert.ToString((int)JGConstant.TaskUserFileType.Docu))
                {
                    if (fileExtension.ToLower().Equals(".doc") || fileExtension.ToLower().Equals(".docx"))
                        FilePath = "../img/word.jpg";
                    else if (fileExtension.ToLower().Equals(".xlx") || fileExtension.ToLower().Equals(".xlsx"))
                        FilePath = "../img/xls.png";
                    else if (fileExtension.ToLower().Equals(".pdf"))
                        FilePath = "../img/pdf.jpg";
                    else if (fileExtension.ToLower().Equals(".csv"))
                        FilePath = "../img/csv.png";

                    dttaskNotesDoc.Rows.Add(dt.Rows[i]["ID"],
                                            Convert.ToString(dt.Rows[i]["FristName"]),
                                            Convert.ToString(dt.Rows[i]["LastName"]),
                                            Convert.ToString(dt.Rows[i]["UserFirstName"]),
                                            Convert.ToString(dt.Rows[i]["UserId"]),
                                            Convert.ToString(dt.Rows[i]["Attachment"]),
                                            Convert.ToString(dt.Rows[i]["AttachmentOriginal"]),
                                            Convert.ToString(dt.Rows[i]["UpdatedOn"]),
                                            Convert.ToString(dt.Rows[i]["FileType"]),
                                            Convert.ToString(FilePath),
                                            Convert.ToString(dt.Rows[i]["Picture"]),
                                            Convert.ToString(dt.Rows[i]["UserInstallId"]));
                }
                if (Convert.ToString(dt.Rows[i]["FileType"]) == Convert.ToString((int)JGConstant.TaskUserFileType.Images))
                {
                    if (fileExtension.ToLower().Equals(".png") || fileExtension.ToLower().Equals(".jpg") || fileExtension.ToLower().Equals(".jpeg"))
                    {
                        FilePath = "../TaskAttachments/" + dt.Rows[i]["Attachment"];
                        dttaskNotesImg.Rows.Add(dt.Rows[i]["ID"],
                                               Convert.ToString(dt.Rows[i]["FristName"]),
                                               Convert.ToString(dt.Rows[i]["LastName"]),
                                               Convert.ToString(dt.Rows[i]["UserFirstName"]),
                                               Convert.ToString(dt.Rows[i]["UserId"]),
                                               Convert.ToString(dt.Rows[i]["Attachment"]),
                                               Convert.ToString(dt.Rows[i]["AttachmentOriginal"]),
                                               Convert.ToString(dt.Rows[i]["UpdatedOn"]),
                                               Convert.ToString(dt.Rows[i]["FileType"]),
                                               Convert.ToString(FilePath),
                                               Convert.ToString(dt.Rows[i]["Picture"]));
                    }
                }

                if (Convert.ToString(dt.Rows[i]["FileType"]) == Convert.ToString((int)JGConstant.TaskUserFileType.Video))
                {
                    if (fileExtension.ToLower().Equals(".mp3") || fileExtension.ToLower().Equals(".mp4")
                   || fileExtension.ToLower().Equals(".mkv") || fileExtension.ToLower().Equals(".3gpp")
                    || fileExtension.ToLower().Equals(".mpeg") || fileExtension.ToLower().Equals(".wmv")
                    || fileExtension.ToLower().Equals(".webm"))
                    {
                        FilePath = "../img/video.png"; /*"../img/audio.png";*/
                        dttaskNotesVideo.Rows.Add(dt.Rows[i]["ID"],
                                               Convert.ToString(dt.Rows[i]["FristName"]),
                                               Convert.ToString(dt.Rows[i]["LastName"]),
                                               Convert.ToString(dt.Rows[i]["UserFirstName"]),
                                               Convert.ToString(dt.Rows[i]["UserId"]),
                                               Convert.ToString(dt.Rows[i]["Attachment"]),
                                               Convert.ToString(dt.Rows[i]["AttachmentOriginal"]),
                                               Convert.ToString(dt.Rows[i]["UpdatedOn"]),
                                               Convert.ToString(dt.Rows[i]["FileType"]),
                                               Convert.ToString(FilePath),
                                               Convert.ToString(dt.Rows[i]["Picture"]));
                    }
                }


                if (Convert.ToString(dt.Rows[i]["FileType"]) == Convert.ToString((int)JGConstant.TaskUserFileType.Audio))
                {
                    if (fileExtension.Equals(".mp3") || fileExtension.Equals(".mp4")
                      || fileExtension.Equals(".wma"))
                    {
                        FilePath = "../img/audio.png"; /*"../img/audio.png";*/
                        dttaskNotesAudio.Rows.Add(dt.Rows[i]["ID"],
                                               Convert.ToString(dt.Rows[i]["FristName"]),
                                               Convert.ToString(dt.Rows[i]["LastName"]),
                                               Convert.ToString(dt.Rows[i]["UserFirstName"]),
                                               Convert.ToString(dt.Rows[i]["UserId"]),
                                               Convert.ToString(dt.Rows[i]["Attachment"]),
                                               Convert.ToString(dt.Rows[i]["AttachmentOriginal"]),
                                               Convert.ToString(dt.Rows[i]["UpdatedOn"]),
                                               Convert.ToString(dt.Rows[i]["FileType"]),
                                               Convert.ToString(FilePath),
                                               Convert.ToString(dt.Rows[i]["Picture"]));
                    }
                }
            }

            gdTaskUsersNotes.DataSource = dttaskNotes;
            gdTaskUsersNotes.DataBind();
            dttaskNotes.Clear();

            reapeaterLogDoc.DataSource = dttaskNotesDoc;
            reapeaterLogDoc.DataBind();
            dttaskNotesDoc.Clear();

            reapeaterLogImages.DataSource = dttaskNotesImg;
            reapeaterLogImages.DataBind();
            dttaskNotesImg.Clear();

            reapeaterLogVideoc.DataSource = dttaskNotesVideo;
            reapeaterLogVideoc.DataBind();
            dttaskNotesVideo.Clear();

            reapeaterLogAudio.DataSource = dttaskNotesAudio;
            reapeaterLogAudio.DataBind();
            dttaskNotesAudio.Clear();

            upTaskHistory.Update();

        }

        public void SetTaskUserNNotesDetails(DataTable dtTaskUserDetails, String TaskDesc)
        {
            for (int i = 0; i < dtTaskUserDetails.Rows.Count; i++)
            {
                dtTaskUserDetails.Rows[i]["Notes"] = dtTaskUserDetails.Rows[i]["Notes"].ToString().Replace("-", "");
            }

            if (TaskId > 0)
            {
                txtTaskDesc.Visible = false;
                rfvDesc.Visible = false;
                ltlTaskDesc.Text = TaskDesc;
            }

            BindTaskUsersNotes(dtTaskUserDetails);

            gdTaskUsers.DataSource = dtTaskUserDetails;
            gdTaskUsers.DataBind();
            upTaskUsers.Update();
        }

        protected void btnSaveDesc_Click(object sender, EventArgs e)
        {
            if (TaskId > 0 && !String.IsNullOrEmpty(txtTaskDesc.Text))
            {
                TaskGeneratorBLL.Instance.SaveTaskDescription(TaskId, txtTaskDesc.Text);
            }


        }

        protected void reapeaterLogDoc_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                Image imgDoc = (Image)e.Item.FindControl("imgDoc");

                imgDoc.ImageUrl = CommonFunction.GetFileTypeIcon(DataBinder.Eval(e.Item.DataItem, "Attachment").ToString());

            }
        }

        protected void reapeaterLogAudio_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                Image imgImages = (Image)e.Item.FindControl("imgImages");

                imgImages.ImageUrl = CommonFunction.GetFileTypeIcon(DataBinder.Eval(e.Item.DataItem, "Attachment").ToString());

            }
        }

        protected void reapeaterLogVideoc_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                Image imgImages = (Image)e.Item.FindControl("imgImages");

                imgImages.ImageUrl = CommonFunction.GetFileTypeIcon(DataBinder.Eval(e.Item.DataItem, "Attachment").ToString());

            }
        }

        protected void btnSaveHelpText_Click(object sender, EventArgs e)
        {
            UtilityBAL.Instance.UpdateContentSetting(JGConstant.ContentSettings.TASK_HELP_TEXT, HttpUtility.HtmlEncode(txtHelpTextEditor.InnerText));

            divHelpText.InnerHtml = Server.HtmlDecode(txtHelpTextEditor.InnerHtml);

            upTaskHelpText.Update();
        }
    }
}