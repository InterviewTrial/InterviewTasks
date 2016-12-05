using System;
using System.Data;
using JG_Prospect.BLL;
using System.Web.UI.WebControls;
using System.Web.UI;


namespace JG_Prospect.UserControl.PopUp
{
    public partial class ucStaffLoginAlert : System.Web.UI.UserControl
    {

        #region '-- --'

        public bool DoInterviewGridHasData { get; set; }

        #endregion

        #region '-- Control Events--'
        protected void Page_Load(object sender, EventArgs e)
        {

        }


        #region Grid Events

        public void BindControl()
        {
            DataSet dS = new DataSet();
            dS = InstallUserBLL.Instance.GetAllInterivewUserByPastDate();

            DataSet dsPastInterviewDate = new DataSet();

            dsPastInterviewDate = dS.Clone();

            foreach (DataRow dtRow in dS.Tables[0].Rows)
            {
                DateTime InterviewDate;
                try
                {
                    if (dtRow["RejectionDate"] != null || dtRow["InterviewDetail"] != null)
                        if (dtRow["RejectionDate"].ToString().Trim() != "" || dtRow["InterviewDetail"].ToString().Trim() != "")
                        {
                            InterviewDate = DateTime.Parse(dtRow["RejectionDate"].ToString() + " " + dtRow["InterviewDetail"].ToString());
                            if (DateTime.Now > InterviewDate)
                            {
                                dtRow["InterviewDetail"] = InterviewDate.ToString();
                                dsPastInterviewDate.Tables[0].Rows.Add(dtRow.ItemArray);
                            }
                        }
                }
                catch (Exception ex)
                {
                    UtilityBAL.AddException("EditUser-CreateUserObjectXml", Session["loginid"] == null ? "" : Session["loginid"].ToString(), ex.Message, ex.StackTrace);
                    continue;
                }

            }

            if (dsPastInterviewDate.Tables[0].Rows.Count > 0)
            {
                grdUsers.DataSource = dsPastInterviewDate;
                grdUsers.DataBind();

                DoInterviewGridHasData = true;
            }
            else
            {
                DoInterviewGridHasData = false;
            }
        }

        protected void grdUsers_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            try
            {
                if (e.Row.RowType == DataControlRowType.DataRow)
                {
                    DropDownList ddlStatus = (e.Row.FindControl("ddlStatus") as DropDownList);//Find the DropDownList in the Row                    
                    string Status = Convert.ToString((e.Row.FindControl("lblStatus") as HiddenField).Value);//Select the status in DropDownList
                    

                    if (Status != "")
                    {
                        ddlStatus.Items.FindByValue(Status).Selected = true;
                         
                    }
                }
            }
            catch (Exception ex)
            {
                Response.Write("" + ex.Message);
            }
        }

        protected void grdUsers_ddlStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
            EditUser objEditUser = new EditUser();

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
                //binddata();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('You dont have rights change the status.')", true);
                return;
            }
            else if ((lblStatus.Value == "Active" && ddl.SelectedValue != "Deactive") && ((Convert.ToString(Session["usertype"]).Contains("Admin")) || (Convert.ToString(Session["usertype"]).Contains("SM"))))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "Overlay", "overlayPassword();", true);
                return;
            }
            bool status = objEditUser.CheckRequiredFields(ddl.SelectedValue, Convert.ToInt32(Id.Text));
            if (!status)
            {
                if (ddl.SelectedValue == "Offer Made" || ddl.SelectedValue == "OfferMade")
                {
                    //////////hdnFirstName.Value = lblFirstName.Text;
                    //////////hdnLastName.Value = lblLastName.Text;
                    //////////txtEmail.Text = lblEmail.Text;
                    //////////txtPassword1.Attributes.Add("value", "jmgrove");
                    //////////txtpassword2.Attributes.Add("value", "jmgrove");
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "Overlay", "OverlayPopupOfferMade();", true);
                    return;
                }
                else
                {
                    //binddata();
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
                //LoadUsersByRecruiterDesgination();
                //FillTechTaskDropDown();
                //ddlInsteviewtime.DataSource = GetTimeIntervals();
                //ddlInsteviewtime.DataBind();
                //dtInterviewDate.Text = DateTime.Now.AddDays(1).ToShortDateString();
                //ddlInsteviewtime.SelectedValue = "10:00 AM";
                ScriptManager.RegisterStartupScript(this, this.GetType(), "OverlayUc", "ucoverlayInterviewDate();", true);
                

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
                //////////txtEmail.Text = lblEmail.Text;
                //////////txtPassword1.Attributes.Add("value", "jmgrove");
                //////////txtpassword2.Attributes.Add("value", "jmgrove");
                ScriptManager.RegisterStartupScript(this, this.GetType(), "Overlay", "OverlayPopupOfferMade();", true);
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

                ////////////////////InstallUserBLL.Instance.ChangeStatus(Convert.ToString(Session["EditStatus"]), Convert.ToInt32(Session["EditId"]), Convert.ToString(DateTime.Today.ToShortDateString()), DateTime.Now.ToShortTimeString(), Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]), JGSession.IsInstallUser.Value, txtReason.Text);
                //binddata();

                if ((ddl.SelectedValue == "Active") || (ddl.SelectedValue == "Deactive"))
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "Overlay", "showStatusChangePopUp();", true);
                return;
            }
        }

        #endregion

        #endregion
    }
}