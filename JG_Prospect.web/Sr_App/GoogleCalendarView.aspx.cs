using JG_Prospect.BLL;
using JG_Prospect.Common.modal;
//using Microsoft.Office.Interop.Excel;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net.Mail;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web.UI;
using JG_Prospect.App_Code;
using JG_Prospect.Common;
using System.Data.Common;
using JG_Prospect.DAL.Database;
using Microsoft.Practices.EnterpriseLibrary.Data.Sql;

namespace JG_Prospect.Sr_App
{
    public partial class GoogleCalendarView : System.Web.UI.Page
    {
        #region '--Members--'

        string strcon = ConfigurationManager.ConnectionStrings["JGPA"].ConnectionString;
        SqlConnection con = null;
        SqlCommand cmd = null;
        SqlDataAdapter da = null;
        DataSet ds = null;
        static string query = "";
        static string Admin = "Admin", usertType = "";

        #endregion

        #region '--Properties--'

        #endregion

        #region '--Page Events--'

        protected void Page_Load(object sender, EventArgs e)
        {
            RadWindow2.VisibleOnPageLoad = false ;
            if (!IsPostBack)
            {
                //Hide Insert,Edit Delete.....
                rsAppointments.AllowInsert = false;
                rsAppointments.AllowEdit = false;
                rsAppointments.AllowDelete = false;


                // BindGoogleMap();
                if (Session["usertype"] != null)
                {
                    usertType = Convert.ToString(Session["usertype"]);

                    if (usertType == Admin)
                    {
                        btnAddEvent.Visible = true;
                        //A4.Visible = false;
                        //  Response.Redirect("/home.aspx");
                    }
                    else if (Session["loginid"] != null)
                    {

                    }
                }
                Session["AppType"] = "SrApp";
                //LoadCalendar();


                //----- Start DP ------
                FillMyCalendarDropDown();
                BindEventCalendar();
                //------ End DP -----
                
            }

        }

        #endregion

        #region '--Control Events--'

        protected void drpMyCalendar_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindEventByCalendar(Convert.ToInt32(drpMyCalendar.SelectedValue));
        }

        protected void lbtCustomerID_Click(object sender, EventArgs e)
        {
            //Redirect to customer profile page....
            ScriptManager.RegisterStartupScript(Page, GetType(), "script1", "YetToDeveloped();", true);
            // Response.Redirect(lbtCustomerID.Text);
        }

        protected void btnsave_Click(object sender, EventArgs e)
        {
            //AnnualEvent a = new AnnualEvent();
            //a.EventName = txtEventName.Text;
            //a.Eventdate = txtHolidayDate.Text;
            //a.id = Convert.ToInt32(lbtCustomerID.Text);
            //new_customerBLL.Instance.UpdateAnnualEvent(a);
            //BindCalendar();

            //int userId = Convert.ToInt16(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
            //ScriptManager.RegisterStartupScript(this.Page, GetType(), "al", "alert('Event Updated Successfully');", true);
            //RadWindow2.VisibleOnPageLoad = false;
            ///*
            //            try
            //            { 
            //                //Adding Record to Database through Stored Procedure
            //                con = new SqlConnection(strcon);
            //                cmd = new SqlCommand("UpdateAnnualEvent", con);
            //                cmd.CommandType = CommandType.StoredProcedure;


            //                cmd.Parameters.AddWithValue("@Eventname", txtEventName.Text);
            //                cmd.Parameters.AddWithValue("@EventDate", txtHolidayDate.Text);
            //                cmd.Parameters.AddWithValue("@ID", lbtCustomerID.Text);
                
            //                con.Open();
            //                cmd.ExecuteNonQuery();
            //                con.Close();

            //                BindCalendar();
            //                //Clear All Data after submitting.....               
            //                ScriptManager.RegisterStartupScript(this.Page, GetType(), "al", "alert('Event Updated Successfully');", true);
            //                RadWindow2.VisibleOnPageLoad = false;
            //            }

            //            catch
            //            {
            //                //return 0;
            //                //LogManager.Instance.WriteToFlatFile(ex);
            //            }
            //           */

        }

        protected void btnClose_Click(object sender, EventArgs e)
        {
            RadWindow2.VisibleOnPageLoad = false;
        }

        protected void btnCreateEvent_Click(object sender, EventArgs e)
        {
            mpEvents.Show();
        }


        protected void btnCreateCal_Click(object sender, EventArgs e)
        {
            mpCalendar.Show();
        }


        protected void btnCalClose_Click(object sender, EventArgs e)
        {
            mpCalendar.Hide();
        }
        protected void btnAddCalendar_Click(object sender, EventArgs e)
        {
            EventCalendar a = new EventCalendar();
            a.CalendarName = txtCalName.Text;
            a.InsertionDate = DateTime.Now.Date.ToString("dd-MMM-yyyy");
            //For checking duplicate calendar name....
            DataSet ds = new DataSet();
            ds = new_customerBLL.Instance.CheckDuplicateCalendarEvent(a);
            if (ds.Tables[0].Rows.Count == 0)
            {
                int userId = Convert.ToInt16(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
                a.UserId = userId;
              
                // -------- insert record  ----------
                new_customerBLL.Instance.AddEventCalendar(a);
                FillMyCalendarDropDown();
                ScriptManager.RegisterStartupScript(this.Page, GetType(), "al", "alert('Calendar Added Successfully');", true);
            }
            else
            {
                //If duplicate Calendar......
                ScriptManager.RegisterStartupScript(this.Page, GetType(), "al", "alert('Calendar Name is already exist');", true);
            }
        }
        protected void btnEventSubmit_Click(object sender, EventArgs e)
        {
            string NewImageName="";
            AnnualEvent a = new AnnualEvent();
            a.EventName = txtEventName.Text;
            a.Eventdate = txtEventStartDate.Text;
            a.EventEndDate = txtEventEndDate.Text;
            a.EventStartTime = txtEventStartTime.Text;
            if (txtEventEndTime.Text == "") {
                a.EventEndTime ="";
            }else{
                a.EventEndTime = txtEventEndTime.Text;
            }
            a.EventFile = "";
            a.EventLoc = txtEventLoc.Text;
            a.EventDesc = txtEventDesc.Text;
            a.EventCal = Convert.ToInt32(drpEventCalender.SelectedValue);
            a.EventColor = txtEventColor.Value ;
            if (rdoRepeatEvent.SelectedValue == "")
            {
                a.EventRepeat = 0;
            }
            else
            {
                a.EventRepeat = Convert.ToInt32(rdoRepeatEvent.SelectedValue);
            }
            if (chkEventType.SelectedValue == "")
            {
                a.EventType = 0;
            }
            else
            {
                a.EventType = Convert.ToInt32(chkEventType.SelectedValue);
            }

            string strInviteUsers = txtinvite.Value;

            //For checking duplicate event....
            DataSet ds = new DataSet();
            ds = new_customerBLL.Instance.CheckDuplicateAnnualEvent(a);
            if (ds.Tables[0].Rows.Count == 0)
            {
                int userId = Convert.ToInt16(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
                a.EventAddedBy = userId;

                try
                {
                    int vMAxEventId = 0;
                    if (flEventFile.HasFile)
                    {
                        // to check file extension
                        //if (FileUploadControl.PostedFile.ContentType == "image/jpeg")
                        // { }

                        DataSet result = new DataSet();
                        try
                        {
                            SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                            {
                                DbCommand command = database.GetStoredProcCommand("GetMaxNo");
                                command.CommandType = CommandType.StoredProcedure;
                                database.AddInParameter(command, "@colname", DbType.String, "ID");
                                database.AddInParameter(command, "@tblname", DbType.String, "tbl_AnnualEvents");
                                result = database.ExecuteDataSet(command);
                            }
                        }
                        catch (Exception ex)
                        {
                            //LogManager.Instance.WriteToFlatFile(ex);
                        }
                        if(result.Tables[0].Rows.Count>0)
                        {
                            vMAxEventId = Convert.ToInt32(result.Tables[0].Rows[0]["maxno"].ToString()) + 1;
                        }
                        result.Dispose();

                        var originalDirectory = new DirectoryInfo(Server.MapPath(JGConstant.EventCalendar_Upload_Folder));

                        string imageName = Path.GetFileName(flEventFile.FileName);
                        NewImageName =vMAxEventId+"_"+ userId + "_"+imageName;
                        a.EventFile = NewImageName;

                        //string NewImageName = Guid.NewGuid() + "-" + imageName;

                        string pathString = System.IO.Path.Combine(originalDirectory.ToString(), NewImageName);
                        bool isExists = System.IO.Directory.Exists(originalDirectory.ToString());

                        if (!isExists)
                            System.IO.Directory.CreateDirectory(originalDirectory.ToString());

                        flEventFile.SaveAs(pathString);
                    }
                }
                catch (Exception ex)
                {
                    // error
                }

                // -------- insert record  ----------
                try
                {
                    new_customerBLL.Instance.AddAnnualEvent(a);
                   
                    // send an email to invites
                    string strbody = "";
                    strbody = strbody + "<p class='MsoNormal'><span style='font-size: 13.3333px;'>Dear User,On behalf of JMGrove Construction &amp; Supply LLC, I would like to invite you for this Event.</span></p>";
                    strbody = strbody + " <p class='MsoNormal'><span style='font-size: 13.3333px;'><br /></span></p> ";
                    strbody = strbody + " <p class='MsoNormal'><span style='font-size: 13.3333px;'>If you have any questions please contact the HR department at</span></p> ";
                    strbody = strbody + " <p class='MsoNormal'><span style='font-size: 13.3333px;'>hr@jmgroveconstructions.com</span></p> ";
                    strbody = strbody + "  <p class='MsoNormal' style='font-size: 13.3333px;'><br /></p> ";

                    string strHeader = " <div style='font-size: 13.3333px;'><img src='http://web.jmgrovebuildingsupply.com/CustomerDocs/DefaultEmailContents/header.jpg' /></div>";
                    strHeader = strHeader + "<div style='font-size: 13.3333px;'><img src='http://web.jmgrovebuildingsupply.com/CustomerDocs/DefaultEmailContents/logo.gif' /></div>";

                    string strFooter = "";
                    strFooter = strFooter + " <br />";
                    strFooter = strFooter + " <div> ";
                    strFooter = strFooter + " <p style='font-size: 13.3333px;'>J.M. Grove - Construction &amp; Supply&nbsp;<br /> ";
                    strFooter = strFooter + " <a href='http://web.jmgrovebuildingsupply.com/Sr_App/jmgroveconstruction.com'>jmgroveconstruction.com&nbsp;</a><br /> ";
                    strFooter = strFooter + " <a href='http://jmgrovebuildingsupply.com/'>http://jmgrovebuildingsupply.com/</a><br />";
                    strFooter = strFooter + " <a href='http://web.jmgrovebuildingsupply.com/login.aspx'>http://web.jmgrovebuildingsupply.com/login.aspx</a><br />";
                    strFooter = strFooter + " <a href='http://jmgroverealestate.com/'>http://jmgroverealestate.com/</a><br />";
                    strFooter = strFooter + " <br />";
                    strFooter = strFooter + " 72 E Lancaster Ave<br />";
                    strFooter = strFooter + " Malvern, Pa 19355<br />";
                    strFooter = strFooter + " Human Resources<br />";
                    strFooter = strFooter + " Office:(215) 274-5182 Ext. 4<br />";
                    strFooter = strFooter + " <a href='mailto:Hr@jmgroveconstruction.com'>Hr@jmgroveconstruction.com</a></p> ";
                    strFooter = strFooter + " <div style='font-size: 13.3333px;'><a href='https://www.facebook.com/JMGrove1com/'><img src='http://web.jmgrovebuildingsupply.com/CustomerDocs/DefaultEmailContents/fb.png' /></a><a href='http://s49.photobucket.com/user/jmg1/media/twitter_zpsiiplyhiq.png.html'><img src='http://web.jmgrovebuildingsupply.com/CustomerDocs/DefaultEmailContents/tw.png' /></a><a href='http://s49.photobucket.com/user/jmg1/media/236e0d0b-832c-4543-81a6-f6c460d302f0_zpsl4nh3ane.png.html'><img src='http://web.jmgrovebuildingsupply.com/CustomerDocs/DefaultEmailContents/gpls.png' /></a><a href='http://s49.photobucket.com/user/jmg1/media/pinterest_zpspioq6pve.png.html'><img src='http://web.jmgrovebuildingsupply.com/CustomerDocs/DefaultEmailContents/pint.png' /></a><br />";
                    strFooter = strFooter + " <a href='http://s49.photobucket.com/user/jmg1/media/twitter_zpsiiplyhiq.png.html'><img src='http://web.jmgrovebuildingsupply.com/CustomerDocs/DefaultEmailContents/hbt.png' /></a><a href='http://s49.photobucket.com/user/jmg1/media/youtube_zpsxyhfmm1b.png.html'><img src='http://web.jmgrovebuildingsupply.com/CustomerDocs/DefaultEmailContents/yt.png' /></a><a href='http://s49.photobucket.com/user/jmg1/media/c3894afd-7a37-43e2-917c-5ffb7a5036a2_zpschul0pqd.png.html'><img src='http://web.jmgrovebuildingsupply.com/CustomerDocs/DefaultEmailContents/houzz.png' /></a>&nbsp;<a href='http://s49.photobucket.com/user/jmg1/media/4478596b-67f4-444e-992a-624af3e56255_zpsoi8p1uyv.jpg.html'><img src='http://web.jmgrovebuildingsupply.com/CustomerDocs/DefaultEmailContents/linkin.jpg' /></a></div>";
                    strFooter = strFooter + " <div style='font-size: 13.3333px;'><img src='http://web.jmgrovebuildingsupply.com/CustomerDocs/DefaultEmailContents/footer.png' /></div></div>";

                    if(strInviteUsers!=""){

                        foreach (string useremail in strInviteUsers.Split(new char[] { ';' }, StringSplitOptions.RemoveEmptyEntries))
                        {
                            string emailId = useremail.ToString();
                           
                            string strsubject = "An Event Invite";
                            string emailbody="";
                            emailbody = strHeader + strbody + strFooter;

                            List<Attachment> lstAttachments = new List<Attachment>();
                            // your remote SMTP server IP.
                            
                            string sourceDir = Server.MapPath(JGConstant.EventCalendar_Upload_Folder);
                            if (File.Exists(sourceDir))
                            {
                                Attachment attachment = new Attachment(System.IO.Path.Combine(sourceDir, NewImageName));
                                attachment.Name = Path.GetFileName(System.IO.Path.Combine(sourceDir, NewImageName));
                                lstAttachments.Add(attachment);
                            }
                            
                            CommonFunction.SendEmail("", emailId, strsubject, emailbody, lstAttachments);
                        }
                    }
                    
                    ScriptManager.RegisterStartupScript(this.Page, GetType(), "al", "alert('Event Added Successfully');", true);
                }
                catch(Exception ex)
                {
                    // insert event error
                }
            }
            else
            {
                //If duplicate Event......
                ScriptManager.RegisterStartupScript(this.Page, GetType(), "al", "alert('Event Name for paricular date is already exist');", true);
            }
        }
        protected void btnEventClose_Click(object sender, EventArgs e)
        {
            mpEvents.Hide();
        }
        protected void rsAppointments_AppointmentClick(object sender, SchedulerEventArgs e)
        {
            //if (usertType == Admin)
            //{
            //    con = new SqlConnection(strcon);
            //    int ID = Convert.ToInt32(e.Appointment.ID);
            //    string Even = e.Appointment.Subject;
            //    string[] str = Even.Split(' ');
            //    string strResult = str[0];
            //    ViewState["ID"] = ID;
            //    string year = Convert.ToString(System.DateTime.Now.Year);

            //    if (strResult != "InterViewDetails")
            //    {
            //        lblDesigna.Visible = false;
            //        lblApplicant.Visible = false;
            //        lblPhone.Visible = false;
            //        lblDesigna.Visible = false;
            //        lblAdded.Visible = false;
            //        lblAplicantfirstName.Visible = false;
            //        lblPhoneNo.Visible = false;
            //        lblPhoneNo.Visible = false;
            //        lblDesignation.Visible = false;
            //        lblAddedBy.Visible = false;
            //        lbtLastName.Visible = false;
            //        Label2.Visible = true;
            //        txtEventName.Visible = true;
            //        Label2.Visible = true;
            //        txtEventName.Visible = true;
            //        Label3.Visible = true;
            //        txtHolidayDate.Visible = true;
            //        btnsave.Visible = true;
            //        btnDelete.Visible = true;

            //        //string query = "select * from tbl_AnnualEvents where DATEPART(yyyy,EventDate)='" + year + "'";// where id='" + ID + "'";
            //        string query = "select * from tbl_AnnualEvents where id='" + ID + "'";
            //        da = new SqlDataAdapter(query, con);
            //        ds = new DataSet();
            //        da.Fill(ds);
            //        if (ds.Tables[0].Rows.Count > 0)
            //        {
            //            lbtCustomerID.Text = Convert.ToString(ds.Tables[0].Rows[0]["ID"]);
            //            txtEventName.Text = Convert.ToString(ds.Tables[0].Rows[0]["EventName"]);
            //            string EventDate = Convert.ToString(ds.Tables[0].Rows[0]["EventDate"]);
            //            DateTime dat = Convert.ToDateTime(EventDate);
            //            txtHolidayDate.Text = dat.ToString("MM/dd/yyyy"); ;
            //            RadWindow2.VisibleOnPageLoad = true;
            //        }
            //    }
            //    else
            //    {
            //        lblAplicantfirstName.Visible = true;
            //        lblPhoneNo.Visible = true;
            //        lblPhoneNo.Visible = true;
            //        lblDesignation.Visible = true;
            //        lblAddedBy.Visible = true;
            //        lbtLastName.Visible = true;
            //        Label2.Visible = false;
            //        txtEventName.Visible = false;
            //        Label2.Visible = false;
            //        txtEventName.Visible = false;
            //        Label3.Visible = false;
            //        txtHolidayDate.Visible = false;
            //        lblDesigna.Visible = true;
            //        lblApplicant.Visible = true;
            //        lblPhone.Visible = true;
            //        lblDesigna.Visible = true;
            //        lblAdded.Visible = true;
            //        btnsave.Visible = false;
            //        btnDelete.Visible = false;

            //        int id = Convert.ToInt32(ViewState["ID"]);
            //        DataSet ds = AdminBLL.Instance.GetInterviewDetails(id);
            //        int applicantId = 0;
            //        if (ds.Tables[0].Rows.Count > 0)
            //        {
            //            applicantId = Convert.ToInt32(ds.Tables[0].Rows[0]["ApplicantId"]);
            //            ViewState["ApplicantId"] = applicantId;
            //            lbtCustomerID.Text = Convert.ToString(ds.Tables[0].Rows[0]["ID"]);
            //            lblAplicantfirstName.Text = Convert.ToString(ds.Tables[0].Rows[0]["FristName"]);
            //            lblPhoneNo.Text = Convert.ToString(ds.Tables[0].Rows[0]["Phone"]);
            //            lblDesignation.Text = Convert.ToString(ds.Tables[0].Rows[0]["Designation"]);
            //            int a = Convert.ToInt32(ds.Tables[0].Rows[0]["EventAddedBy"]);
            //            string query = "select * from tblUsers where id='" + a + "'";
            //            da = new SqlDataAdapter(query, con);
            //            DataSet dsid = new DataSet();
            //            da.Fill(dsid);

            //            if (dsid.Tables[0].Rows.Count > 0)
            //            {
            //                lblAddedBy.Text = Convert.ToString(dsid.Tables[0].Rows[0]["Username"]);
            //            }
            //            lbtLastName.Text = Convert.ToString(ds.Tables[0].Rows[0]["LastName"]);

            //            RadWindow2.VisibleOnPageLoad = true;
            //        }
            //    }
            //}

            //else
            //{
            //    RadWindow2.VisibleOnPageLoad = false;
            //}
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            //AnnualEvent a = new AnnualEvent();
            //a.id = Convert.ToInt32(lbtCustomerID.Text);
            //new_customerBLL.Instance.DeleteAnnualEvent(a);
            //BindCalendar();

            //int userId = Convert.ToInt16(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
            //ScriptManager.RegisterStartupScript(this.Page, GetType(), "al", "alert('Event Deleted Successfully');", true);
            //RadWindow2.VisibleOnPageLoad = false;
            /*
            try
            {
                //Adding Record to Database through Stored Procedure
                con = new SqlConnection(strcon);
                cmd = new SqlCommand("DeleteAnnualEvent", con);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@ID", lbtCustomerID.Text);

                con.Open();
                cmd.ExecuteNonQuery();
                con.Close();
                BindCalendar();

                //Clear All Data after submitting.....
                ScriptManager.RegisterStartupScript(this.Page, GetType(), "al", "alert('Event Deleted Successfully');", true);
                RadWindow2.VisibleOnPageLoad = false;
            }

            catch
            {
                //return 0;
                //LogManager.Instance.WriteToFlatFile(ex);
            }
           */
        }

        protected void btnAddEvent_Click(object sender, EventArgs e)
        {
            Response.Redirect("AddEvents.aspx");
        }

        protected void lbtLastName_Click(object sender, EventArgs e)
        {
            Response.Redirect("InstallCreateUser.aspx?ID=" + ViewState["ApplicantId"]);
        }

        protected void chkHR_CheckedChanged(object sender, EventArgs e)
        {
            LoadCalendar();
        }

        protected void chkCompany_CheckedChanged(object sender, EventArgs e)
        {
            LoadCalendar();
        }

        protected void chkEvents_CheckedChanged(object sender, EventArgs e)
        {
            LoadCalendar();
        }

        protected void lbtCustID_Click(object sender, EventArgs e)
        {
            LinkButton CustomerId = (LinkButton)sender;

            SchedulerAppointmentContainer appContainer = (SchedulerAppointmentContainer)CustomerId.Parent;
            Appointment appointment = appContainer.Appointment;
            int i = Convert.ToInt32(appointment.ID);
            DataSet ds = AdminBLL.Instance.GetInterviewDetails(i);
            int applicantId = 0;
            if (ds.Tables[0].Rows.Count > 0)
            {
                applicantId = Convert.ToInt32(ds.Tables[0].Rows[0]["ApplicantId"]);
                ViewState["ApplicantId"] = applicantId;
            }

            Response.Redirect("InstallCreateUser.aspx?ID=" + ViewState["ApplicantId"]);
        }

        protected void ddlStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
            string selValue = ((System.Web.UI.WebControls.ListControl)(sender)).SelectedValue;
            LinkButton lnk = (LinkButton)((System.Web.UI.WebControls.ListControl)(sender)).Parent.FindControl("lbtCustID");

            hidApplicantID.Value = lnk.Text;
            hidSelectedVal.Value = selValue;

            if (ViewState["Email"] == null)
            {
                LinkButton lnkEmail = (LinkButton)((System.Web.UI.WebControls.ListControl)(sender)).Parent.FindControl("lnkEmail");
                txtOfferMail.Text = lnkEmail.Text;
                txtOfferPassword.Attributes.Add("value", "jmgrove");
                txtOfferConPassword.Attributes.Add("value", "jmgrove");
                ViewState["Email"] = lnkEmail.Text;

                if (selValue == "OfferMade")
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "Overlay", "OverlayPopupOfferMade();", true);
                    return;
                }
            }
        }

        protected void rsAppointments_AppointmentCreated(object sender, AppointmentCreatedEventArgs e)
        {
            string status = e.Appointment.Attributes["Status"];
            //string status = Convert.ToString(DataBinder.Eval(e.Appointment.DataItem, "Status"));
            DropDownList ddlStatus = (DropDownList)e.Container.FindControl("ddlStatus");
            LinkButton lbtnReSchedule = (LinkButton)e.Container.FindControl("lbtnReSchedule");
            if (ddlStatus != null && !string.IsNullOrEmpty(status) && ddlStatus.Items.FindByValue(status) != null)
            {
                ddlStatus.SelectedValue = status;

                if (ddlStatus.SelectedValue == "InterviewDate")
                    lbtnReSchedule.Visible = true;
                else
                    lbtnReSchedule.Visible = false;
            }

            e.Appointment.Subject = e.Appointment.Attributes["EventName"];
            if (!string.IsNullOrEmpty(e.Appointment.Attributes["AssignedUserFristNames"]))
            {
                e.Appointment.Subject = string.Concat(e.Appointment.Subject, " ", e.Appointment.Attributes["AssignedUserFristNames"]).Trim();
            }
        }

        protected void btnSaveOfferMade_Click(object sender, EventArgs e)
        {
            try
            {
                int EditId = 0;
                int.TryParse(hidApplicantID.Value, out EditId);
                InstallUserBLL.Instance.UpdateOfferMade(EditId, txtOfferMail.Text, txtOfferPassword.Text);

                DataSet ds = new DataSet();
                string email = "", HireDate = "", EmpType = "", PayRates = "", Desig = "", reason = "", firstName = "", lastName = "";

                ds = InstallUserBLL.Instance.ChangeStatus(hidSelectedVal.Value, EditId, DateTime.Today.ToString("yyyy-MM-dd"), DateTime.Now.ToShortTimeString(), Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]), JGSession.IsInstallUser.Value, reason);
                if (ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        email = Convert.ToString(ds.Tables[0].Rows[0][0]) != "" ? Convert.ToString(ds.Tables[0].Rows[0][0]) : "";
                        HireDate = Convert.ToString(ds.Tables[0].Rows[0][1]) != "" ? Convert.ToString(ds.Tables[0].Rows[0][1]) : "";
                        EmpType = Convert.ToString(ds.Tables[0].Rows[0][2]) != "" ? Convert.ToString(ds.Tables[0].Rows[0][2]) : "";
                        PayRates = Convert.ToString(ds.Tables[0].Rows[0][3]) != "" ? Convert.ToString(ds.Tables[0].Rows[0][3]) : "";
                        Desig = Convert.ToString(ds.Tables[0].Rows[0]["Designation"]) != "" ? Convert.ToString(ds.Tables[0].Rows[0]["Designation"]) : "";
                        firstName = Convert.ToString(ds.Tables[0].Rows[0]["FristName"]) != "" ? Convert.ToString(ds.Tables[0].Rows[0]["FristName"]) : "";
                        lastName = Convert.ToString(ds.Tables[0].Rows[0]["LastName"]) != "" ? Convert.ToString(ds.Tables[0].Rows[0]["LastName"]) : "";
                    }
                }

                string strHtml = JG_Prospect.App_Code.CommonFunction.GetContractTemplateContent(199, 0, Desig);
                strHtml = strHtml.Replace("#CurrentDate#", DateTime.Now.ToShortDateString());
                strHtml = strHtml.Replace("#FirstName#", firstName);
                strHtml = strHtml.Replace("#LastName#", lastName);
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

                SendEmail(email, firstName, lastName, "Offer Made", reason, Desig, HireDate, EmpType, PayRates, 105, lstAttachments);

                LoadCalendar();
            }
            catch (Exception ex)
            {
                Console.WriteLine("{0} Exception caught.", ex);
            }
            finally
            {
                ViewState["Email"] = null;
                ScriptManager.RegisterStartupScript(this, this.GetType(), "Overlay", "ClosePopupOfferMade()", true);
            }
        }

        protected void lbtnReSchedule_Click(object sender, CommandEventArgs e)
        {
            int intApplicantID = 0;

            string[] commandArgs = e.CommandArgument.ToString().Split(new char[] { ',' });

            int.TryParse(commandArgs[0].ToString(), out intApplicantID);
            Session["ApplicantDesignation"] = commandArgs[1];
            Session["ApplicantId"] = intApplicantID;
            ReScheduleInterviewDate(Convert.ToInt32(intApplicantID));

            ScriptManager.RegisterStartupScript(this, this.GetType(), "Overlay", "overlayInterviewDate()", true);
            return;
        }

        /// <summary>
        /// Reschedule Interviw Date and send respective emails
        ///  Task ID#: ITSN034 ?TaskId=117
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void btnSaveInterview_Click(object sender, EventArgs e)
        {

            DataSet ds = new DataSet();
            string strEmail = string.Empty;
            string strFristName = string.Empty;
            string strLastName = string.Empty;
            string strHireDate = string.Empty;

            DateTime interviewDate;
            DateTime.TryParse(dtInterviewDate.Text, out interviewDate);
            if (interviewDate == null)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "Overlay", "alert('Invalid Interview Date, Please verify');", true);
                return;
            }
            ds = InstallUserBLL.Instance.ReSchedule_Interivew(Convert.ToInt32(Session["ApplicantId"])
                , interviewDate.ToString("yyyy-MM-dd")
                , ddlInsteviewtime.SelectedItem.Text
                , Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]));


            if (ds != null)
            {
                if (ds.Tables[0].Rows.Count > 0)
                {
                    strEmail = ds.Tables[0].Rows[0]["Email"].ToString();
                    strFristName = ds.Tables[0].Rows[0]["FristName"].ToString();
                    strLastName = ds.Tables[0].Rows[0]["LastName"].ToString();
                    strHireDate = ds.Tables[0].Rows[0]["LastName"].ToString();
                }
            }

            //AssignedTask if any or Default

            SendEmail(strEmail, strFristName, strLastName, "Interview Date Auto Email", "",
                Convert.ToString(Session["ApplicantDesignation"]), strHireDate, "", "", 104);

            AssignedTaskToUser();

            Session["ApplicantId"] = null;

            Response.Redirect(JG_Prospect.Common.JGConstant.PG_PATH_MASTER_CALENDAR);


            //ScriptManager.RegisterStartupScript(this, this.GetType(), "Overlay", "ClosePopupInterviewDate()", true);
            //return;
        }

        #endregion

        #region '--Methods--'

        #region ' -- Re-Schedule Interivew Helper Methods--'

        private void ReScheduleInterviewDate(int CandidateUserId)
        {
            LoadUsersByRecruiterDesgination();

            ddlTechTask = Utilits.FullDropDown.FillTechTaskDropDown(ddlTechTask);
            ddlInsteviewtime = Utilits.FullDropDown.GetTimeIntervals(ddlInsteviewtime);

            lblCurrentTask.Text = GetUserCurrentTask(CandidateUserId);

            dtInterviewDate.Text = DateTime.Now.AddDays(1).ToShortDateString();
            ddlInsteviewtime.SelectedValue = "10:00 AM";

        }

        private string GetUserCurrentTask(int UserId)
        {
            string strUserTask = "No Task Assigned";

            DataSet ds = InstallUserBLL.Instance.GetTechTaskByUser(UserId);

            if (ds != null)
            {
                if (ds.Tables[0].Rows.Count > 0)
                {
                    strUserTask = ds.Tables[0].Rows[0]["Title"].ToString();
                }
            }

            return strUserTask;
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

        private void AssignedTaskToUser()
        {
            //If dropdown has any value then assigned it to user else. return 
            if (ddlTechTask.Items.Count > 0)
            {
                string ApplicantId = Session["ApplicantId"].ToString();
                // save (insert / delete) assigned users.
                //bool isSuccessful = TaskGeneratorBLL.Instance.SaveTaskAssignedUsers(Convert.ToUInt64(ddlTechTask.SelectedValue), Session["EditId"].ToString());

                // save assigned user a TASK.
                bool isSuccessful = TaskGeneratorBLL.Instance.SaveTaskAssignedToMultipleUsers(Convert.ToUInt64(ddlTechTask.SelectedValue), ApplicantId);

                // Change task status to assigned = 3.
                if (isSuccessful)
                    UpdateTaskStatus(Convert.ToInt32(ddlTechTask.SelectedValue), Convert.ToUInt16(JGConstant.TaskStatus.Assigned));

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
        }

        private void SendEmailToAssignedUsers(string strInstallUserIDs, string strTaskId)
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

        public void LoadCalendar()
        {
            //For HR Calendar.....
            if (chkHR.Checked == true && chkCompany.Checked == false && chkEvents.Checked == false)
            {
                BindHRCalendar();
            }
            //For Company Calendar.....
            else if (chkCompany.Checked == true && chkHR.Checked == false && chkEvents.Checked == false)
            {
                BindCompanyCalendar();
            }
            //For Event Calendar.....
            else if (chkEvents.Checked == true && chkHR.Checked == false && chkCompany.Checked == false)
            {
                BindEventCalendar();
            }
            //For HR Calendar AND Company Calendar.....
            else if (chkHR.Checked == true && chkCompany.Checked == true && chkEvents.Checked == false)
            {
                BindHRCompanyCalendar();
            }
            //For HR Calendar AND Event Calendar.....
            else if (chkHR.Checked == true && chkEvents.Checked == true && chkCompany.Checked == false)
            {
                BindHREventCalendar();
            }
            //For Company Calendar AND Event Calendar.....
            else if (chkCompany.Checked == true && chkEvents.Checked == true && chkHR.Checked == false)
            {
                BindCompanyEventCalendar();
            }
            //For Company Calendar AND Event Calendar AND HR Calendar.....
            else if (chkHR.Checked == true && chkCompany.Checked == true && chkEvents.Checked == true)
            {
                BindHRCompanyEventCalendar();
            }
            else if (chkHR.Checked == false && chkCompany.Checked == false && chkEvents.Checked == false)
            {
                BindCalendar();
            }
        }

        public void BindCalendar()
        {
            DataSet ds = AdminBLL.Instance.GetAllAnnualEvent();
            if (ds.Tables[0].Rows.Count > 0)
            {
                rsAppointments.DataSource = ds.Tables[0];
                rsAppointments.DataBind();
            }
            RadWindow2.VisibleOnPageLoad = false;
        }

        public void BindHRCalendar()
        {
            DataSet ds = AdminBLL.Instance.GetHRCalendar();
            if (ds.Tables[0].Rows.Count > 0)
            {
                rsAppointments.DataSource = ds.Tables[0];
                rsAppointments.DataBind();
            }
            RadWindow2.VisibleOnPageLoad = false;
        }

        public void BindCompanyCalendar()
        {
            if (usertType == Admin)
            {
                DataSet ds = AdminBLL.Instance.GetCompanyCalendar();
                if (ds.Tables[0].Rows.Count > 0)
                {
                    rsAppointments.DataSource = ds.Tables[0];
                    rsAppointments.DataBind();
                }
            }
            RadWindow2.VisibleOnPageLoad = false;
        }

        public void BindEventCalendar()
        {
            DataSet ds = AdminBLL.Instance.GetEventCalendar();
            if (ds.Tables[0].Rows.Count > 0)
            {
                rsAppointments.DataSource = ds.Tables[0];
                rsAppointments.DataBind();
            }
            RadWindow2.VisibleOnPageLoad = false;
        }

        //----------- Start DP ------------

        public void BindEventByCalendar(int calid)
        {
            DataSet ds = AdminBLL.Instance.GetEventByCalendar(calid);
            if (ds.Tables[0].Rows.Count > 0)
            {
                rsAppointments.DataSource = ds.Tables[0];
                rsAppointments.DataBind();
            }
            RadWindow2.VisibleOnPageLoad = false;
        }
        // ---------- End DP ------------

        public void BindHRCompanyCalendar()
        {
            DataSet ds = AdminBLL.Instance.GetHRCompanyCalendar();
            if (ds.Tables[0].Rows.Count > 0)
            {
                rsAppointments.DataSource = ds.Tables[0];
                rsAppointments.DataBind();
            }
            RadWindow2.VisibleOnPageLoad = false;
        }

        public void BindHREventCalendar()
        {
            DataSet ds = AdminBLL.Instance.GetHRCompanyEventCalendar();
            if (ds.Tables[0].Rows.Count > 0)
            {
                rsAppointments.DataSource = ds.Tables[0];
                rsAppointments.DataBind();
            }
            RadWindow2.VisibleOnPageLoad = false;
        }

        public void BindCompanyEventCalendar()
        {
            DataSet ds = AdminBLL.Instance.GetEventCompanyCalendar();
            if (ds.Tables[0].Rows.Count > 0)
            {
                rsAppointments.DataSource = ds.Tables[0];
                rsAppointments.DataBind();
            }
            RadWindow2.VisibleOnPageLoad = false;
        }

        public void BindHRCompanyEventCalendar()
        {
            DataSet ds = AdminBLL.Instance.GetHRCompanyEventCalendar();
            if (ds.Tables[0].Rows.Count > 0)
            {
                rsAppointments.DataSource = ds.Tables[0];
                rsAppointments.DataBind();
            }
            RadWindow2.VisibleOnPageLoad = false;
        }

        public void SendEmail(string emailId, string FName, string LName, string status, string Reason, string Designition, string HireDate, string EmpType, string PayRates, int htmlTempID, List<Attachment> Attachments = null)
        {
            try
            {
                string fullname = FName + " " + LName;
                DataSet ds = AdminBLL.Instance.GetEmailTemplate(Designition, htmlTempID);// AdminBLL.Instance.FetchContractTemplate(104);

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
                //strBody = strBody.Replace("#Date#", dtInterviewDate.Text).Replace("#date#", dtInterviewDate.Text);
                //strBody = strBody.Replace("#Time#", ddlInsteviewtime.SelectedValue).Replace("#time#", ddlInsteviewtime.SelectedValue);
                strBody = strBody.Replace("#Designation#", Designition).Replace("#designation#", Designition);

                strFooter = strFooter.Replace("#Name#", FName).Replace("#name#", FName);
                //strFooter = strFooter.Replace("#Date#", dtInterviewDate.Text).Replace("#date#", dtInterviewDate.Text);
                //strFooter = strFooter.Replace("#Time#", ddlInsteviewtime.SelectedValue).Replace("#time#", ddlInsteviewtime.SelectedValue);
                strFooter = strFooter.Replace("#Designation#", Designition).Replace("#designation#", Designition);

                strBody = strBody.Replace("Lbl Full name", fullname);
                strBody = strBody.Replace("LBL position", Designition);
                //strBody = strBody.Replace("lbl: start date", txtHireDate.Text);
                //strBody = strBody.Replace("($ rate","$"+ txtHireDate.Text);
                strBody = strBody.Replace("Reason", Reason);
                //Hi #lblFName#, <br/><br/>You are requested to appear for an interview on #lblDate# - #lblTime#.<br/><br/>Regards,<br/>
                strBody = strHeader + strBody + strFooter;

                EditUser obj = new EditUser();
                if (status == "OfferMade")
                {
                    //TODO : commented code for missing directive using Word = Microsoft.Office.Interop.Word;
                    //obj.createForeMenForJobAcceptance(strBody, FName, LName, Designition, emailId, HireDate, EmpType, PayRates);
                }
                if (status == "Deactive")
                {
                    //TODO : commented code for missing directive using Word = Microsoft.Office.Interop.Word;
                    //obj.CreateDeactivationAttachment(strBody, FName, LName, Designition, emailId, HireDate, EmpType, PayRates);
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
            catch (Exception ex)
            {
                UtilityBAL.AddException("CreateSalesUser-SendEmail", Session["loginid"] == null ? "" : Session["loginid"].ToString(), ex.Message, ex.StackTrace);
            }
        }

        private void FillMyCalendarDropDown()
        {
            //---------- start DP ------------
            int userId = Convert.ToInt16(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("GetAllEventCalendar");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@UserId", DbType.Int32, userId);
                    result = database.ExecuteDataSet(command);
                }
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
            }

            if (result.Tables[0].Rows.Count > 0)
            {
                drpMyCalendar.Items.Clear();
                drpEventCalender.Items.Clear();

                ListItem lstMyCal = new ListItem();
                lstMyCal.Text = "My Calendar";
                lstMyCal.Value = "0";
                drpMyCalendar.Items.Add(lstMyCal);


                for (int i = 0; i < result.Tables[0].Rows.Count; i++)
                {
                    ListItem lst = new ListItem();
                    lst.Text = result.Tables[0].Rows[i]["CalendarName"].ToString();
                    lst.Value = result.Tables[0].Rows[i]["ID"].ToString();
                    drpEventCalender.Items.Add(lst);
                    drpMyCalendar.Items.Add(lst);
                }
            }
            result.Dispose();
            //------------ End DP ------------
        }


        #endregion
    }
}