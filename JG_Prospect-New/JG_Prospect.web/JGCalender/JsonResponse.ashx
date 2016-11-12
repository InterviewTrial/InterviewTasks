<<<<<<< HEAD
﻿<%@ WebHandler Language="C#" Class="JG_Prospect.JGCalender.JsonResponse" %>

using System;
using System.Web;
using System.Collections;
using System.Collections.Generic;
using System.Web.SessionState;
using System.Web.Script.Serialization;

namespace JG_Prospect.JGCalender
{
    public class JsonResponse : IHttpHandler, IRequiresSessionState
    {

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            DateTime start = Convert.ToDateTime(context.Request.QueryString["start"]);
            DateTime end = Convert.ToDateTime(context.Request.QueryString["end"]);
            string userIds = context.Request.QueryString["eIds"];
            var iSerializer = new System.Web.Script.Serialization.JavaScriptSerializer();
            var s = iSerializer.Deserialize<List<int>>(userIds);
            var iDs = "";
            var searchFilter= string.Empty;
            searchFilter = context.Request.QueryString["searchText"];
            if (s != null)
                iDs = string.Join(",", s);
            
            List<int> idList = new List<int>();
            List<ImproperCalendarEvent> tasksList = new List<ImproperCalendarEvent>();

            //Generate JSON serializable events
            foreach (CalendarEvent cevent in EventDAO.getEvents(start, end, iDs, searchFilter))
            {
                tasksList.Add(new ImproperCalendarEvent
                {
                    id = cevent.id,
                    title = cevent.title,
                    start = String.Format("{0:s}", cevent.start),
                    end = String.Format("{0:s}", cevent.end),
                    description = cevent.description,
                    allDay = cevent.allDay,
                    status = cevent.status,
                    customerid = cevent.customerid,
                    lastname = cevent.lastname,
                    primarycontact = cevent.primarycontact,
                    address = cevent.address,
                    zipcode = cevent.zipcode,
                    productline = cevent.productline,
                    addedby = cevent.addedby,
                    firstname = cevent.firstname,
                    backgroundColor = cevent.backgroundColor
                });
                idList.Add(cevent.id);
            }

            context.Session["idList"] = idList;

            //Serialize events to string
            var oSerializer = new System.Web.Script.Serialization.JavaScriptSerializer();
            string sJSON = oSerializer.Serialize(tasksList);

            //Write JSON to response object
            context.Response.Write(sJSON);
        }

        public bool IsReusable
        {
            get { return false; }
        }

    }

=======
﻿<%@ WebHandler Language="C#" Class="JG_Prospect.JGCalender.JsonResponse" %>

using System;
using System.Web;
using System.Collections;
using System.Collections.Generic;
using System.Web.SessionState;
using System.Web.Script.Serialization;

namespace JG_Prospect.JGCalender
{
    public class JsonResponse : IHttpHandler, IRequiresSessionState
    {

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            DateTime start = context.Request.QueryString["start"] == null ? DateTime.Now.AddDays(-1) : Convert.ToDateTime(context.Request.QueryString["start"]);
            DateTime end = context.Request.QueryString["end"] == null ? DateTime.Now : Convert.ToDateTime(context.Request.QueryString["end"]);

            string userIds = context.Request.QueryString["eIds"];
            var iSerializer = new System.Web.Script.Serialization.JavaScriptSerializer();
            var s = iSerializer.Deserialize<List<int>>(userIds);
            var iDs = "";
            var searchFilter = string.Empty;
            searchFilter = context.Request.QueryString["searchText"];
            if (s != null)
                iDs = string.Join(",", s);

            List<int> idList = new List<int>();
            List<ImproperCalendarEvent> tasksList = new List<ImproperCalendarEvent>();

            //Generate JSON serializable events
            foreach (CalendarEvent cevent in EventDAO.getEvents(start, end, iDs, searchFilter))
            {
                tasksList.Add(new ImproperCalendarEvent
                {
                    id = cevent.id,
                    title = cevent.title,
                    start = String.Format("{0:s}", cevent.start),
                    end = String.Format("{0:s}", cevent.end),
                    description = cevent.description,
                    allDay = cevent.allDay,
                    status = cevent.status,
                    customerid = cevent.customerid,
                    lastname = cevent.lastname,
                    primarycontact = cevent.primarycontact,
                    address = cevent.address,
                    zipcode = cevent.zipcode,
                    productline = cevent.productline,
                    addedby = cevent.addedby,
                    firstname = cevent.firstname,
                    backgroundColor = cevent.backgroundColor,
                    Latitude = GetLatitude(cevent.CommonAddress),
                    Longitude = GetLongitude(cevent.CommonAddress),
                    CommonAddress = cevent.CommonAddress
                });
                idList.Add(cevent.id);
            }

            context.Session["idList"] = idList;

            //Serialize events to string
            var oSerializer = new System.Web.Script.Serialization.JavaScriptSerializer();
            string sJSON = oSerializer.Serialize(tasksList);

            //Write JSON to response object
            context.Response.Write(sJSON);
        }

        public double? GetLatitude(string Address)
        {
            try
            {
                var map = new GoogleMaps.LocationServices.GoogleLocationService();
                return map.GetLatLongFromAddress(Address).Latitude;
            }
            catch (Exception)
            {
                return (double)0;
            }
        }

        public double? GetLongitude(string Address)
        {
            try
            {
                var map = new GoogleMaps.LocationServices.GoogleLocationService();
                return map.GetLatLongFromAddress(Address).Longitude;
            }
            catch (Exception)
            {
                return (double)0;
            }
        }

        public bool IsReusable
        {
            get { return false; }
        }

    }

>>>>>>> origin/jaylem-interviewtask
}