using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using JG_Prospect.BLL;

namespace JG_Prospect.UserControl
{
    public partial class ucAuditTrailByUser : System.Web.UI.UserControl
    {
        int icount =1 ;
        #region '--Properties & variables --'

        public string UserLoginID { get; set; }

        DataSet DsAuditTrail;

        #endregion


        protected void Page_Load(object sender, EventArgs e)
        {
            if (UserLoginID != null && UserLoginID.Trim() != string.Empty)//(!this.IsPostBack)
            {
                //DtAuditTrail = GetData("SELECT * FROM [tblUserAuditTrail] "); // WHERE UserLoginID = " + UserLoginID);

                DsAuditTrail = UserAuditTrailBLL.Instance.GetAuditsTrailLstByLoginID(UserLoginID);

                DsAuditTrail = SetTabGrouping(DsAuditTrail);

                rptUserAudit.DataSource = DsAuditTrail;
                rptUserAudit.DataBind();
            }
        }

        private DataSet SetTabGrouping(DataSet dS)
        {
            DataSet dsReturn = new DataSet();

            dsReturn= dS.Clone();
            

            foreach (DataRow datarowProcess in dS.Tables[0].Rows)
            {
                //string GrpCSS = GetTimeGrpOnLoginTime(datarowProcess["LastLoginOn"].ToString());

                //Set Value for Tabs
                //datarowProcess["TimeTabGrp"] = GrpCSS;

                //Calculate Time Spend inside App.
                datarowProcess["TotalVisiteTime"] = ConvertTimeToMMSS(Convert.ToString(datarowProcess["TotalVisiteTime"]));

                //Calculate Total

                dsReturn.Tables[0].Rows.Add(datarowProcess.ItemArray);
            }

            
            return dsReturn;
        }

        private string ConvertTimeToMMSS(string strSecond)
        {
            string strReturnTime = "0";
            if (strSecond != null)
            {
                Double TsSecond = 0;

                double.TryParse(strSecond, out TsSecond);

                TimeSpan time = TimeSpan.FromSeconds(TsSecond);
                strReturnTime = time.ToString(@"mm\:ss");

            }
            return strReturnTime;   
        }

        protected void OnItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (rptUserAudit.Items.Count < 1)
            {
                rptUserAudit.Visible = false;
            }
            else if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                rptUserAudit.Visible = true;
                int customerId = Convert.ToInt32((e.Item.FindControl("hfAuditID") as HiddenField).Value);
                Label lblVisitCount = (e.Item.FindControl("lblVisitCount") as Label);
                
                DataTable DtAuditDtl = new DataTable();

                Repeater rptAuditDtl = e.Item.FindControl("rptAuditDtl") as Repeater;

                string Description = (from DataRow AuditDtlDr in DsAuditTrail.Tables[0].Rows
                                      where (int)AuditDtlDr["AuditID"] == customerId
                                      select (string)AuditDtlDr["Description"]).FirstOrDefault();

                
                DtAuditDtl = GetDataSourceFromDescription(Description);

                lblVisitCount.Text = DtAuditDtl.Rows.Count.ToString();

                rptAuditDtl.DataSource = DtAuditDtl;
                rptAuditDtl.DataBind();
                
            }
        }

        private string GetTimeGrpOnLoginTime(string strLoginTime)
        {
            DateTime dtLoginTime;
            DateTime.TryParse(strLoginTime, out dtLoginTime);

            var dateDiff = dtLoginTime.CompareTo(DateTime.Now);
            icount++;

            if (icount < 4)
                return " dayTab";
            else if (icount < 8)
                return " MonthTab";
            else
                return " QTab";
        }

        private DataTable GetDataSourceFromDescription(string description)
        {
            //string[] lines = description.Split('\n');
            string[] VisitEntry = description.Split(new string[] { " || " }, StringSplitOptions.None);

            DataTable table = new DataTable();
            DataColumn colID = table.Columns.Add("Id", typeof(int));
            DataColumn colVisitTime = table.Columns.Add("VisitedOn", typeof(string));
            DataColumn colPageName = table.Columns.Add("PageName", typeof(string));
            int visitCount = 1;

            foreach (var newRow in VisitEntry)
            {
                //string[] split = line.Split('#');
                string[] split = newRow.Split(new string[] {" |:| "}, StringSplitOptions.None); 
                    
                DataRow row = table.NewRow();

                row.SetField(colID, visitCount);
                
                if(split[0] != null)
                row.SetField(colVisitTime, split[0]);

                if (split.Length > 1)
                    row.SetField(colPageName, split[1]);

                table.Rows.Add(row);
                visitCount++;
            }
            return table;
        }




        //private static DataTable GetData(string query)
        //{
        //    string constr = ConfigurationManager.ConnectionStrings["JGPA"].ConnectionString;

        //    using (SqlConnection con = new SqlConnection(constr))
        //    {
        //        using (SqlCommand cmd = new SqlCommand())
        //        {
        //            cmd.CommandText = query;
        //            using (SqlDataAdapter sda = new SqlDataAdapter())
        //            {
        //                cmd.Connection = con;
        //                sda.SelectCommand = cmd;
        //                using (DataSet ds = new DataSet())
        //                {
        //                    DataTable dt = new DataTable();
        //                    sda.Fill(dt);
        //                    return dt;
        //                }
        //            }
        //        }
        //    }
        //}



    }
}