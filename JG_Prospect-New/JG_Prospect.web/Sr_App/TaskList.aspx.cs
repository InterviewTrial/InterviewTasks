﻿#region "-- Using --"

using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using JG_Prospect.Common;
using JG_Prospect.BLL;
using System.Data;

#endregion



namespace JG_Prospect.Sr_App
{
    public partial class TaskList : System.Web.UI.Page
    {

        #region "--Page methods--"

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                LoadFilters();
                SearchTasks();
            }
        }



        #endregion

        #region "-Control Events-"
        protected void btnSearch_Click(object sender, EventArgs e)
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

        #endregion

        #region "--Private Methods--"

        /// <summary>
        /// Load filter dropdowns for task
        /// </summary>
        private void LoadFilters()
        {

            DataSet dsFilters = TaskGeneratorBLL.Instance.GetAllUsersNDesignationsForFilter();

            DataTable dtUsers = dsFilters.Tables[0];
            DataTable dtDesignations = dsFilters.Tables[1];

            ddlUsers.DataSource = dtUsers;
            ddlDesignation.DataSource = dtDesignations;

            ddlUsers.DataTextField = "FirstName";
            ddlUsers.DataValueField = "Id";
            ddlUsers.DataBind();

            ddlDesignation.DataTextField = "Designation";
            ddlDesignation.DataValueField = "Designation";
            ddlDesignation.DataBind();

            ddlUsers.Items.Insert(0, new ListItem("--Users--", "0"));
            ddlDesignation.Items.Insert(0, new ListItem("--Designation--", "0"));
        }

        /// <summary>
        /// Search tasks with parameters choosen by user.
        /// </summary>
        private void SearchTasks()
        {

            int? UserID = null;
            string Title = String.Empty, Designation = String.Empty;
            Int16? Status = null;
            DateTime? CreatedOn = null;

            // this is for paging based data fetch, in header view case it will be always page numnber 0 and page size 5
            int Start = gvTasks.PageIndex, PageLimit = gvTasks.PageSize;

            PrepareSearchFilerts(ref UserID, ref Title, ref Designation, ref Status, ref CreatedOn);

            DataSet dsResult = TaskGeneratorBLL.Instance.GetTasksList(UserID, Title, Designation, Status, CreatedOn, Start, PageLimit);

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
        private void PrepareSearchFilerts(ref int? UserID, ref string Title, ref string Designation, ref short? Status, ref DateTime? CreatedOn)
        {
            if (ddlUsers.SelectedIndex > 0)
            {
                UserID = Convert.ToInt32(ddlUsers.SelectedItem.Value);
            }

            if (!String.IsNullOrEmpty(txtSearch.Text))
            {
                Title = txtSearch.Text;
            }
            if (ddlDesignation.SelectedIndex > 0)
            {
                Designation = ddlDesignation.SelectedItem.Value;
            }

            if (ddlTaskStatus.SelectedIndex > 0)
            {
                Status = Convert.ToInt16(ddlTaskStatus.SelectedItem.Value);
            }

            if (!String.IsNullOrEmpty(txtCreatedon.Text))
            {
                CreatedOn = Convert.ToDateTime(txtCreatedon.Text);
            }
        }


        #endregion


    }
}