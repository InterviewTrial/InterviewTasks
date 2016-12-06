using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.SessionState;

namespace JG_Prospect
{
    public class Global : System.Web.HttpApplication
    {

        //void Application_AuthenticateRequest(object sender, EventArgs e)
        //{
        //    if (!JGSession.IsActive)
        //    {
        //        if (Request.Url.AbsolutePath.EndsWith(".aspx") && !Request.Url.AbsolutePath.EndsWith("login.aspx"))
        //        {
        //            Response.Redirect("~/login.aspx?returnurl=" + Request.Url.PathAndQuery);
        //        }
        //    }
        //}

        void Application_Start(object sender, EventArgs e)
        {
            // Code that runs on application startup

        }

        void Application_End(object sender, EventArgs e)
        {
            //  Code that runs on application shutdown

        }

        void Application_Error(object sender, EventArgs e)
        {
            // Code that runs when an unhandled error occurs
            if (!string.IsNullOrEmpty(System.Configuration.ConfigurationManager.AppSettings["ErrorNotificationEmailId"]))
            {
                Exception objException = Context.Error;
                if (objException != null)
                {
                    string strSubject, strBody;

                    // inner exception is the actual exception. 
                    // so, if inner exception is available, send it in email.
                    if (objException.InnerException != null)
                    {
                        strSubject = "Exception - " + objException.InnerException.Message;

                        strBody = GetExceptionHtml(objException.InnerException);
                    }
                    // send base exception details, when inner exception is not available.
                    else
                    {
                        strSubject = "Exception - " + objException.Message;

                        strBody = GetExceptionHtml(objException);
                    }

                    if (!string.IsNullOrEmpty(System.Configuration.ConfigurationManager.AppSettings["ApplicationEnvironment"]))
                    {
                        switch ((JG_Prospect.Common.JGConstant.ApplicationEnvironment)Convert.ToByte(System.Configuration.ConfigurationManager.AppSettings["ApplicationEnvironment"]))
                        {
                            case JG_Prospect.Common.JGConstant.ApplicationEnvironment.Local:
                                strSubject = "Local " + strSubject;
                                break;
                            case JG_Prospect.Common.JGConstant.ApplicationEnvironment.Staging:
                                strSubject = "Staging " + strSubject;
                                break;
                            case JG_Prospect.Common.JGConstant.ApplicationEnvironment.Live:
                                strSubject = "Live " + strSubject;
                                break;
                        }
                    }


                    if (Request != null && Request.Url != null && !string.IsNullOrEmpty(Request.Url.ToString()))
                    {
                        strBody = "<p style='padding:5px;margin:5px;'>" + Request.Url.ToString() + "</p>" + strBody;
                    }

                    // append all contents to a main table 
                    // to center align the contents and 
                    // to keep all the contents in one parent table.
                    strBody = "<table width='100%'><tr><td align='center' valign='top'>" + strBody + "</td></tr></table>";

                    JG_Prospect.App_Code.CommonFunction.SendEmailInternal
                                                            (
                                                                System.Configuration.ConfigurationManager.AppSettings["ErrorNotificationEmailId"],
                                                                strSubject,
                                                                strBody
                                                            );
                }
            }
        }

        private string GetExceptionHtml(Exception objException)
        {
            string strHtml = "";

            strHtml += "<table width='700' cellpadding='5' border='0'>";
            strHtml += "<tr>";
            strHtml += "<td valign='top'>Type:</td>";
            strHtml += "<td valign='top'>" + objException.GetType().FullName + "</td>";
            strHtml += "</tr>";
            strHtml += "<tr>";
            strHtml += "<td valign='top'>Message:</td>";
            strHtml += "<td valign='top'>" + objException.Message + "</td>";
            strHtml += "</tr>";
            strHtml += "<tr>";
            strHtml += "<td valign='top'>StackTrace:</td>";
            strHtml += "<td valign='top'>" + objException.StackTrace + "</td>";
            strHtml += "</tr>";
            strHtml += "</table>";

            return strHtml;
        }

        void Session_Start(object sender, EventArgs e)
        {
            // Code that runs when a new session is started

        }

        void Session_End(object sender, EventArgs e)
        {
            // Code that runs when a session ends. 
            // Note: The Session_End event is raised only when the sessionstate mode
            // is set to InProc in the Web.config file. If session mode is set to StateServer 
            // or SQLServer, the event is not raised.

        }

    }
}
