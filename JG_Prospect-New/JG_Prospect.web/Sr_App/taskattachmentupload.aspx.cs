﻿
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
    public partial class taskattachmentupload : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                SaveUploadedFile(Request.Files);
            }
        }
        
        /// <summary>
        /// Save all uploaded image
        /// </summary>
        /// <param name="httpFileCollection"></param>
        public void SaveUploadedFile(HttpFileCollection httpFileCollection)
        {
            //bool isSavedSuccessfully = true;
            //string fName = "";
            foreach (string fileName in httpFileCollection)
            {
                HttpPostedFile file = httpFileCollection.Get(fileName);
                UploadAttachment(file);                
            }                   
        }
        
        public void UploadAttachment(HttpPostedFile file)
        {
                       
            if (file != null && file.ContentLength > 0)
            {
                var originalDirectory = new DirectoryInfo(Server.MapPath("~/TaskAttachments"));

                string imageName = Path.GetFileName(file.FileName);
                string NewImageName = Guid.NewGuid() + "-" + imageName;

                string pathString = System.IO.Path.Combine(originalDirectory.ToString(),NewImageName);

                bool isExists = System.IO.Directory.Exists(originalDirectory.ToString());

                if (!isExists)
                    System.IO.Directory.CreateDirectory(originalDirectory.ToString());
                
                file.SaveAs(pathString);
                Response.Write(NewImageName + "^");
            }                          
        }

        [WebMethod]
        public static string RemoveUploadedattachment(string serverfilename)
        {
            var originalDirectory = new DirectoryInfo(HttpContext.Current.Server.MapPath("~/TaskAttachments"));
                        
            string pathString = System.IO.Path.Combine(originalDirectory.ToString(), serverfilename);

            bool isExists = System.IO.File.Exists(pathString);

            if (isExists)
                File.Delete(pathString);

            return serverfilename;
        }
        

    }
}