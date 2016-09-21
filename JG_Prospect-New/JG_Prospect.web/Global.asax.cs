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
                    string strSubject = "Exception - " + objException.Message;

                    string strBody = GetExceptionHtml(objException);

                    if (objException.InnerException != null)
                    {
                        strSubject = "Exception - " + objException.InnerException.Message;

                        strBody = GetExceptionHtml(objException.InnerException);
                    }

                    strBody += "<br/><br/>";

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
            string strHtml = "<table>";
            strHtml += "<tr>";
            strHtml += "<td>Message:</td>";
            strHtml += "<td>" + objException.Message + "</td>";
            strHtml += "</tr>";
            strHtml += "<tr>";
            strHtml += "<td>StackTrace:</td>";
            strHtml += "<td>" + objException.StackTrace + "</td>";
            strHtml += "</tr>";

            if (objException.InnerException != null)
            {

            }

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
