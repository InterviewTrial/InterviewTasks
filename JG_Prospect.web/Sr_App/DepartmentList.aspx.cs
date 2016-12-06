#region "-- using --"

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Data;
using System.Web.UI.WebControls;
using System.Text;
using System.IO;
using System.Net;
using System.Configuration;

using JG_Prospect.BLL;
using JG_Prospect.Common.modal;
using JG_Prospect.Common;
using JG_Prospect.UserControl;
using System.Web.Script.Serialization;
using Newtonsoft.Json;
using System.Web.UI.HtmlControls;
using System.Net.Mail;
using System.Web.Services;

#endregion

namespace JG_Prospect.Sr_App
{
    public partial class DepartmentList : System.Web.UI.Page
    {

        #region "--Properties--"

        private static int UserId = 0;

        #endregion

        #region "--Page methods--"
        public void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["loginid"] == null && Session["usertype"] == null)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "AlertBox", "alert('You have to login first');", true);
                    Response.Redirect("~/login.aspx?returnurl=" + Request.Url.PathAndQuery);
                }
                //else if (Session["usertype"] != null && Session["usertype"].ToString() != "Admin")
                else if (Session["DesigNew"] != null && Session["DesigNew"].ToString() != "ITLead" && Session["DesigNew"].ToString() != "Admin")
                {
                    Response.Redirect("~/Sr_App/home.aspx", true);
                }
                //else if (Session["DesigNew"] != null && Session["DesigNew"].ToString() != "ITLead")
                //{

                //}
                else
                {
                    if (Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()] != null)
                    {
                        UserId = Convert.ToInt16(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
                    }
                    bindGrid();
                }
            }

        }

        #endregion

        #region "--Control Events--"

        protected void gvDepartmentList_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            if (sender != null)
            {
                gvDepartmentList.PageIndex = e.NewPageIndex;
                gvDepartmentList.DataSource = (DataSet)ViewState["DepartmentData"];
                gvDepartmentList.DataBind();
            }
        }

        protected void gvDepartmentList_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                DataRowView lDrRowData = (DataRowView)e.Row.DataItem;
                DropDownList ddlactive = (DropDownList)e.Row.FindControl("ddlactive");
                if (ddlactive != null)
                {
                    ddlactive.SelectedValue = lDrRowData["IsActive"].ToString() == "False" ? "0" : "1";
                }
            }
        }

         #endregion

        #region "--Private Methods--"
        protected void bindGrid()
        {
            DataSet ds = DepartmentBLL.Instance.GetAllDepartment();
            ViewState["DepartmentData"] = ds;
            gvDepartmentList.DataSource = ds;
            gvDepartmentList.DataBind();
        }

        private void ResetFormControlValues(Control parent)
        {
            try
            {
                //imgmap.ImageUrl = "";
                //GridViewLocationPic.DataSource = null;
                //GridViewLocationPic.DataBind();
                gvDepartmentList.DataSource = null;
                gvDepartmentList.DataBind();
                //LinkButtonmap1.Text = "";
                //LinkButtonmap2.Text = "";
                //LblStatus1.Text = "";
            }
            catch { }
        }

        #endregion


    }
}