﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using JG_Prospect.Common.modal;
using JG_Prospect.BLL;
using System.IO;
using JG_Prospect.Common.Logger;
using System.Data;
using JG_Prospect.Common;
using System.Web.Services;
using System.Web.Script.Services;
using AjaxControlToolkit;
using System.Text.RegularExpressions;
using JG_Prospect.Sr_App.Controls;


namespace JG_Prospect.Sr_App.Product_Line
{
    public partial class Custom : System.Web.UI.Page
    {
        ErrorLog logManager = new ErrorLog();
        string previousPage = string.Empty;
        private static string OtherText = string.Empty;
        int userId = 0;
        protected int ProductTypeId
        {
            get
            {
                return ViewState[QueryStringKey.Key.ProductTypeId.ToString()] == null ? 0 : Convert.ToInt32(ViewState[QueryStringKey.Key.ProductTypeId.ToString()]);
            }
            set { ViewState[QueryStringKey.Key.ProductTypeId.ToString()] = value; }
        }

        public List<CustomerLocationPic> CustomerLocationPicturesList
        {
            get
            {
                return ViewState[SessionKey.Key.PagedataTable.ToString()] == null ? null : (List<CustomerLocationPic>)ViewState[SessionKey.Key.PagedataTable.ToString()];
            }
            set
            {
                ViewState[SessionKey.Key.PagedataTable.ToString()] = value;
            }
        }


        protected void Page_Load(object sender, EventArgs e)
        {

            int ProductId = 0, CustomerId = 0, CustomId = 0;
            if (Request.QueryString[QueryStringKey.Key.Other.ToString()] != null)
            {
                OtherText = Request.QueryString[QueryStringKey.Key.Other.ToString()].ToString();
            }
            ViewState["PreviousPage"] = Request.UrlReferrer;
            userId = Convert.ToInt16(Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
            if (ViewState["PreviousPage"] != null)
            {
                previousPage = ViewState["PreviousPage"].ToString();
            }

            //if (Request.QueryString[QueryStringKey.Key.ProductTypeIdFrom.ToString()] != null)
            //{
            //    ProductTypeIdFrom = Convert.ToInt32(Request.QueryString[QueryStringKey.Key.ProductTypeIdFrom.ToString()]);
            //}
            if (Request.QueryString[QueryStringKey.Key.CustomerId.ToString()] != null)
            {
                lblmsg.Text = Request.QueryString[QueryStringKey.Key.CustomerId.ToString()].ToString();
            }

            //DataSet dsCustomer=new_customerBLL.Instance.GetCustomerDetails(Convert.ToInt16(Request.QueryString[1]));
            DataSet dsCustomer = new_customerBLL.Instance.GetCustomerDetails(Convert.ToInt16(Request.QueryString[QueryStringKey.Key.CustomerId.ToString()].ToString()));
            if (dsCustomer.Tables[0].Rows.Count > 0)
            {
                txtCustomer.Text = dsCustomer.Tables[0].Rows[0]["CustomerName"].ToString();
                txtCustomer.Enabled = false;
            }
            DataSet dsTerms;
            if (Request.QueryString[QueryStringKey.Key.ProductTypeId.ToString()] != null)
            {
                ProductTypeId = Convert.ToInt16(Request.QueryString[QueryStringKey.Key.ProductTypeId.ToString()]);

                if (ProductTypeId != 0)
                {
                    string productName = UserBLL.Instance.GetProductNameByProductId(ProductTypeId);
                    string ProposalTerm = string.Empty;
                    dsTerms = new_customerBLL.Instance.GetProposalTerm(Convert.ToInt32(ProductTypeId));
                    if (dsTerms.Tables.Count > 0)
                    {
                        if (dsTerms.Tables[0].Rows.Count > 0)
                        {
                            if (Convert.ToString(dsTerms.Tables[0].Rows[0][1]) != "")
                            {
                                ProposalTerm = Convert.ToString(dsTerms.Tables[0].Rows[0][1]);
                                ProposalTerm = Regex.Replace(ProposalTerm, "<.*?>|&.*?;", string.Empty);
                                if (!IsPostBack)
                                {
                                    txtProposalTerm.Text = ProposalTerm;
                                }
                            }
                        }
                    }
                    h1Heading.InnerText = "Details:" + productName;
                }
            }
            if (ViewState[QueryStringKey.Key.Edit.ToString()] == null)
            {
                if (Request.QueryString[QueryStringKey.Key.CustomerId.ToString()] != null &&
                    Request.QueryString[QueryStringKey.Key.ProductTypeId.ToString()] != null &&
                    Request.QueryString[QueryStringKey.Key.ProductId.ToString()] != null)
                {
                    if (previousPage.Contains("Procurement.aspx"))
                    {
                        CustomerId = Convert.ToInt32(Request.QueryString[QueryStringKey.Key.CustomerId.ToString()]);
                        ProductId = Convert.ToInt32(Request.QueryString[QueryStringKey.Key.ProductTypeId.ToString()]);
                        CustomId = Convert.ToInt32(Request.QueryString[QueryStringKey.Key.ProductId.ToString()]);
                        fillCusromDetails(CustomerId, CustomId, ProductId);
                        lnkDownload.Visible = true;
                        DisableControls();
                        btnexit.Text = "Go Back";
                    }
                    else
                    {
                        CustomerId = Convert.ToInt32(Request.QueryString[QueryStringKey.Key.CustomerId.ToString()]);
                        ProductId = Convert.ToInt32(Request.QueryString[QueryStringKey.Key.ProductTypeId.ToString()]);
                        CustomId = Convert.ToInt32(Request.QueryString[QueryStringKey.Key.ProductId.ToString()]);

                        hidProdType.Value = ProductId.ToString();
                        btnsave.Text = JGConstant.UPDATE;
                        lnkDownload.Visible = true;

                        fillCusromDetails(CustomerId, CustomId, ProductId);
                        ViewState[QueryStringKey.Key.Edit.ToString()] = JGConstant.TRUE;
                    }

                }
                else { btnsave.Text = JGConstant.SAVE; }

            }
        }
        #region Shital Added

        private const string SESSIONKEY = "ProductLineControlsCount";
        private const string USER_CONTROL_NAME_PREFIX = "AddProductLineUserControl";
        public int AddedControlCount
        {
            get
            {
                return Session[SESSIONKEY] == null ? 0 : int.Parse(Session[SESSIONKEY].ToString());
            }
            set
            {
                Session[SESSIONKEY] = value;
            }
        }

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            if (!Page.IsPostBack)
            {
                Session[SESSIONKEY] = null;
            }
            LoadContactControls();
        }

        protected void btnAddProductLine_Click(object sender, EventArgs e)
        {
            AddedControlCount++;
            AddProductLineControl(USER_CONTROL_NAME_PREFIX + AddedControlCount);
        }

        /// <summary>
        /// Load the user controls based on session key
        /// </summary>
        private void LoadContactControls()
        {
            for (int i = 1; i <= AddedControlCount; i++)
            {
                AddProductLineControl(USER_CONTROL_NAME_PREFIX + i);
            }
        }

        private void AddProductLineControl(string Id)
        {
            System.Web.UI.UserControl x = (System.Web.UI.UserControl)LoadControl("~/Sr_App/Controls/AddProductLinesControl.ascx");
            x.ID = Id;
            placeHolderProductLines.Controls.Add(x);
        }

        #endregion

        private void DisableControls()
        {
            txtProposalTerm.Enabled = false;
            txtProposalCost.Enabled = false;
            txtCustSupMaterial.Enabled = false;
            chkCustSupMaterial.Enabled = false;
            txtStorage.Enabled = false;
            drpMaterial.Enabled = false;
            drpStorage.Enabled = false;
            chkStorage.Enabled = false;
            txtspecialIns.Enabled = false;
            chkPermit.Enabled = false;
            chkHabitat.Enabled = false;
        }
        [WebMethod]
        public static string Exists(string value)
        {
            if (value == AdminBLL.Instance.GetAdminCode())
            {
                return "True";
            }
            else
            {
                return "false";
            }
        }

        private void fillCusromDetails(int CustomerId, int CustomId, int ProductTypeId)
        {
            Customs custom = new Customs();
            string locPics = "";
            custom.ProductTypeId = ProductTypeId;
            custom.CustomerId = CustomerId;
            custom.Id = CustomId;


            custom = CustomBLL.Instance.GetCustomDetail(custom);
            if (custom != null)
            {
                locPics = Convert.ToString(custom.CustomerLocationPics.Count);

                if (locPics != "")
                {
                    hidCount.Value = Convert.ToString(custom.CustomerLocationPics.Count);
                }
                hidProdId.Value = custom.Id.ToString();
                txtCustomer.Text = custom.Customer;
                txtProposalCost.Text = custom.ProposalCost.ToString();
                txtProposalTerm.Text = custom.ProposalTerms;
                txtspecialIns.Text = custom.SpecialInstruction;
                txtworkarea.Text = custom.WorkArea;
                txtCustSupMaterial.Text = custom.CustSuppliedMaterial;
                if (custom.CustSuppliedMaterial == "")
                    drpMaterial.SelectedItem.Text = "Select";
                else
                drpMaterial.SelectedItem.Text = custom.CustSuppliedMaterial;
                chkCustSupMaterial.Checked = custom.IsCustSupMatApplicable;
                txtStorage.Text = custom.MaterialStorage;
                if (custom.MaterialStorage == "")
                    drpStorage.SelectedItem.Text = "Select";
                else
                    drpStorage.SelectedItem.Text = custom.MaterialStorage;
                chkStorage.Checked = custom.IsMatStorageApplicable;
                chkPermit.Checked = custom.IsPermitRequired;
                chkHabitat.Checked = custom.IsHabitat;
                lnkDownload.Text = custom.Attachment;
                ViewState[SessionKey.Key.PagedataTable.ToString()] = custom.CustomerLocationPics;
                gvCategory1.DataSource = custom.CustomerLocationPics;
                gvCategory1.DataBind();
            }
        }

        private void ClearCustomData()
        {
            hidProdId.Value = null;
            hidProdType.Value = null;
            hidCount.Value = null;
            txtCustomer.Text = string.Empty;
            txtProposalCost.Text = string.Empty;
            txtProposalTerm.Text = string.Empty;
            txtspecialIns.Text = string.Empty;
            txtworkarea.Text = string.Empty;
            txtCustSupMaterial.Text = string.Empty;
            chkCustSupMaterial.Checked = false;
            txtStorage.Text = string.Empty;
            chkStorage.Checked = false;
            chkPermit.Checked = false;
            chkHabitat.Checked = false;
            lnkDownload.Visible = false;
            ViewState[SessionKey.Key.PagedataTable.ToString()] = null;
            ViewState[QueryStringKey.Key.ProductTypeId.ToString()] = null;
            gvCategory1.DataSource = null;
            gvCategory1.DataBind();
        }

        protected void btnexit_Click(object sender, EventArgs e)
        {
            if (btnexit.Text == "Go Back")
            {
                Response.Redirect("~/Sr_App/Procurement.aspx");
            }
            else
            {
                Response.RedirectPermanent("~/Sr_App/home.aspx");
            }

        }

        protected void btnsave_Click(object sender, EventArgs e)
        {
            try
            {
                if (Page.IsValid)
                {
                    Customs custom = new Customs();
                    if (hidProdId.Value != "")
                    { custom.Id = Convert.ToInt32(hidProdId.Value); }
                    else { custom.Id = 0; }

                    // custom.CustomerId = Convert.ToInt16(Request.QueryString[2]);// Convert.ToInt32(Session[SessionKey.Key.CustomerId.ToString()]);
                    custom.CustomerId = Convert.ToInt32(Request.QueryString[SessionKey.Key.CustomerId.ToString()]);
                    custom.Customer = txtCustomer.Text.Trim();
                    custom.ProposalCost = decimal.Parse(txtProposalCost.Text);
                    custom.ProposalTerms = txtProposalTerm.Text.Trim();
                    custom.SpecialInstruction = txtspecialIns.Text;
                    custom.WorkArea = txtworkarea.Text;
                    custom.UserId = userId;
                    custom.ProductTypeId = this.ProductTypeId;

                    string xml = "<root>";

                    //Commented by Yogesh Keraliya : Technical intervie task#9
                    //Implemented drag and drop location image uploader so images will be stored in hidden file and from that need to get pic list
                    //List<CustomerLocationPic> pics = (List<CustomerLocationPic>)ViewState[SessionKey.Key.PagedataTable.ToString()];
                    List<CustomerLocationPic> pics = GetUploadedLocationPictures();

                    var image = pics.AsEnumerable().Take(1);
                    string mainImage = image.FirstOrDefault().LocationPicture;

                    for (int i = 0; i < pics.Count; i++)
                    {
                        xml += "<pics><pic>" + pics[i].LocationPicture + "</pic></pics>";
                    }
                    xml += "</root>";
                    custom.LocationImage = xml;
                    custom.MainImage = mainImage;
                    //if (fileAttachment.HasFile)
                    //{
                    //    if (fileAttachment.PostedFile.FileName != "")
                    //    {
                    //        custom.Attachment = fileAttachment.PostedFile.FileName;

                    //        string strFileNameWithPath = fileAttachment.PostedFile.FileName;
                    //        string strExtensionName = System.IO.Path.GetExtension(strFileNameWithPath);
                    //        string strFileName = System.IO.Path.GetFileName(strFileNameWithPath);
                    //        custom.Attachment = strFileName;
                    //        int intFileSize = fileAttachment.PostedFile.ContentLength;

                    //        if (intFileSize > 0)
                    //        {
                    //            if (File.Exists(Server.MapPath("~/UploadedFiles/") + strFileName) == true)
                    //            {
                    //                File.Delete(Server.MapPath("~/UploadedFiles/") + strFileName);
                    //                fileAttachment.PostedFile.SaveAs(Server.MapPath("~/UploadedFiles/") + strFileName);
                    //            }
                    //            else
                    //            {
                    //                fileAttachment.PostedFile.SaveAs(Server.MapPath("~/UploadedFiles/") + strFileName);
                    //            }
                    //        }
                    //    }
                    //}
                    //else
                    //{
                    //    if (lnkDownload.Visible)
                    //    {
                    //        custom.Attachment = lnkDownload.Text;
                    //    }
                    //    else { custom.Attachment = string.Empty; }
                    //}

                    if (lnkDownload.Text != "")
                    {
                        custom.Attachment = lnkDownload.Text;
                    }
                    else { custom.Attachment = string.Empty; }
                    // custom.CustSuppliedMaterial = txtCustSupMaterial.Text.Trim();

                    if (drpMaterial.SelectedItem.Text == "other")
                    custom.CustSuppliedMaterial = txtCustSupMaterial.Text.Trim();
                    else if (drpMaterial.SelectedItem.Text == "Select")
                        custom.CustSuppliedMaterial = "";
                    else

                        custom.CustSuppliedMaterial = drpMaterial.SelectedItem.Text;
                    custom.IsCustSupMatApplicable = chkCustSupMaterial.Checked;
                    //custom.MaterialStorage = txtStorage.Text.Trim();
                    if (drpStorage.SelectedItem.Text == "other")

                        custom.MaterialStorage = txtStorage.Text.Trim();
                    else if (drpStorage.SelectedItem.Text == "Select")
                        custom.MaterialStorage = "";
                    else
                        custom.MaterialStorage = drpStorage.SelectedItem.Text;
                    custom.IsMatStorageApplicable = chkStorage.Checked;
                    custom.IsPermitRequired = chkPermit.Checked;
                    custom.IsHabitat = chkHabitat.Checked;
                    custom.Others = OtherText;
                    bool result = CustomBLL.Instance.AddCustom(custom);

                    Session["Proposal"] = txtProposalTerm.Text;

                    if (result && custom.Id == 0)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "AlertBox", "alert('Product has been added successfully.');", true);
                        ClearCustomData();
                        // Response.Redirect("~/Sr_App/ProductEstimate.aspx?CustomerId=" + custom.CustomerId, false);
                        Response.Redirect("~/Sr_App/ProductEstimate.aspx", false);
                    }
                    else if (result && custom.Id > 0)
                    {

                        ScriptManager.RegisterStartupScript(this, this.GetType(), "AlertBox", "alert('Product has been updated successfully.');", true);
                        ClearCustomData();
                        // Response.Redirect("~/Sr_App/ProductEstimate.aspx?CustomerId=" + custom.CustomerId, false);
                        Response.Redirect("~/Sr_App/ProductEstimate.aspx", false);
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "AlertBox", "alert('Unable to add Product.');", true);
                        ClearCustomData();
                    }

                }
            }
            catch (Exception ex)
            {
                logManager.writeToLog(ex, "Custom", Request.ServerVariables["remote_addr"].ToString());
            }
        }

        /// <summary>
        /// Get location pictures uploaded by user from hidden filed.
        /// Created By: Yogesh K
        /// Created Date: 06/17/2016
        /// </summary>
        /// <returns>List of CustomerLocationPic</returns>
        private List<CustomerLocationPic> GetUploadedLocationPictures()
        {
            List<CustomerLocationPic> pics = new List<CustomerLocationPic>();

            //check if any image is uplopaded by customer or not.
            if (!String.IsNullOrEmpty(locimages.Value))
            {
                String[] locationPics = locimages.Value.Split(new char[] { '^' }, StringSplitOptions.RemoveEmptyEntries);

                for (int i = 0; i < locationPics.Length; i++)
                {
                    pics.Add(new CustomerLocationPic { RowSerialNo = i + 1, LocationPicture = locationPics[i] });
                }

                locimages.Value = string.Empty;
            }

            return pics;
        }

        protected void btnImageUploadClick_Click(object sender, EventArgs e)
        {
            var ImageList = CustomerLocationPicturesList;
        }
        protected void AsyncFileUploadCustomerAttachment_UploadedComplete(object sender, AsyncFileUploadEventArgs e)
        {
            string imageName = Path.GetFileName(AsyncFileUploadCustomerAttachment.FileName);

            if (File.Exists(Server.MapPath("~/UploadedFiles/") + imageName) == true)
            {
                File.Delete(Server.MapPath("~/UploadedFiles/") + imageName);
            }
            AsyncFileUploadCustomerAttachment.SaveAs(Server.MapPath("~/UploadedFiles/" + imageName));
            lnkDownload.Visible = true;
            lnkDownload.Text = imageName;

        }
        protected void ajaxFileUpload_UploadedComplete(object sender, AsyncFileUploadEventArgs e)
        {
            if (ValidateImageUpload(Path.GetFileName(ajaxFileUpload.FileName)))
            {
                int srNo = 1;
                List<CustomerLocationPic> pics = null;
                string imageName = Path.GetFileName(ajaxFileUpload.FileName);
                string tempImageName = Guid.NewGuid() + "-" + imageName;
                ajaxFileUpload.SaveAs(Server.MapPath("~/CustomerDocs/LocationPics/" + tempImageName));
                tempImageName = "../CustomerDocs/LocationPics/" + tempImageName;
                imageName = tempImageName;
                //ajaxFileUpload.SaveAs(Server.MapPath("~/CustomerDocs/LocationPics/" + tempImageName));

                if (ViewState[SessionKey.Key.PagedataTable.ToString()] != null)
                {
                    pics = (List<CustomerLocationPic>)ViewState[SessionKey.Key.PagedataTable.ToString()];
                }
                else
                {
                    pics = new List<CustomerLocationPic>();
                }
                if (pics.Count > 0)
                {
                    srNo = pics.Count + 1;
                }
                pics.Add(new CustomerLocationPic { RowSerialNo = srNo, LocationPicture = tempImageName });

                CustomerLocationPicturesList = pics;
                hidCount.Value = pics.Count == 0 ? string.Empty : pics.Count.ToString();
                imglocation.Visible = true;
                Image.Visible = true;
                gvCategory1.DataSource = pics;
                gvCategory1.DataBind();
            }
        }
        private bool ValidateImageUpload(string fileName)
        {
            string[] extensions = { ".gif", ".png", ".jpg", ".jpeg", ".bmp", ".tif", ".tiff" };
            bool flag = false;
            for (int counter = 0; counter < extensions.Length; counter++)
            {
                if (fileName.ToLower().Contains(extensions[counter]))
                {
                    flag = true;
                    break;
                }
            }
            List<CustomerLocationPic> pics = CustomerLocationPicturesList;
            if (pics != null && Convert.ToInt32(pics.Count) >= 5)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "showalert", "alert('" + "You can not upload image more than five." + "');", true);
                return false;
            }
            if (!flag)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "showalert", "alert('" + "Invalid formats are not allowed." + "');", true);
                return false;
            }
            return flag;
        }
        protected void bntAdd_Click(object sender, EventArgs e)
        {
            //LoadImage();
        }

        protected void gvCategory_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "DeleteRec")
            {
                //int Id = Convert.ToInt32(e.CommandArgument.ToString());
                //List<CustomerLocationPic> pics = (List<CustomerLocationPic>)ViewState[SessionKey.Key.PagedataTable.ToString()];
                //pics.Remove(pics.FirstOrDefault(id => id.RowSerialNo == Id));
                //ViewState[SessionKey.Key.PagedataTable.ToString()] = pics;
                //hidCount.Value = "";
                //hidCount.Value = pics.Count.ToString();
                //gvCategory.DataSource = pics;
                //gvCategory.DataBind();
                gvCategory1.DataSource = ViewState[SessionKey.Key.PagedataTable.ToString()];
                gvCategory1.DataBind();
            }
        }

        protected void gvCategory_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                CustomerLocationPic dr = (CustomerLocationPic)e.Row.DataItem;
                string strImage = dr.LocationPicture;
                //((Image)(e.Row.FindControl("imglocation"))).ImageUrl = "~/CustomerDocs/LocationPics/" + strImage;
            }
        }

        protected void gvCategory_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            //gvCategory1.PageIndex = e.NewPageIndex;
            //gvCategory1.DataSource = ViewState[SessionKey.Key.PagedataTable.ToString()];
            //gvCategory1.DataBind();
        }

        protected void lnkDownload_Click(object sender, EventArgs e)
        {
            string fileName = lnkDownload.Text.Trim();

            Response.ContentType = "application/octet-stream";
            Response.AddHeader("Content-Disposition", "attachment;filename=\"" + fileName + "\"");
            Response.TransmitFile("~/UploadedFiles/" + fileName);
            Response.End();
        }

        protected void chkCustSupMaterial_CheckedChanged(object sender, EventArgs e)
        {
            if (chkCustSupMaterial.Checked == true)
            {
                txtCustSupMaterial.Enabled = false;
                drpMaterial.Enabled = false;
                txtCustSupMaterial.Text = "";
            }
            else
            {
                txtCustSupMaterial.Enabled = true;
                drpMaterial.Enabled = true;
                txtCustSupMaterial.Text = "";
            }
        }

        protected void chkStorage_CheckedChanged(object sender, EventArgs e)
        {
            if (chkStorage.Checked == true)
        {
                txtStorage.Enabled = false;
                drpStorage.Enabled = false;
                txtStorage.Text = "";
            }
            else
            {
                txtStorage.Enabled = true;
                drpStorage.Enabled = true;
                txtStorage.Text = "";
            }
        }

      

        protected void gvCategory1_ItemCommand(object source, DataListCommandEventArgs e)
        {
            if (e.CommandName == "DeleteRec")
            {
                int Id = Convert.ToInt32(e.CommandArgument.ToString());
                List<CustomerLocationPic> pics = (List<CustomerLocationPic>)ViewState[SessionKey.Key.PagedataTable.ToString()];
                pics.Remove(pics.FirstOrDefault(id => id.RowSerialNo == Id));
                ViewState[SessionKey.Key.PagedataTable.ToString()] = pics;
                hidCount.Value = "";
                hidCount.Value = pics.Count.ToString();
                if (hidCount.Value=="0")
                { imglocation.Visible = false;
                    imglocation.ImageUrl = "";
                    Image.Visible = false;
                }
                    
                gvCategory1.DataSource = pics;
                gvCategory1.DataBind();
               
            }

            if (e.CommandName == "ShowRec")
            {
                int Id = Convert.ToInt32(e.CommandArgument.ToString());
                List<CustomerLocationPic> pics = (List<CustomerLocationPic>)ViewState[SessionKey.Key.PagedataTable.ToString()];
                
                CustomerLocationPic pics1 = pics.FirstOrDefault(id => id.RowSerialNo == Id);//.Single<CustomerLocationPic>();
                string strImage = pics1.LocationPicture;
                imglocation.ImageUrl = strImage;
                
            }
            
        }

        protected void gvCategory1_ItemDataBound(object sender, DataListItemEventArgs e)
        {
            if (e.Item.ItemType ==  ListItemType.Item)
            {
                CustomerLocationPic dr = (CustomerLocationPic)e.Item.DataItem;
                string strImage = dr.LocationPicture;
                imglocation.ImageUrl = strImage;
                //((Image)(e.Row.FindControl("imglocation"))).ImageUrl = "~/CustomerDocs/LocationPics/" + strImage;
            }
        }

        

        protected void drpMaterial_TextChanged(object sender, EventArgs e)
        {

            DropDownList drp = sender as DropDownList;
            if (drp.SelectedItem.Value == "other")
                txtCustSupMaterial.Visible = true;
            else
                txtCustSupMaterial.Visible = false;
        }
        
        protected void drpStorage_TextChanged(object sender, EventArgs e)
        {
            DropDownList drp = sender as DropDownList;
            if (drp.SelectedItem.Value == "other")
                txtStorage.Visible = true;
            else
                txtStorage.Visible = false;
        }
    }
}
