using JG_Prospect.BLL;
using JG_Prospect.Common;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.IO;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace JG_Prospect.App_Code
{

    public enum TaskStatus
    {
        Open = 1,
        Requested = 2,
        Assigned = 3,
        InProgress = 4,
        Pending = 5,
        ReOpened = 6,
        Closed = 7
    }

    public enum TaskType
    {
        Bug = 1,
        BetaError = 2,
        Enhancement = 3
    }


    public static class CommonFunction
    {
        /// <summary>
        /// Call to show javascript alert message from page.
        /// </summary>
        /// <param name="page">Pass page obect of current page. i.e. this.Page</param>
        /// <param name="MessageString">Message which needs to display inside alert</param>
        public static void ShowAlertFromPage(Page page, String MessageString)
        {
            page.ClientScript.RegisterStartupScript(page.GetType(), "alert", String.Concat("alert('", MessageString, "');"), true);
        }

        /// <summary>
        /// Call to show javascript alert message from update panel inside page.
        /// </summary>
        /// <param name="page">Pass page obect of current page. i.e. this.Page</param>
        /// <param name="MessageString">Message which needs to display inside alert</param>
        public static void ShowAlertFromUpdatePanel(Page page, String MessageString)
        {
            ScriptManager.RegisterStartupScript(page, page.GetType(), "alert", String.Concat("alert('", MessageString, "');"), true);
        }

        public static string FormatToShortDateString(object dateobject)
        {
            string formateddatetime = string.Empty;
            DateTime date;

            if (dateobject != null && DateTime.TryParse(dateobject.ToString(), out date))
            {
                formateddatetime = date.ToString("MM/dd/yyyy");
            }

            return formateddatetime;
        }

        public static string FormatDateTimeString(object dateobject)
        {
            string formateddatetime = string.Empty;
            DateTime date;

            if (dateobject != null && DateTime.TryParse(dateobject.ToString(), out date))
            {
                formateddatetime = date.ToString("hh:mm tt MM/dd/yyyy");
            }

            return formateddatetime;
        }

        public static void AuthenticateUser()
        {
            if (!JGSession.IsActive)
            {
                HttpContext.Current.Response.Redirect("~/login.aspx?returnurl=" + HttpContext.Current.Request.Url.PathAndQuery);
            }
        }

        /// <summary>
        /// Used in task related controls to enable / disable features based on user type.
        /// Admin, Office manager, Sales Managers, Tech Leads, IT Enginners, Foremans are given Admin rights for task controls.
        /// </summary>
        /// <returns></returns>
        public static bool CheckAdminMode()
        {
            // Please refer InstallCreateProspect.ascx.cs control to find list of available designations for install user in BindDesignation method.

            bool returnVal = false;
            if (HttpContext.Current.Session["DesigNew"] != null)
            {
                switch (HttpContext.Current.Session["DesigNew"].ToString().ToUpper())
                {
                    case "ADMIN": // admin
                    case "OFFICE MANAGER": // office manager
                    case "SALES MANAGER": // sales manager
                    case "ITLEAD": // it engineer | tech lead
                    case "FOREMAN": // foreman
                        returnVal = true;
                        break;
                    default: // other designations
                        returnVal = false;
                        break;
                }
            }
            //if (HttpContext.Current.Session["DesigNew"] != null && HttpContext.Current.Session["DesigNew"].ToString().Contains("Admin"))
            //{
            //    returnVal = true;
            //}

            return returnVal;
        }

        /// <summary>
        /// Used in task related controls to enable / disable features based on user type.
        /// Admin, Tech Leads are given different default values for task controls.
        /// </summary>
        /// <returns></returns>
        public static bool CheckAdminAndItLeadMode()
        {
            // Please refer InstallCreateProspect.ascx.cs control to find list of available designations for install user in BindDesignation method.

            bool returnVal = false;
            if (HttpContext.Current.Session["DesigNew"] != null)
            {
                switch (HttpContext.Current.Session["DesigNew"].ToString().ToUpper())
                {
                    case "ADMIN": // admin
                    case "ITLEAD": // it engineer | tech lead
                        returnVal = true;
                        break;
                    default: // other designations
                        returnVal = false;
                        break;
                }
            }

            return returnVal;
        }

        /// <summary>
        /// Sends an email.
        /// </summary>
        /// <param name="strEmailTemplate"></param>
        /// <param name="strToAddress">it will receive email.</param>
        /// <param name="strSubject">subject line of email.</param>
        /// <param name="strBody">contect / body of email.</param>
        /// <param name="lstAttachments">any files to be attached to email.</param>
        public static void SendEmail(string strEmailTemplate, string strToAddress, string strSubject, string strBody, List<Attachment> lstAttachments)
        {
            try
            {
                /* Sample HTML Template
                 * *****************************************************************************
                 * Hi #lblFName#,
                 * <br/>
                 * <br/>
                 * You are requested to appear for an interview on #lblDate# - #lblTime#.
                 * <br/>
                 * <br/>
                 * Regards,
                 * <br/>
                */

                string userName = ConfigurationManager.AppSettings["VendorCategoryUserName"].ToString();
                string password = ConfigurationManager.AppSettings["VendorCategoryPassword"].ToString();

                MailMessage Msg = new MailMessage();
                Msg.From = new MailAddress(userName, "JGrove Construction");
                Msg.To.Add(strToAddress);
                Msg.CC.Add(new MailAddress("jgrove.georgegrove@gmail.com", "Justin Grove"));
                Msg.Subject = strSubject;// "JG Prospect Notification";
                Msg.Body = strBody;
                Msg.IsBodyHtml = true;

                //ds = AdminBLL.Instance.GetEmailTemplate('');
                //// your remote SMTP server IP.
                foreach (Attachment objAttachment in lstAttachments)
                {
                    Msg.Attachments.Add(objAttachment);
                }
                SmtpClient sc = new SmtpClient(
                                                ConfigurationManager.AppSettings["smtpHost"].ToString(),
                                                Convert.ToInt32(ConfigurationManager.AppSettings["smtpPort"].ToString())
                                              );
                NetworkCredential ntw = new NetworkCredential(userName, password);
                sc.UseDefaultCredentials = false;
                sc.Credentials = ntw;
                sc.DeliveryMethod = SmtpDeliveryMethod.Network;
                sc.EnableSsl = Convert.ToBoolean(ConfigurationManager.AppSettings["enableSSL"].ToString()); // runtime encrypt the SMTP communications using SSL
                try
                {
                    sc.Send(Msg);
                }
                catch (Exception ex)
                {
                    // throw will call application error event, which will log error details.
                    throw ex;
                }

                Msg = null;
                sc.Dispose();
                sc = null;
            }
            catch (Exception ex)
            {
                // throw will call application error event, which will log error details.
                throw ex;
            }
        }

        /// <summary>
        /// Sends an internal email.
        /// </summary>
        /// <param name="strEmailTemplate"></param>
        /// <param name="strToAddress">it will receive email.</param>
        /// <param name="strSubject">subject line of email.</param>
        /// <param name="strBody">contect / body of email.</param>
        public static void SendEmailInternal(string strToAddress, string strSubject, string strBody)
        {
            try
            {
                string userName = ConfigurationManager.AppSettings["VendorCategoryUserName"].ToString();
                string password = ConfigurationManager.AppSettings["VendorCategoryPassword"].ToString();

                MailMessage Msg = new MailMessage();
                Msg.From = new MailAddress(userName, "JGrove Construction");
                foreach (string strEmailAddress in strToAddress.Split(new char[] { ';' }, StringSplitOptions.RemoveEmptyEntries))
                {
                    Msg.To.Add(strEmailAddress);
                }

                Msg.Subject = strSubject;// "JG Prospect Notification";
                Msg.Body = strBody;
                Msg.IsBodyHtml = true;

                SmtpClient sc = new SmtpClient(
                                                ConfigurationManager.AppSettings["smtpHost"].ToString(),
                                                Convert.ToInt32(ConfigurationManager.AppSettings["smtpPort"].ToString())
                                              );
                NetworkCredential ntw = new NetworkCredential(userName, password);
                sc.UseDefaultCredentials = false;
                sc.Credentials = ntw;
                sc.DeliveryMethod = SmtpDeliveryMethod.Network;
                sc.EnableSsl = Convert.ToBoolean(ConfigurationManager.AppSettings["enableSSL"].ToString()); // runtime encrypt the SMTP communications using SSL
                try
                {
                    sc.Send(Msg);
                }
                catch (Exception ex)
                {

                }

                Msg = null;
                sc.Dispose();
                sc = null;
            }
            catch
            {
                // do not add throw clause here.
                // it will lead to infinite loop.
                // because application error event calls this method to send error details.
                // here, we need to supress the exception.
            }
        }

        /// <summary>
        /// Gets contract tamplate content string by combining header, body and footer.
        /// </summary>
        /// <returns></returns>
        public static string GetContractTemplateContent(int intContractTemplateId, int intDesignationId = 0, String designation = "IT - Sr .Net Developer")
        {
            DataSet ds1 = AdminBLL.Instance.FetchContractTemplate(intContractTemplateId, intDesignationId);
            string strHtml = string.Empty;
            if (ds1 != null)
            {

                DataTable htmlData = (from myRow in ds1.Tables[1].AsEnumerable()
                                      where myRow.Field<string>("Designation") == designation
                                      select myRow).CopyToDataTable();

                if (htmlData.Rows.Count > 0)
                {
                    strHtml = string.Concat(
                                                   htmlData.Rows[0]["HTMLHeader"].ToString(),
                                                   htmlData.Rows[0]["HTMLBody"].ToString(),
                                                   htmlData.Rows[0]["HTMLBody2"].ToString(),
                                                   htmlData.Rows[0]["HTMLFooter"].ToString()
                                                  );
                }
                else
                {
                    strHtml = string.Concat(
                                                   ds1.Tables[1].Rows[0]["HTMLHeader"].ToString(),
                                                   ds1.Tables[1].Rows[0]["HTMLBody"].ToString(),
                                                   ds1.Tables[1].Rows[0]["HTMLBody2"].ToString(),
                                                   ds1.Tables[1].Rows[0]["HTMLFooter"].ToString()
                                                  );
                }
                // this creates a warpper to limit width of all the sections.
                strHtml = "<table width='100%' cellpadding='0' cellspacing='0' border='0'><tr><td>" + strHtml + "</td></tr></table>";
            }
            return strHtml;
        }

        /// <summary>
        /// Converts html to pdf file and retunrs pdf file path.
        /// </summary>
        /// <param name="strHtml">Html content to include in pdf.</param>
        /// <param name="strRootPath">Folder path to store generated pdf.</param>
        /// <returns>Path to the generated pdf file.</returns>
        public static string ConvertHtmlToPdf(string strHtml, string strRootPath, string strFileName)
        {
            iTextSharp.text.Document objDocument = new iTextSharp.text.Document();
            string strFilePath = Path.Combine(strRootPath, string.Format("{0} {1}.pdf", strFileName, DateTime.Now.ToString("dd-MM-yyyy hh-mm-ss-tt")));

            try
            {
                iTextSharp.text.pdf.PdfWriter objPdfWriter = iTextSharp.text.pdf.PdfWriter.GetInstance
                        (
                            objDocument,
                            new FileStream(strFilePath, FileMode.Create)
                        );

                objDocument.Open();

                iTextSharp.tool.xml.XMLWorkerHelper.GetInstance().ParseXHtml
                        (
                            objPdfWriter,
                            objDocument,
                            new StringReader(strHtml)
                        );

                objDocument.Close();

                return strFilePath;
            }
            catch
            { }
            finally
            {
                if (objDocument != null)
                {
                    objDocument.Close();
                }
                objDocument = null;
            }
            return string.Empty;
        }

        /// <summary>
        /// Converts html to pdf file stream and retunrs bytes.
        /// </summary>
        /// <param name="strHtml">Html content to include in pdf.</param>
        /// <returns>Bytes to generate pdf file.</returns>
        public static byte[] ConvertHtmlToPdf(string strHtml)
        {
            iTextSharp.text.Document objDocument = new iTextSharp.text.Document();

            try
            {
                MemoryStream objMemoryStream = new MemoryStream();
                iTextSharp.text.pdf.PdfWriter objPdfWriter = iTextSharp.text.pdf.PdfWriter.GetInstance
                        (
                            objDocument,
                            objMemoryStream
                        );

                objDocument.Open();

                iTextSharp.tool.xml.XMLWorkerHelper.GetInstance().ParseXHtml
                        (
                            objPdfWriter,
                            objDocument,
                            new StringReader(strHtml)
                        );

                objDocument.Close();

                return objMemoryStream.ToArray();
            }
            catch
            { }
            finally
            {
                if (objDocument != null)
                {
                    objDocument.Close();
                }
                objDocument = null;
            }
            return null;
        }

        /// <summary>
        /// Generate subtask auto suggest sequence.
        /// </summary>
        /// <param name="sequence"></param>
        /// <returns></returns>
        public static string[] getSubtaskSequencing(string sequence)
        {
            String[] ReturnSequence = new String[2];

            String[] numbercomponents = sequence.Split(new char[] { '-' }, StringSplitOptions.RemoveEmptyEntries);

            //if no subtask sequence than start with roman number I.
            if (String.IsNullOrEmpty(sequence))
            {
                int startSequence = 1;
                ReturnSequence[0] = ExtensionMethods.ToRoman(startSequence);
                ReturnSequence[1] = string.Empty;
            }
            else if (numbercomponents.Length == 1) // like number of subtask without alphabet I,II
            {
                int numbersequence;
                numbercomponents[0] = numbercomponents[0].Trim();
                bool parsed = ExtensionMethods.TryRomanParse(numbercomponents[0], out numbersequence);
                if (parsed)
                {
                    numbersequence++;

                    ReturnSequence[0] = ExtensionMethods.ToRoman(numbersequence); // increment integer and convert to roman number again.
                    ReturnSequence[1] = String.Concat(numbercomponents[0], " - a"); // concat existing roman number with alphabet.
                }
            }
            else  // if task sequence contains alphabet.
            {
                int numbersequence;
                numbercomponents[0] = numbercomponents[0].Trim();
                numbercomponents[1] = numbercomponents[1].Trim();


                char[] alphabetsequence = numbercomponents[1].ToCharArray();// get aplphabet from sequence

                bool parsed = ExtensionMethods.TryRomanParse(numbercomponents[0], out numbersequence); // parse roman to integer

                if (parsed)
                {
                    numbersequence++; // increase integer sequence

                    ReturnSequence[0] = ExtensionMethods.ToRoman(numbersequence); // convert integer sequnce to roman
                    ReturnSequence[1] = string.Concat(numbercomponents[0], " - ", ++alphabetsequence[0]); // advance alphabet to next alphabet.
                }
            }

            return ReturnSequence;
        }

        /// <summary>
        /// Gets next sequence value based on current value.
        /// </summary>
        /// <param name="strStartAt">First value of sequence. i.e. A, 1, I.</param>
        /// <param name="strCurrentSequence">current sequence number. i.e. C, 5, III.</param>
        /// <param name="blIsRoman">I can be an alphabet as well as a romal number. This flag is used to differenciate both.</param>
        /// <returns>
        /// input  : ouput
        ///    ''  :     A
        ///     1  :     2 
        ///     A  :     B 
        ///     Z  :    AA 
        ///    A1  :    A2
        ///    Z1  :    Z2
        ///    A9  :   AA0
        ///    Z9  :   AZ0
        ///    A-  :   A-0
        ///    Z-  :   Z-0
        /// </returns>
        public static string GetTaskWorkSpecificationSequence(string strStartAt, string strCurrentSequence = "", bool blIsRoman = false)
        {
            string strReturnValue = strStartAt.ToString();

            if (!string.IsNullOrEmpty(strCurrentSequence))
            {
                string strPrefix = string.Empty;

                char chInputPostfix = strCurrentSequence[strCurrentSequence.Length - 1];
                string strPostfix = chInputPostfix.ToString();
                if (strCurrentSequence.Length > 1)
                {
                    strPrefix = strCurrentSequence.Substring(0, strCurrentSequence.Length - 1);
                }

                int intaCode = (int)'a';
                int intzCode = (int)'z';
                int intACode = (int)'A';
                int intZCode = (int)'Z';
                int intInputCode = (int)chInputPostfix;

                int intNumber;

                if (blIsRoman && ExtensionMethods.TryRomanParse(strCurrentSequence, out intNumber))
                {
                    return ExtensionMethods.ToRoman((++intNumber));
                }
                else if (Char.IsDigit(chInputPostfix))
                {
                    intNumber = (int)Char.GetNumericValue(chInputPostfix);

                    if (intNumber == 9)
                    {
                        strPrefix = "A" + strPrefix;
                        //chInputPostfix = chStartAt;
                        strPostfix = strStartAt;
                    }
                    else
                    {
                        //chInputPostfix = (++intNumber).ToString()[0];
                        strPostfix = (++intNumber).ToString();
                    }
                }
                else if (
                            (intInputCode >= intaCode && intInputCode <= intzCode) ||
                            (intInputCode >= intACode && intInputCode <= intZCode)
                        )
                {
                    if (intInputCode == intzCode || intInputCode == intZCode)
                    {
                        strPrefix = "A" + strPrefix;
                        //chInputPostfix = chStartAt;
                        strPostfix = strStartAt;
                    }
                    else
                    {
                        //chInputPostfix = (char)(++intInputCode);
                        strPostfix = ((char)(++intInputCode)).ToString();
                    }
                }
                else
                {
                    strPrefix = strPrefix + chInputPostfix;
                    //chInputPostfix = chStartAt;
                    strPostfix = strStartAt;
                }

                //strReturnValue = strPrefix + chInputPostfix;
                strReturnValue = strPrefix + strPostfix;
            }

            return strReturnValue;
        }

        public static System.Web.UI.WebControls.ListItemCollection GetTaskStatusList()
        {
            ListItemCollection objListItemCollection = new ListItemCollection();

            objListItemCollection.Add(new ListItem("Open", Convert.ToByte(JGConstant.TaskStatus.Open).ToString()));
            objListItemCollection.Add(new ListItem("Requested", Convert.ToByte(JGConstant.TaskStatus.Requested).ToString()));
            objListItemCollection.Add(new ListItem("Assigned", Convert.ToByte(JGConstant.TaskStatus.Assigned).ToString()));
            objListItemCollection.Add(new ListItem("In Progress", Convert.ToByte(JGConstant.TaskStatus.InProgress).ToString()));
            objListItemCollection.Add(new ListItem("Pending", Convert.ToByte(JGConstant.TaskStatus.Pending).ToString()));
            objListItemCollection.Add(new ListItem("Re-Opened", Convert.ToByte(JGConstant.TaskStatus.ReOpened).ToString()));
            objListItemCollection.Add(new ListItem("Closed", Convert.ToByte(JGConstant.TaskStatus.Closed).ToString()));
            objListItemCollection.Add(new ListItem("Specs In Progress", Convert.ToByte(JGConstant.TaskStatus.SpecsInProgress).ToString()));

            if (CheckAdminAndItLeadMode())
            {
                objListItemCollection.Add(new ListItem("Deleted", Convert.ToByte(JGConstant.TaskStatus.Deleted).ToString()));
            }

            return objListItemCollection;
        }

        public static System.Web.UI.WebControls.ListItemCollection GetTaskTypeList()
        {
            ListItemCollection objListItemCollection = new ListItemCollection();

            objListItemCollection.Add(new ListItem("--None--", "0"));
            objListItemCollection.Add(new ListItem("Bug", Convert.ToInt16(JGConstant.TaskType.Bug).ToString()));
            objListItemCollection.Add(new ListItem("BetaError", Convert.ToInt16(JGConstant.TaskType.BetaError).ToString()));
            objListItemCollection.Add(new ListItem("Enhancement", Convert.ToInt16(JGConstant.TaskType.Enhancement).ToString()));

            //objListItemCollection[1].Enabled = false;
            return objListItemCollection;
        }

        public static System.Web.UI.WebControls.ListItemCollection GetTaskPriorityList()
        {
            ListItemCollection objListItemCollection = new ListItemCollection();

            objListItemCollection.Add(new ListItem("--None--", "0"));
            objListItemCollection.Add(new ListItem("Critical", Convert.ToInt16(JGConstant.TaskPriority.Critical).ToString()));
            objListItemCollection.Add(new ListItem("High", Convert.ToInt16(JGConstant.TaskPriority.High).ToString()));
            objListItemCollection.Add(new ListItem("Medium", Convert.ToInt16(JGConstant.TaskPriority.Medium).ToString()));
            objListItemCollection.Add(new ListItem("Low", Convert.ToInt16(JGConstant.TaskPriority.Low).ToString()));

            return objListItemCollection;
        }

        public static bool IsImageFile(string fileName)
        {
            bool isImageFile = false;
            string fileExtension = Path.GetExtension(fileName).ToLower();

            if (fileExtension.Contains(".jpg") || fileExtension.Contains(".jpeg") || fileExtension.Contains(".bmp") || fileExtension.Contains(".gif") || fileExtension.Contains(".png"))
            {
                isImageFile = true;
            }
            return isImageFile;
        }

        public static string GetFileTypeIcon(string FileName)
        {
            string fileExtension = Path.GetExtension(FileName).ToLower();

            string iconFile = string.Empty;

            switch (fileExtension)
            {
                case ".zip":
                case ".rar":
                    iconFile = "/img/zip-icon.png";
                    break;
                case ".mp3":
                case ".wav":
                case ".m4a":
                    iconFile = "/img/audio-icon.png";
                    break;
                case ".wmv":
                case ".avi":
                case ".mov":
                case ".mpg":
                case ".mp4":
                    iconFile = "/img/video-icon.png";
                    break;
                case ".pdf":
                    iconFile = "/img/pdf-icon.png";
                    break;
                case ".xlsx":
                case ".xls":
                    iconFile = "/img/excel-icon.png";
                    break;
                case ".txt":
                case ".rtf":
                case ".docx":
                case ".doc":
                    iconFile = "/img/word-icon.png";
                    break;
                case ".png":
                case ".jpg":
                case ".jpeg":
                case ".bmp":
                case ".gif":
                default:
                    break;
            }
            return iconFile;
        }
        public static string CreatePassword(int length)
        {
            const string valid = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
            StringBuilder res = new StringBuilder();
            Random rnd = new Random();
            while (0 < length--)
            {
                res.Append(valid[rnd.Next(valid.Length)]);
            }
            return res.ToString();
        }
    }
}

namespace JG_Prospect
{

    public static class JGSession
    {
        public static bool IsActive
        {
            get
            {
                if (HttpContext.Current.Session == null || JGSession.UserId == 0)
                {
                    return false;
                }
                return true;
            }
        }

        public static Int32 UserId
        {
            get
            {
                if (HttpContext.Current.Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()] == null)
                {
                    return 0;
                }
                return Convert.ToInt32(HttpContext.Current.Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]);
            }
            set
            {
                HttpContext.Current.Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()] = value;
            }
        }

        public static string Username
        {
            get
            {
                if (HttpContext.Current.Session["Username"] == null)
                    return null;
                return Convert.ToString(HttpContext.Current.Session["Username"]);
            }
            set
            {
                HttpContext.Current.Session["Username"] = value;
            }
        }

        public static string UserProfileImg
        {
            get
            {
                if (HttpContext.Current.Session["UserProfileImg"] == null || HttpContext.Current.Session["UserProfileImg"].ToString() == "")
                    return "../img/JG-Logo-white.gif";
                else
                    return Convert.ToString(HttpContext.Current.Session["UserProfileImg"]);
            }
            set
            {
                HttpContext.Current.Session["UserProfileImg"] = value;
            }
        }

        public static string LoginUserID
        {
            get
            {
                if (HttpContext.Current.Session["LoginUserID"] == null)
                    return null;
                return Convert.ToString(HttpContext.Current.Session["LoginUserID"]);
            }
            set
            {
                HttpContext.Current.Session["LoginUserID"] = value;
            }
        }



        public static bool? IsInstallUser
        {
            get
            {
                if (HttpContext.Current.Session["IsInstallUser"] == null)
                    return null;
                return Convert.ToBoolean(HttpContext.Current.Session["IsInstallUser"]);
            }
            set
            {
                HttpContext.Current.Session["IsInstallUser"] = value;
            }
        }
    }
}