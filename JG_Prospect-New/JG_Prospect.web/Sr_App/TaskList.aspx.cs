#region "-- Using --"

using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using JG_Prospect.Common;
using JG_Prospect.BLL;
using System.Data;
using JG_Prospect.App_Code;
#endregion



namespace JG_Prospect.Sr_App
{
    public partial class TaskList : System.Web.UI.Page
    {
        private static string strAdminMode = "ADMINMODE";

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
                LoadFilters();
                SearchTasks();
            }
        }



        #endregion

        #region "-Control Events-"
        protected void btnSearch_Click(object sender, ImageClickEventArgs e)
        {
            SearchTasks();
        }
        protected void gvTasks_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvTasks.PageIndex = e.NewPageIndex;
            SearchTasks();
        }
        protected void gvTasks_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                Label lblTaskStatus = (Label)e.Row.FindControl("lblTaskStatus");

                if (lblTaskStatus != null)
                {
                    lblTaskStatus.Text = ((JGConstant.TaskStatus)Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "Status"))).ToString();

                }

            }
        }
        
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

        #endregion

        #region "--Private Methods--"

        private void CheckIsAdmin()
        {

            this.IsAdminMode = CommonFunction.CheckAdminMode();

        }


        /// <summary>
        /// Load filter dropdowns for task
        /// </summary>
        private void LoadFilters()
        {

            DataSet dsFilters = TaskGeneratorBLL.Instance.GetAllUsersNDesignationsForFilter();

            DataTable dtUsers = dsFilters.Tables[0];
            //DataTable dtDesignations = dsFilters.Tables[1];

            ddlUsers.DataSource = dtUsers;
            //ddlDesignation.DataSource = dtDesignations;

            ddlUsers.DataTextField = "FirstName";
            ddlUsers.DataValueField = "Id";
            ddlUsers.DataBind();

            //ddlDesignation.DataTextField = "Designation";
            //ddlDesignation.DataValueField = "Designation";
            //ddlDesignation.DataBind();

            ddlUsers.Items.Insert(0, new ListItem("--All--", "0"));
            ddlDesignation.Items.Insert(0, new ListItem("--All--", "0"));
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

            DataSet dsResult = TaskGeneratorBLL.Instance.GetTasksList(UserID, Title, Designation, Status, CreatedFrom, CreatedTo, Statuses, Designations, this.IsAdminMode , Start, PageLimit);

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
                    Designation = ddlDesignation.SelectedItem.Value;
                }

                if (ddlTaskStatus.SelectedIndex > 0)
                {
                    Status = Convert.ToInt16(ddlTaskStatus.SelectedItem.Value);
                }
            }
            else
            {
                UserID = Convert.ToInt32(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);

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

        #endregion

    }
}