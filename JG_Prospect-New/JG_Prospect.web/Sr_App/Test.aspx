<%--<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Test.aspx.cs" Inherits="JG_Prospect.Sr_App.Test" %>--%>

<%@ Page Title="" Language="C#" MasterPageFile="~/Sr_App/SR_app.Master" AutoEventWireup="true"
    CodeBehind="Test.aspx.cs" Inherits="JG_Prospect.Sr_App.new_customer" %>



<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
    

     <script src="datetime/js/jquery.timepicker.js"></script>
    <link href="datetime/css/jquery.timepicker.css" rel="stylesheet" />

    <div>
        <div class="demo">
            <h2>Basic Example</h2>
            <p>
                <input id="basicExample" type="text" class="time" /></p>
        </div>

        <script>
         
                $('#basicExample').timepicker();
           
            </script>
    </div>

</asp:Content>