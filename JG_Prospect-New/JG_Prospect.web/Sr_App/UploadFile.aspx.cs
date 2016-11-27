using System;
using System.IO;
using System.Web;
using System.Web.Services;
using JG_Prospect.Common;
using System.Web.UI;

namespace JG_Prospect.Sr_App
{
    public partial class UploadFile : System.Web.UI.Page
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
                var originalDirectory = new DirectoryInfo(Server.MapPath(JGConstant.ProfilPic_Upload_Folder));

                string imageName = Path.GetFileName(file.FileName);
                string NewImageName = DateTime.Now.Year.ToString()
                               + "_" + DateTime.Now.Month.ToString()
                               + "_" + DateTime.Now.Day.ToString() + DateTime.Now.Hour.ToString()
                               + "_" + DateTime.Now.Second.ToString() +"-" + imageName;

                //string NewImageName = Guid.NewGuid() + "-" + imageName;

                string pathString = System.IO.Path.Combine(originalDirectory.ToString(), NewImageName);

                bool isExists = System.IO.Directory.Exists(originalDirectory.ToString());

                if (!isExists)
                    System.IO.Directory.CreateDirectory(originalDirectory.ToString());

                file.SaveAs(pathString);
                Session["UplaodPicture"] = JGConstant.ProfilPic_Upload_Folder + "/" + NewImageName;
                Response.Write(NewImageName + "^");
            }
        }

        [WebMethod]
        public static string RemoveUploadedattachment(string serverfilename)
        {
            var originalDirectory = new DirectoryInfo(HttpContext.Current.Server.MapPath("~/UploadeProfile"));
                        
            string pathString = System.IO.Path.Combine(originalDirectory.ToString(), serverfilename);

            bool isExists = System.IO.File.Exists(pathString);

            if (isExists)
                File.Delete(pathString);

            return serverfilename;
        }
        

    }
}