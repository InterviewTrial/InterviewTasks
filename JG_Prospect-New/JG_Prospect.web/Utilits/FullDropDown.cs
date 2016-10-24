using JG_Prospect.BLL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI.WebControls;

namespace JG_Prospect.Utilits
{
    /// <summary>
    /// Class is only Responsible for filling dropdown only
    /// </summary>
    public class FullDropDown
    {
        /// <summary>
        /// Will Fill Respective Task Task Dropdown
        /// </summary>
        /// <param name="ddlTechTask"></param>
        /// <returns></returns>
        public static DropDownList FillTechTaskDropDown(DropDownList ddlTechTask)
        {
            DataSet dsTechTask;

            dsTechTask = TaskGeneratorBLL.Instance.GetAllActiveTechTask();

            ddlTechTask.DataSource = dsTechTask;
            ddlTechTask.DataTextField = "Title";
            ddlTechTask.DataValueField = "TaskId";
            ddlTechTask.DataBind();

            return ddlTechTask;
        }

        /// <summary>
        /// Will Fill Intervals time dropsown 
        /// Copied from \Sr_App\EditUser.aspx.cs By Bhavik Vaishnani.
        /// </summary>
        /// <returns></returns>
        public static DropDownList GetTimeIntervals(DropDownList ddlInsteviewtime)
        {
            List<string> timeIntervals = new List<string>();
            TimeSpan startTime = new TimeSpan(0, 0, 0);
            DateTime startDate = new DateTime(DateTime.MinValue.Ticks); // Date to be used to get shortTime format.
            for (int i = 0; i < 48; i++)
            {
                int minutesToBeAdded = 30 * i;      // Increasing minutes by 30 minutes interval
                TimeSpan timeToBeAdded = new TimeSpan(0, minutesToBeAdded, 0);
                TimeSpan t = startTime.Add(timeToBeAdded);
                DateTime result = startDate + t;
                timeIntervals.Add(result.ToShortTimeString());      // Use Date.ToShortTimeString() method to get the desired format                
            }

            ddlInsteviewtime.DataSource = timeIntervals;
            ddlInsteviewtime.DataBind();

            return ddlInsteviewtime;
        }
    }


    enum Type { notes = 1, audio = 2, video = 3, images = 4, docu = 5, other = 6 };

}