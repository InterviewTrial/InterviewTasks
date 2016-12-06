#region "-- using --"

using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;

#endregion

namespace JG_Prospect.Controls
{
    public partial class CustomPager : System.Web.UI.UserControl
    {
        #region '--Members--'

        public EventHandler OnPageIndexChanged;

        #endregion

        #region '--Properties--'

        public Int32 PageSize
        {
            get
            {
                if (ViewState["PageSize"] == null)
                {
                    return 10;
                }
                return Convert.ToInt32(ViewState["PageSize"]);
            }
            set
            {
                ViewState["PageSize"] = value;
            }
        }

        public Int32 PagerSize
        {
            get
            {
                if (ViewState["PagerSize"] == null)
                {
                    return 10;
                }
                return Convert.ToInt32(ViewState["PagerSize"]);
            }
            set
            {
                ViewState["PagerSize"] = value;
            }
        }

        public Int32 PageIndex
        {
            get
            {
                if (ViewState["PageIndex"] == null)
                {
                    return 0;
                }
                return Convert.ToInt32(ViewState["PageIndex"]);
            }
            set
            {
                ViewState["PageIndex"] = value;
            }
        }

        #endregion

        #region '--Page Events--'

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        #endregion

        #region '--Control Events--'

        protected void Page_Changed(object sender, EventArgs e)
        {
            PageIndex = int.Parse((sender as LinkButton).CommandArgument);
            if (OnPageIndexChanged != null)
            {
                OnPageIndexChanged(sender, e);
            }
        }

        #endregion

        #region '--Methods--'

        public void FillPager(int intRecordCount)
        {
            //double dblPageCount = (double)((decimal)intRecordCount / Convert.ToDecimal(PageSize));
            //int intPageCount = (int)Math.Ceiling(dblPageCount);
            //List<ListItem> lstPages = new List<ListItem>();
            //if (intPageCount > 0)
            //{
            //    for (int i = 1; i <= intPageCount; i++)
            //    {
            //        lstPages.Add(new ListItem(i.ToString(), i.ToString(), i != intCurrentPage));
            //    }
            //}

            if (PageIndex >= intRecordCount)
            {
                PageIndex = 0;
            }

            int intPageCount = (int)Math.Ceiling((decimal)intRecordCount / (decimal)PageSize);
            List<ListItem> lstPages = new List<ListItem>();
            if (intRecordCount > PageSize)
            {
                int intStartPageIndex, intEndPageIndex;

                intStartPageIndex = ((int)Math.Ceiling((decimal)(PageIndex + 1) / (decimal)PageSize) - 1) * PageSize;

                intEndPageIndex = intStartPageIndex + (PageSize - 1);
                
                for (int i = intStartPageIndex; i <= intEndPageIndex && ((i) * PageSize) <= intRecordCount; i++)
                {
                    lstPages.Add(new ListItem((i + 1).ToString(), i.ToString(), i != PageIndex));
                }

                if (intStartPageIndex > 0)
                {
                    lstPages.Insert(0, new ListItem("<", (intStartPageIndex - 1).ToString()));
                }

                if (((intEndPageIndex + 1) * PageSize) < intRecordCount)
                {
                    lstPages.Add(new ListItem(">", (intEndPageIndex + 1).ToString()));
                }
            }

            rptPager.DataSource = lstPages;
            rptPager.DataBind();
        }

        #endregion
    }
}