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
    public partial class DesignationList : System.Web.UI.Page
    {
        #region "--Properties--"

        private static int UserId = 0;

        #endregion

        #region "--Page methods--"
        public void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["loginid"] == null)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "AlertBox", "alert('You have to login first');", true);
                    Response.Redirect("~/login.aspx?returnurl=" + Request.Url.PathAndQuery);
                }
                //else if (Session["usertype"].ToString() != "Admin")
                //{
                //    Response.Redirect("~/home.aspx", true);
                //}
                else
                {
                    if (Request.QueryString["DepartmentId"] != null)
                    {
                        Session["DepartmentId"] = Request.QueryString["DepartmentId"];
                        addDesignation.HRef = "DesignationAddEdit.aspx?DesignationId=0&DepartmentId=" + Session["DepartmentId"];
                    }
                    
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

        protected void gvDesignationList_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            if (sender != null)
            {
                gvDesignationList.PageIndex = e.NewPageIndex;
                gvDesignationList.DataSource = (DataSet)ViewState["DesignationData"];
                gvDesignationList.DataBind();
            }
        }

        protected void gvDesignationList_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                DataRowView lDrRowData = (DataRowView)e.Row.DataItem;
                DropDownList ddlactive = (DropDownList)e.Row.FindControl("ddlactive");
                if (ddlactive != null)
                {
                    ddlactive.SelectedValue = lDrRowData["IsActive"].ToString() == "False" ? "0" : "1";
                }

                HtmlAnchor editDesignation = (HtmlAnchor)e.Row.FindControl("editDesignation");
                editDesignation.HRef= "DesignationAddEdit.aspx?DesignationId="+ lDrRowData["ID"].ToString() + "&DepartmentId=" + lDrRowData["DepartmentID"].ToString();

            }
        }

        #endregion

        #region "--Private Methods--"
        protected void bindGrid()
        {
            DataSet ds = DesignationBLL.Instance.GetAllDesignationByDepartmentID(Convert.ToInt32(Session["DepartmentId"].ToString()));
            ViewState["DesignationData"] = ds;
            gvDesignationList.DataSource = ds;
            gvDesignationList.DataBind();
        }

        private void ResetFormControlValues(Control parent)
        {
            try
            {
                gvDesignationList.DataSource = null;
                gvDesignationList.DataBind();
            }
            catch { }
        }

        #endregion
    }
}