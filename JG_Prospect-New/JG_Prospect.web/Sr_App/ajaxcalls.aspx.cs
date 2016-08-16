using JG_Prospect.BLL;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace JG_Prospect.Sr_App
{
    public partial class ajaxcalls : System.Web.UI.Page
    {

        #region "-- Web Methods --"


        /// <summary>
        /// Get auto search suggestions for task generator search box.
        /// </summary>
        /// <param name="searchterm"></param>
        /// <returns>categorised search suggestions for Users, Designations, Task Title, Task Ids</returns>

        [WebMethod]
        public static string GetSearchSuggestions(string searchterm)
        {
            DataSet dsSuggestions;

            string SearchSuggestions = string.Empty;

            dsSuggestions = TaskGeneratorBLL.Instance.GetTaskSearchAutoSuggestion(searchterm);

            if (dsSuggestions != null && dsSuggestions.Tables.Count > 0 && dsSuggestions.Tables[0].Rows.Count > 0)
            {
                SearchSuggestions = JsonConvert.SerializeObject(dsSuggestions.Tables[0]);
            }

            return SearchSuggestions;
        }

        #endregion



    }
}