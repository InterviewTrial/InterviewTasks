#region "-- using --"

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Data;
using System.Web.UI.WebControls;
using System.Text;
using System.Configuration;
using JG_Prospect.BLL;
using JG_Prospect.Common.modal;
using JG_Prospect.Common;
using System.Web.Script.Serialization;
using Newtonsoft.Json;
using System.Web.UI.HtmlControls;

#endregion


namespace JG_Prospect.Sr_App
{
    public partial class DesignationAddEdit : System.Web.UI.Page
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
                else if (Session["usertype"] != null && Session["usertype"].ToString() != "Admin")
                {
                    Response.Redirect("~/home.aspx", true);
                }
                else
                {
                    if (Request.QueryString["DesignationId"] != null)
                    {
                        Session["DesignationId"] = Request.QueryString["DesignationId"];
                    }
                    if (Request.QueryString["DepartmentId"] != null)
                    {
                        Session["DepartmentId"] = Request.QueryString["DepartmentId"];
                    }
                    if (Session["DesignationId"] != null)
                    {
                        BindDepartmentDetails();
                        FillDesignationDetails(Convert.ToInt32(Session["DesignationId"].ToString()));
                        if (Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()] != null)
                        {
                            UserId = Convert.ToInt16(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
                        }
                    }
                }
            }
        }

        #endregion

        #region "--Control Events--"

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                Designation objdep = new Designation();
                objdep.ID = Convert.ToInt32(Session["DesignationId"].ToString());
                objdep.DesignationName = txtDesignationName.Text;
                objdep.IsActive = ddlStatus.SelectedValue == "1" ? true : false;
                objdep.DepartmentID = Convert.ToInt32(ddlDepartment.SelectedValue);
                int res = DesignationBLL.Instance.DesignationInsertUpdate(objdep);
                if (res != 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "AlertBox", "alert('Designation save successfully.');", true);
                    Response.Redirect("DesignationList.aspx?DepartmentId="+ ddlDepartment.SelectedValue, true);
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "AlertBox", "alert('Please Try Again');", true);
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect("DesignationAddEdit.aspx?DesignationId=0", true);
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            if (Session["usertype"].ToString() != "Admin")
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "AlertBox", "alert('You don't have permission to delete customer record');", true);
                return;
            }
            else
            {
                int custid = Convert.ToInt32(Session["DesignationId"].ToString());
                string AdminId = ConfigurationManager.AppSettings["AdminUserId"].ToString();
                bool result = new_customerBLL.Instance.DeleteCustomerDetails(Convert.ToInt32(Session["DesignationId"].ToString()));
                if (result)
                {
                    ResetFormControlValues();
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "AlertBox", "alert('Customer Record Deleted successfully');", true);
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "AlertBox", "alert('There is some error in deleting customer');", true);
                    return;
                }
            }
        }
        #endregion

        #region "--Private Methods--"

        private void BindDepartmentDetails()
        {
            try
            {
                DataSet ds = new DataSet();
                ds = DepartmentBLL.Instance.GetAllDepartment();
                ddlDepartment.DataValueField = "ID";
                ddlDepartment.DataTextField = "DepartmentName";
                ddlDepartment.DataSource = ds.Tables[0];
                ddlDepartment.DataBind();

                if (Session["DepartmentId"] != null)
                    ddlDepartment.SelectedValue = Session["DepartmentId"].ToString();

            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "AlertBox", "alert(\"" + ex.Message + "\");", true);
            }

        }
        private void FillDesignationDetails(int DesignationId)
        {
            try
            {
                ResetFormControlValues();
                if (DesignationId == 0)
                    return;

                DataSet ds = new DataSet();

                ds = DesignationBLL.Instance.GetDesignationByID(DesignationId, 0);
                if (ds != null)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        txtDesignationName.Text = ds.Tables[0].Rows[0]["DesignationName"].ToString();
                        ddlDepartment.SelectedValue = ds.Tables[0].Rows[0]["DepartmentID"].ToString();
                        ddlDepartment.Enabled = false;
                        ddlStatus.SelectedValue = ds.Tables[0].Rows[0]["IsActive"].ToString() == "False" ? "0" : "1";
                    }
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "AlertBox", "alert(\"" + ex.Message + "\");", true);
            }

        }

        private void ResetFormControlValues()
        {
            try
            {
                txtDesignationName.Text = "";
                ddlStatus.SelectedValue = "1";
                ddlDepartment.Enabled = true;
            }
            catch { }
        }

        #endregion
    }
}