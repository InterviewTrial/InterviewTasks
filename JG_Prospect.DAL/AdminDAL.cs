﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using Microsoft.Practices.EnterpriseLibrary.Data.Sql;
using JG_Prospect.DAL.Database;
using System.Data.Common;
using JG_Prospect.Common;
using JG_Prospect.Common.modal;
using System.Data.SqlClient;
using System.Configuration;

namespace JG_Prospect.DAL
{
    public class AdminDAL
    {
        private static AdminDAL m_AdminDAL = new AdminDAL();
        private DataSet returndata;

        private AdminDAL()
        {

        }

        public static AdminDAL Instance
        {
            get { return m_AdminDAL; }
            private set { ;}
        }

        public DataSet FetchMaterialList(string SoldId)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UDP_GetPermissionDetails");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@SoldJobId", DbType.String, SoldId);
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }

        public DataSet GetAutoEmailTemplate(int pHTMLTemplateID, int pSubHTMLTemplateID=0)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("USP_GETAutoEmailTemplates");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@HTMLTemplateID", DbType.Int32, pHTMLTemplateID);
                    database.AddInParameter(command, "@SubHTMLTempID", DbType.Int32, pSubHTMLTemplateID);
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }

        public DataSet FetchContractTemplate(int id)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UDP_FetchContractTemplate");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@ProductType", DbType.Int32, id);
                    result = database.ExecuteDataSet(command);
                }               
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }

        public DataSet FetchContractTemplate(int id, int desig)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UDP_FetchContractTemplate_AutoEmail");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@ProductType", DbType.Int32, id);
                    database.AddInParameter(command, "@DesigID", DbType.Int32, desig);
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }

        public DataSet GetEmailTemplate(String pTemplateName, int htmlTemplateID)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("USP_GetEmailTemplate");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@TemplateName", DbType.String, pTemplateName);
                    database.AddInParameter(command, "@HTMLTemplateID", DbType.Int32, htmlTemplateID);
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }

        public DataSet GetJobInformation(String pSoldJobID, Int32 pProductCatID, Int32 pVendorID)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("USP_GetPurchaseOrderEmailContent");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@SoldJobID", DbType.String, pSoldJobID);
                    database.AddInParameter(command, "@ProductCatID", DbType.String, pProductCatID);
                    database.AddInParameter(command, "@VendorID", DbType.String, pVendorID);
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }

        public DataSet GetInstallerEmails()
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("USP_GetInstallerEmailAddress");
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }

        public DataSet AutoFill(string prefix)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("Usp_GetBanks");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@prefixText", DbType.String, prefix);
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }


        public DataSet FetchStatusEmailTemplate(string Status)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UDP_FetchStatusEmailTemplate");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@Html_Name", DbType.String, Status);
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }
        public DataSet FetchingContractTemplateDetails(string templateName)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UDP_FetchingContractTemplateDetails");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@TemplateName", DbType.String, templateName);
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }
        public DataSet DisableCustomer(int id,string Reason)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("USP_DisableCustomer");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@Id", DbType.Int32, id);
                    database.AddInParameter(command, "@Reason", DbType.String, Reason);
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }

        public DataSet GetSrAppointment(int Id)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("USP_GetSRAppointments");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@UserId", DbType.Int32, Id);
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }


        public DataSet FetchWorkOrderTemplate()
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UDP_FetchWorkOrderTemplate");
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }

        public bool UpdateEmailVendorCategoryTemplate(string EmailTemplateHeader, string EmailTemplateFooter,String Attachment, string subject)
        {
            bool result = false;
            try
            {

                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UDP_UpdateEmailVendorCategoryTemplate");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@EmailTemplateHeader", DbType.String, EmailTemplateHeader);
                    database.AddInParameter(command, "@EmailTemplateFooter", DbType.String, EmailTemplateFooter);
                    database.AddInParameter(command, "@AttachmentPath", DbType.String, Attachment);
                    database.AddInParameter(command, "@Subject", DbType.String, subject);
                    database.ExecuteNonQuery(command);

                   
                    result = true;
                }

                return result;

            }

            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return false;
            }

        }
        public bool UpdateEmailVendorTemplate(string EmailTemplateHeader, string EmailTemplateFooter, string subject, int pHTMLTemplateID, List<CustomerDocument> custList)
        {
            bool result = false;
            try
            {

                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UDP_UpdateEmailVendorTemplate");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@EmailTemplateHeader", DbType.String, EmailTemplateHeader);
                    database.AddInParameter(command, "@EmailTemplateFooter", DbType.String, EmailTemplateFooter);
                    database.AddInParameter(command, "@Subject", DbType.String, subject);
                    database.ExecuteNonQuery(command);
                    foreach (var item in custList)
                    {
                        DbCommand command2 = database.GetStoredProcCommand("UDP_AddCustomerFile");
                        command2.CommandType = CommandType.StoredProcedure;
                        database.AddInParameter(command2, "@DocumentName", DbType.String, item.DocumentName);
                        database.AddInParameter(command2, "@DocumentPath", DbType.String, item.DocumentPath);
                        database.AddInParameter(command2, "@HTMLTemplateID", DbType.String, pHTMLTemplateID);
                        database.ExecuteNonQuery(command2);
                    }

                    result = true;
                }

                return result;

            }

            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return false;
            }

        }
        public string AddMaterialListAttachment(String pSoldJobID, Int32 pProductCatID, List<CustomerDocument> pAttachmentList, int pAttachmentType, int pVendorID)
        {
            string result = "";
            try
            {

                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    
                    foreach (var item in pAttachmentList)
                    {
                        DbCommand command2 = database.GetStoredProcCommand("USP_AddMaterialListAttachment");
                        command2.CommandType = CommandType.StoredProcedure;
                        database.AddInParameter(command2, "@DocumentName", DbType.String, item.DocumentName);
                        database.AddInParameter(command2, "@DocumentPath", DbType.String, item.DocumentPath);
                        database.AddInParameter(command2, "@SoldJobID", DbType.String, pSoldJobID);
                        database.AddInParameter(command2, "@ProductCatID", DbType.String, pProductCatID);
                        database.AddInParameter(command2, "@AttachmentType", DbType.Int32, pAttachmentType);
                        database.AddInParameter(command2, "@VendorID", DbType.Int32, pVendorID);
                        result = Convert.ToString(database.ExecuteScalar(command2));
                    }
                }
                return result;
            }
            catch (Exception ex)
            {
                return "";
            }

        }
        /// <summary>
        /// This method deletes the record and returns the path of physical file, so that it could be deleted from server.
        /// </summary>
        /// <param name="pAttachmentID"></param>
        /// <returns></returns>
        public DataSet DeleteEmailAttachment(int pAttachmentID)
        {
            DataSet result = new DataSet();
            try
            {

                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("USP_DeleteHTMLTemplateAttachment");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@ID", DbType.String, pAttachmentID);
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }

            catch (Exception ex)
            {
                return null;
            }

        }
        /// <summary>
        /// This method deletes the record and returns the path of physical file, so that it could be deleted from server.
        /// </summary>
        /// <param name="pAttachmentID"></param>
        /// <returns></returns>
        public DataSet DeleteMaterialListAttachment(int pAttachmentID)
        {
            DataSet result = new DataSet();
            try
            {

                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("USP_DeleteMaterialListAttachment");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@ID", DbType.String, pAttachmentID);
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }

            catch (Exception ex)
            {
                return null;
            }

        }
        public bool UpdateEmailVendorTemplate2(string EmailTemplateHeader, string EmailTemplateFooter,string AttPath)
        {
            bool result = false;
            try
            {

                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UDP_UpdateEmailVendorTemplate");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@EmailTemplateHeader", DbType.String, EmailTemplateHeader);
                    database.AddInParameter(command, "@EmailTemplateFooter", DbType.String, EmailTemplateFooter);
                    database.AddInParameter(command, "@AttachmentPath", DbType.String,AttPath);
                    database.ExecuteNonQuery(command);
                    result = true;
                }

                return result;

            }

            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return false;
            }

        }
        public bool UpdateContractTemplate(string ContracttemplateHeader, string ContracttemplateBodyA, string ContracttemplateBodyB,
            string ContracttemplateFooter, string ContractTemplateBody2, int id, int desigID)
        {
            bool result = false;
            try
            {

                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UDP_UpdateContractTemplate");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@ContracttemplateHeader", DbType.String, ContracttemplateHeader);
                    database.AddInParameter(command, "@ContracttemplateBodyA", DbType.String, ContracttemplateBodyA);
                    database.AddInParameter(command, "@ContracttemplateBodyB", DbType.String, ContracttemplateBodyB);
                    database.AddInParameter(command, "@ContracttemplateFooter", DbType.String, ContracttemplateFooter);
                    database.AddInParameter(command, "@ContracttemplateBody2", DbType.String, ContractTemplateBody2);
                    database.AddInParameter(command, "@id", DbType.Int16, id);
                    database.AddInParameter(command, "@DesigID", DbType.Int32, desigID);
                    database.ExecuteNonQuery(command);
                    result = true;
                }

                return result;

            }

            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return false;
            }

        }


        public bool UpdateWorkOrderTemplate(string WorkOrdertemplate)
        {
            bool result = false;
            try
            {

                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UDP_UpdateWorkOrderTemplate");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@WorkOrder_html", DbType.String, WorkOrdertemplate);
                    database.ExecuteNonQuery(command);
                    result = true;
                }

                return result;

            }

            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return false;
            }

        }

        public DataSet GetHTMLTemplateAttachedFile(int pHTMLTemplateID)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("USP_GetAttachedFile");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@HTMLTemplateID", DbType.Int32, pHTMLTemplateID);
                    result = database.ExecuteDataSet(command);
                    command.Dispose();
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }

        public DataSet GetShutterStyle()
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UDP_getshutterstyle");
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }




        public DataSet GetProductLineForGrid()
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("USP_GetProductLineNew");
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }



        public DataSet SelectProduct_PriceControl(int ProductId)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("USP_SelectProduct_PriceControl");
                    database.AddInParameter(command, "@ProductId", DbType.Int32, ProductId);
                    database.AddInParameter(command, "@Type", DbType.String, "S");
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }


        public DataSet DeleteProduct_PriceControl(int ProductId)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("USP_SelectProduct_PriceControl");
                    database.AddInParameter(command, "@ProductId", DbType.Int32, ProductId);
                    database.AddInParameter(command, "@Type", DbType.String, "D");
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }


        public DataSet CheckDuplicateProduct_PriceControl(string Productname)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("USP_SelectProduct_PriceControl");
                    database.AddInParameter(command, "@ProductName", DbType.String, Productname);
                    database.AddInParameter(command, "@Type", DbType.String, "Dup");
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }


        public DataSet CheckDuplicateProduct_Update_PriceControl(string Productname, int ProdId)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("USP_SelectProduct_PriceControl");
                    database.AddInParameter(command, "@ProductName", DbType.String, Productname);
                    database.AddInParameter(command, "@ProductId", DbType.Int32, ProdId);
                    database.AddInParameter(command, "@Type", DbType.String, "DupU");
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }

        public DataSet GetContractTemplateByName(string ProductLineName)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("USP_GetContractTemplateByNameNew");
                    database.AddInParameter(command, "@Html_Name", DbType.String, ProductLineName);
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }


        public DataSet InsertProduct_PriceControl(string ProductLineName)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("USP_InsertProduct_PriceControl");
                    database.AddInParameter(command, "@ProductName", DbType.String, ProductLineName);
                    database.AddInParameter(command, "@Type", DbType.String, "I");

                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }

        public DataSet UpdateProduct_PriceControl(string ProductLineName, int ProdId)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("USP_InsertProduct_PriceControl");
                    database.AddInParameter(command, "@ProductName", DbType.String, ProductLineName);
                    database.AddInParameter(command, "@ProductId", DbType.Int32, ProdId);
                    database.AddInParameter(command, "@Type", DbType.String, "U");

                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }


        public DataSet InsertContract(string ProductLineName,string  HTMLHeader,string  HTMLBody,string HTMLFooter,string HTMLBody2)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("USP_InsertProductContract");
                    database.AddInParameter(command, "@Html_Name", DbType.String, ProductLineName);
                    database.AddInParameter(command, "@HTMLHeader",DbType.String,HTMLHeader);
                    database.AddInParameter(command, "@HTMLBody", DbType.String, HTMLBody);
                    database.AddInParameter(command, "@HTMLFooter", DbType.String, HTMLFooter);
                    database.AddInParameter(command, "@HTMLBody2", DbType.String, HTMLBody2);
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }

        public DataSet UpdateContractTemplate(int Id,string ProductLineName, string HTMLHeader, string HTMLBody, string HTMLFooter, string HTMLBody2)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("USP_UPDATEContract");
                    database.AddInParameter(command, "@Id", DbType.Int32, Id);
                    database.AddInParameter(command, "@Html_Name", DbType.String, ProductLineName);
                    database.AddInParameter(command, "@HTMLHeader", DbType.String, HTMLHeader);
                    database.AddInParameter(command, "@HTMLBody", DbType.String, HTMLBody);
                    database.AddInParameter(command, "@HTMLFooter", DbType.String, HTMLFooter);
                    database.AddInParameter(command, "@HTMLBody2", DbType.String, HTMLBody2);
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }

        public DataSet GetShutterwidth()
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UDP_getshutterwidth");
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }


        public DataSet GetSurfaceofmount()
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UDP_GetSurfaceofMount");
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }

        public bool updateshutterwidth(int id, decimal price)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    returndata = new DataSet();
                    DbCommand command = database.GetStoredProcCommand("UDP_updateshutterwidth");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@Id", DbType.Int32, id);
                    database.AddInParameter(command, "@price", DbType.Decimal, price);
                    returndata = database.ExecuteDataSet(command);
                    return true;
                }
            }
            catch (Exception ex)
            {
                return false;
            }
        }

        public bool updatesurfacemount(int id, decimal price)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    returndata = new DataSet();
                    DbCommand command = database.GetStoredProcCommand("UDP_updatesurfacemount");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@Id", DbType.Int32, id);
                    database.AddInParameter(command, "@price", DbType.Decimal, price);
                    returndata = database.ExecuteDataSet(command);
                    return true;
                }
            }
            catch (Exception ex)
            {
                return false;
            }
        }


        public bool Updatepricebypercentage(Decimal percentage, string oper)
        {
            bool result = false;
            try
            {

                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UDP_ChangePricesbypercentage");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@percentage", DbType.Decimal, percentage);
                    database.AddInParameter(command, "@operator", DbType.String, oper);
                    database.ExecuteNonQuery(command);
                    result = true;
                }

                return result;

            }

            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return false;
            }

        }

        public DataSet FetchALLcustomer()
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UDP_FetchALLcustomer");
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }

        public DataSet BindGridForSrSales(string str_Search,string str_Criateria,string from,string to)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("Usp_GetSrSalesByCrieteria");
                    database.AddInParameter(command, "@str_Search", DbType.String, str_Search);
                    database.AddInParameter(command, "@str_Criateria", DbType.String, str_Criateria);
                    database.AddInParameter(command, "@from", DbType.String, from);
                    database.AddInParameter(command, "@to", DbType.String, to);
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }



        public DataSet MakeAppointments(int UserId, int QuoteId,string Date,string Time,string CalType)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("USP_AddSrAppointments");
                    database.AddInParameter(command, "@UserId", DbType.Int32, UserId);
                    database.AddInParameter(command, "@QuoteId", DbType.Int32, QuoteId);
                    database.AddInParameter(command, "@Date", DbType.String, Date);
                    database.AddInParameter(command, "@Time", DbType.String, Time);
                    //database.AddInParameter(command, "@CalType", DbType.String, CalType);
                   // database.AddInParameter(command, "@CalType", DbType.String, CalType);
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }

        public DataSet GetSalesAppointmentsById(int UserId)
        {
            DataSet result = new DataSet();
            /*
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("usp_GetSalesAppointmentsBySalesId");
                    database.AddInParameter(command, "@UserId", DbType.Int32, UserId);
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
            */
            //Code altered by Neeta....
            try
            {
               SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("SearchCustomerByID");
                   // DbCommand command = database.GetStoredProcCommand("SearchCustomerByID");
                    database.AddInParameter(command, "@ID", DbType.Int32, UserId);
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }



        public DataSet GetTodaysAppointments(int UserId)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("GetTodaysAppointmentsById");
                    // DbCommand command = database.GetStoredProcCommand("SearchCustomerByID");
                    database.AddInParameter(command, "@ID", DbType.Int32, UserId);
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }



        public DataSet GetNextAppointmentsById(int UserId)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("USP_GetNextAppointMentById");
                    // DbCommand command = database.GetStoredProcCommand("SearchCustomerByID");
                    database.AddInParameter(command, "@ID", DbType.Int32, UserId);
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }
        
        //For Color Code.....
        public DataSet GetStatusForColorCode(int UserId)
        {
            DataSet result = new DataSet();          
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("GetStatusForColorCode");
                    database.AddInParameter(command, "@ID", DbType.Int32, UserId);
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {              
                return null;
            }
        }

        //For Status.....
        public DataSet GetAllStatusForSalesCustomer()
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("GetAllStatusForSalesCustomer");
                  
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        public DataSet GetAllsalesAppointments()
        {
            DataSet result = new DataSet();         
            //Code added by Neeta....
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("GetAllsalesAppointments");                   
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }
        //Company Calendar....

        public DataSet GetCompanyCalendar()
        {
            DataSet result = new DataSet();         
            //Code added by Neeta....
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("GetCompanyCalendar");                   
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }

        //Event Calendar...
        public DataSet GetInterviewDetails(int UserId)
        {
            DataSet result = new DataSet();
            
            //Code added by Neeta....
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("GetInterviewDetails");
                    database.AddInParameter(command, "@ID", DbType.Int32, UserId);
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {               
                return null;
            }
        }

        public DataSet GetAnnualEventByID(int UserId,string year)
        {
            DataSet result = new DataSet();          
            //Code added by Neeta....
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("GetAnnualEventByID");
                    database.AddInParameter(command, "@EventAddedBy", DbType.Int32, UserId);
                    database.AddInParameter(command, "@Year", DbType.String, year);
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }

        public DataSet GetAllAnnualEvent()
        {
            DataSet result = new DataSet();
            DateTime d = Convert.ToDateTime(System.DateTime.Now.ToLongDateString());
            string year = Convert.ToString(System.DateTime.Now.Year);
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("GetAllAnnualEvent");
                    database.AddInParameter(command, "@Year", DbType.String, year);
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }

        //For Event calendar....
        public DataSet GetEventCalendar()
        {
            DataSet result = new DataSet();
            DateTime d = Convert.ToDateTime(System.DateTime.Now.ToLongDateString());
            string year = Convert.ToString(System.DateTime.Now.Year);
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("GetEventCalendar");
                    database.AddInParameter(command, "@Year", DbType.String, year);
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }

        //Get All HR, Event , Company Calendars...
        public DataSet GetHRCompanyEventCalendar()
        {
            DataSet result = new DataSet();
            DateTime d = Convert.ToDateTime(System.DateTime.Now.ToLongDateString());
            string year = Convert.ToString(System.DateTime.Now.Year);
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("GetHRCompanyEventCalendar");
                    database.AddInParameter(command, "@Year", DbType.String, year);
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }
        

            //For Company event Calendar...
        public DataSet GetEventCompanyCalendar()
        {
            DataSet result = new DataSet();
            DateTime d = Convert.ToDateTime(System.DateTime.Now.ToLongDateString());
            string year = Convert.ToString(System.DateTime.Now.Year);
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("GetEventCompanyCalendar");
                    database.AddInParameter(command, "@Year", DbType.String, year);
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }

        //HR Company Calendar.....
        public DataSet GetHRCompanyCalendar()
        {
            DataSet result = new DataSet();
            DateTime d = Convert.ToDateTime(System.DateTime.Now.ToLongDateString());
            string year = Convert.ToString(System.DateTime.Now.Year);
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("GetHRCompanyCalendar");
                    database.AddInParameter(command, "@Year", DbType.String, year);
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }


        //For HR and Event Calendar...
        public DataSet GetHREventCalendar()
        {
            DataSet result = new DataSet();
            DateTime d = Convert.ToDateTime(System.DateTime.Now.ToLongDateString());
            string year = Convert.ToString(System.DateTime.Now.Year);
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("GetHREventCalendar");
                    database.AddInParameter(command, "@Year", DbType.String, year);
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }

        //For HR Calendar....
        public DataSet GetHRCalendar()
        {
            DataSet result = new DataSet();
            DateTime d = Convert.ToDateTime(System.DateTime.Now.ToLongDateString());
            string year = Convert.ToString(System.DateTime.Now.Year);
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("GetHRCalendar");
                    database.AddInParameter(command, "@Year", DbType.String, year);
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }


        public DataSet GetJuniorsalesAppointmentsById(int UserId)
        {
            DataSet result = new DataSet();

            //Code altered by Neeta....
            try
            {
                //  String str = ConfigurationManager.ConnectionStrings["JGPA"].ConnectionString;
                //  SqlConnection con = new SqlConnection(str);


                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("SearchJuniorCustomerByID");
                    database.AddInParameter(command, "@ID", DbType.Int32, UserId);
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                return null;
            }
        }
        //Code Added by Neeta A.....
        public DataSet GetTodaysSalesAppointment(int UserId)
        {
            DataSet result = new DataSet();

            //Code altered by Neeta....
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("GetTodaysSalesAppointment");
                    database.AddInParameter(command, "@ID", DbType.Int32, UserId);
                    database.AddInParameter(command, "@CurrentDate", DbType.DateTime, System.DateTime.Now.Date);               
                    database.AddInParameter(command, "@CurrentTime", DbType.String, DateTime.Now.ToString("hh:mm tt"));
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                return null;
            }
        }
        public void UpdateStatusFromGrid(int id, string str_Status)
        {
            DataSet result = new DataSet();
            try
            {  
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("USP_UPDATEStatus");
                    database.AddInParameter(command, "@Id", DbType.Int32, id);
                    database.AddInParameter(command, "@Status", DbType.String, str_Status);
                    command.CommandType = CommandType.StoredProcedure;
                    database.ExecuteDataSet(command);
                }
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
            }
        }


        public void UpdateCloseReason(int id, string str_Status)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("Usp_UpdateCloseReason");
                    database.AddInParameter(command, "@QuoteId", DbType.Int32, id);
                    database.AddInParameter(command, "@CloseReason", DbType.String, str_Status);
                    command.CommandType = CommandType.StoredProcedure;
                    database.ExecuteDataSet(command);
                }
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
            }
        }


        public void UpdateSold(int id, string str_Status,string Status)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("USP_SoldDate");
                    database.AddInParameter(command, "@Id", DbType.Int32, id);
                    database.AddInParameter(command, "@EstDateSchdule", DbType.Date, Convert.ToDateTime(str_Status));
                    database.AddInParameter(command, "@Status", DbType.String, Status);
                    command.CommandType = CommandType.StoredProcedure;
                    database.ExecuteDataSet(command);
                    database.ExecuteDataSet(command);
                }
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
            }
        }



        public void UpdateEst(int id, string str_Status,string Status)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("USP_EstDate");
                    database.AddInParameter(command, "@Id", DbType.Int32, id);
                    database.AddInParameter(command, "@EstDateSchdule", DbType.Date, Convert.ToDateTime(str_Status));
                    database.AddInParameter(command, "@Status", DbType.String, Status);
                    command.CommandType = CommandType.StoredProcedure;
                    database.ExecuteDataSet(command);
                }
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
            }
        }


        public DataSet BindGridForStatus(int CustId)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("USP_GetStatusByCustomerId");
                   // DbCommand command = database.GetStoredProcCommand("USP_GetStatusByCustomerId");
                    database.AddInParameter(command, "@CustId", DbType.Int32, CustId);
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }


        public DataSet BindGridForQuotes(int CustId)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("USP_GetQoutesByCustomerId");
                    database.AddInParameter(command, "@CustId", DbType.Int32, CustId);
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }


        public DataSet BindGridForJobs(int CustId)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                   // DbCommand command = database.GetStoredProcCommand("[jgrov_User].[USP_GetSoldJobIdByCustomerId]");
                    DbCommand command = database.GetStoredProcCommand("USP_GetSoldJobIdByCustomerId");
                    database.AddInParameter(command, "@CustId", DbType.Int32, CustId);
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }

        public bool UpdateStatus(int custid, string status, string followupdate)
        {
            bool result = false;
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UDP_UpdateStatusNew");
                    command.CommandType = CommandType.StoredProcedure;
                    //database.AddInParameter(command, "@prospectid", DbType.Int32, prospectid);
                    database.AddInParameter(command, "@customerid", DbType.Int32, custid);
                    database.AddInParameter(command, "@status", DbType.String, status);

                    database.AddInParameter(command, "@followupdate", DbType.Date, Convert.ToDateTime(followupdate, JGConstant.CULTURE));
                    database.ExecuteNonQuery(command);
                    result = true;
                }

                return result;

            }

            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return false;
            }

        }


        public string GetAdminCode()
        {
            string result = "";
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UDP_GetAdminCode");
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteScalar(command).ToString();
                }

                return result;

            }

            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }

        }
        #region Password is taken from tblInstallUsers table....
        public string GetForemanCode()
        {
            string result = "";
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UDP_GetForemanCode");
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteScalar(command).ToString();
                }

                return result;

            }

            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }

        }


        public DataSet GetForemanPassword(string ForemanPwd)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("GetForemanPassword");

                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@Password", DbType.String,ForemanPwd);
                    result = database.ExecuteDataSet(command);
                }

                return result;

            }

            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }

        }


        #endregion

        public DataSet FetchCustomerEmailTemplate(int id)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UDP_FetchCustomerEmailTemplate");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@ProductType", DbType.Int32, id);
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }
        public bool UpdateCustomerEmailtTemplate(string CustomerEmailtemplateHeader, string CustomerEmailtemplateBody, string CustomerEmailtemplateFooter, int id, List<CustomerDocument> custList)
        {
            bool result = false;
            try
            {

                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UDP_UpdateCustomerEmailTemplate");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@EmailtemplateHeader", DbType.String, CustomerEmailtemplateHeader);
                    database.AddInParameter(command, "@EmailtemplateBody", DbType.String, CustomerEmailtemplateBody);
                    database.AddInParameter(command, "@EmailtemplateFooter", DbType.String, CustomerEmailtemplateFooter);
                    //database.AddInParameter(command, "@ContracttemplateBody2", DbType.String, ContractTemplateBody2);
                    database.AddInParameter(command, "@id", DbType.Int16, id);
                    database.ExecuteNonQuery(command);

                    foreach (var item in custList)
                    {
                        DbCommand command2 = database.GetStoredProcCommand("UDP_AddCustomerFile");
                        command2.CommandType = CommandType.StoredProcedure;
                        database.AddInParameter(command2, "@DocumentName", DbType.String, item.DocumentName);
                        database.AddInParameter(command2, "@DocumentPath", DbType.String, item.DocumentPath);
                        database.AddInParameter(command2, "@HTMLTemplateID", DbType.String, id);
                        database.ExecuteNonQuery(command2);
                        //custList.Add(new CustomerDocument
                        //{
                        //    DocumentName = item.DocumentName,
                        //    CreatedDate = DateTime.Now
                        //});
                    }
                    result = true;
                }

                return result;

            }

            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return false;
            }

        }
        public DataSet FetchCustomerAttachments()
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UDP_FetchCustomerAttachemnt");
                    command.CommandType = CommandType.StoredProcedure;
                    //database.AddInParameter(command, "@ProductType", DbType.Int32, id);
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }

        public DataSet FetchCustomerAttachmentTemplate()
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UDP_FetchCustomerEmailTemplate");
                    command.CommandType = CommandType.StoredProcedure;
                    //database.AddInParameter(command, "@ProductType", DbType.Int32, id);
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }

        public bool DeleteCustomerAttachment(string documentName)
        {
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UDP_deleteCustomerAttachment");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@DocumentName", DbType.String, documentName);
                    database.ExecuteNonQuery(command);
                    return true;
                }
            }
            catch (Exception ex)
            {
                return false;
            }

        }
        //Get Company Address
        public DataSet CompanyAddress()
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("GetCompanyAddress");
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }
        public string UpdateCompanyAddress(int Addressid, string CompanyAddress, string CompanyCity, string CompanyState, string CompanyZipCode)
        {
            string result = string.Empty;
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("USP_UPDATECompanyAddress");
                    database.AddInParameter(command, "@Id", DbType.Int32, Addressid);
                    database.AddInParameter(command, "@Address", DbType.String, CompanyAddress);
                    database.AddInParameter(command, "@City", DbType.String, CompanyCity);
                    database.AddInParameter(command, "@State", DbType.String, CompanyState);
                    database.AddInParameter(command, "@Zipcode", DbType.String, CompanyZipCode);
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteScalar(command).ToString();
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }
        public bool UpdateEmailVendorCategoryTemplate(string EmailTemplateHeader, string EmailTemplateFooter, string subject, int pHTMLTemplateID, List<CustomerDocument> custList)
        {
            bool result = false;
            try
            {

                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("UDP_UpdateEmailVendorCategoryTemplate");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@EmailTemplateHeader", DbType.String, EmailTemplateHeader);
                    database.AddInParameter(command, "@EmailTemplateFooter", DbType.String, EmailTemplateFooter);
                    database.AddInParameter(command, "@Subject", DbType.String, subject);
                    database.ExecuteNonQuery(command);
                    foreach (var item in custList)
                    {
                        DbCommand command2 = database.GetStoredProcCommand("UDP_AddCustomerFile");
                        command2.CommandType = CommandType.StoredProcedure;
                        database.AddInParameter(command2, "@DocumentName", DbType.String, item.DocumentName);
                        database.AddInParameter(command2, "@DocumentPath", DbType.String, item.DocumentPath);
                        database.AddInParameter(command2, "@HTMLTemplateID", DbType.String, pHTMLTemplateID);
                        database.ExecuteNonQuery(command2);
                    }
                    command.Dispose();
                    result = true;
                }

                return result;

            }

            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return false;
            }

        }

        public bool UpdateHTMLTemplate(string EmailTemplateHeader, string EmailTemplateBody, string EmailTemplateFooter, string subject, int pHTMLTemplateID, List<CustomerDocument> custList)
        {
            bool result = false;
            try
            {

                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("USP_SaveHTMLTemplate");
                    command.CommandType = CommandType.StoredProcedure;
                    database.AddInParameter(command, "@EmailTemplateHeader", DbType.String, EmailTemplateHeader);
                    database.AddInParameter(command, "@EmailTemplateBody", DbType.String, EmailTemplateBody);
                    database.AddInParameter(command, "@EmailTemplateFooter", DbType.String, EmailTemplateFooter);
                    database.AddInParameter(command, "@Subject", DbType.String, subject);
                    database.AddInParameter(command, "@SubHTMLTemplateID", DbType.Int32, pHTMLTemplateID);
                    
                    database.ExecuteNonQuery(command);
                    foreach (var item in custList)
                    {
                        DbCommand command2 = database.GetStoredProcCommand("UDP_AddCustomerFile");
                        command2.CommandType = CommandType.StoredProcedure;
                        database.AddInParameter(command2, "@DocumentName", DbType.String, item.DocumentName);
                        database.AddInParameter(command2, "@DocumentPath", DbType.String, item.DocumentPath);
                        database.AddInParameter(command2, "@SubHTMLTemplateID", DbType.String, pHTMLTemplateID);
                        database.ExecuteNonQuery(command2);
                    }
                    command.Dispose();
                    result = true;
                }

                return result;

            }

            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return false;
            }

        }

        public DataSet GetProductCategory()
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("USP_GetProductLineNew");
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }

        public DataSet GetAllVendorCategory(bool Isretail_wholesale, bool IsManufacturer)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("USP_GetProductVendor");
                    database.AddInParameter(command, "@IsRetail_Wholesale", DbType.Boolean, Isretail_wholesale);
                    database.AddInParameter(command, "@IsManufacturer", DbType.Boolean, IsManufacturer);
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }

        public DataSet GetVendorCategory(string ProductCategoryId,bool Isretail_wholesale, bool IsManufacturer)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("USP_GetProductVendor");
                    database.AddInParameter(command, "@ProductCategoryId", DbType.String, ProductCategoryId);
                    database.AddInParameter(command, "@IsRetail_Wholesale", DbType.Boolean, Isretail_wholesale);
                    database.AddInParameter(command, "@IsManufacturer", DbType.Boolean, IsManufacturer);
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }
        public DataSet GetVendorSubCategory(string VendorCategoryId, bool Isretail_wholesale, bool IsManufacturer)
        {
            DataSet result = new DataSet();
            try
            {
                SqlDatabase database = MSSQLDataBase.Instance.GetDefaultDatabase();
                {
                    DbCommand command = database.GetStoredProcCommand("USP_GetVendorSubCategory");
                    database.AddInParameter(command, "@VendorCategoryId", DbType.String, VendorCategoryId);
                    database.AddInParameter(command, "@IsRetail_Wholesale", DbType.Boolean, Isretail_wholesale);
                    database.AddInParameter(command, "@IsManufacturer", DbType.Boolean, IsManufacturer);
                    command.CommandType = CommandType.StoredProcedure;
                    result = database.ExecuteDataSet(command);
                }
                return result;
            }
            catch (Exception ex)
            {
                //LogManager.Instance.WriteToFlatFile(ex);
                return null;
            }
        }

    }

}
