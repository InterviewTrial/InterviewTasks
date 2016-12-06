<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AngularData.aspx.cs" Inherits="JG_Prospect.Sr_App.AngularData" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="../Scripts/angular.min.js"></script>
    <script src="../Scripts/angular-resource.min.js"></script>
    <script src="../js/app.js"></script>
    <script src="../js/data.js"></script>
    <script src="../js/workspecs.js"></script>
</head>
<body>
    <form id="form1" runat="server">


        <ul ng-app="app" ng-controller="workspecsctrl">
            <li ng-repeat="data in workspecsInfo" ng-include="'tree_item_renderer.html'"></li>
        </ul>

    </form>

    


</body>
</html>
