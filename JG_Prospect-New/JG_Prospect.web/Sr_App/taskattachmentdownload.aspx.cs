
using JG_Prospect.BLL;
using JG_Prospect.Common.modal;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;


namespace JG_Prospect.Sr_App
{
    public partial class taskattachmentdownload : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.QueryString.Count > 0 && Request.QueryString["file"] != null)
            {
                DownloadImage(Request.QueryString["file"].ToString(), Request.QueryString["Ofile"].ToString());

            }
        }
        private void DownloadImage(string file,string OriginalFileName)
        {

            string filename = String.Concat(Server.MapPath("~/TaskAttachments/") + file);

            if (File.Exists(filename))
            {
                Response.ContentType = "application/octet-stream";
                Response.AppendHeader("Content-Disposition",  String.Concat("attachment; filename=", OriginalFileName));
                Response.TransmitFile(filename);
                Response.SetCookie(new HttpCookie("fileDownload", "true") { Path = "/" });
                Response.End();
            }
        }


    }
}