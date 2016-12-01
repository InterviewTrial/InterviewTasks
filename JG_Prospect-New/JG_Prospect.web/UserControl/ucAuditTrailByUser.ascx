<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ucAuditTrailByUser.ascx.cs" Inherits="JG_Prospect.UserControl.ucAuditTrailByUser" %>
<style>
    #tabUl li {
        width: 100px;
    }

        #tabUl li a {
            width: 100px;
            padding: 0;
        }

    .dayTab {
    }

    .MonthTab {
        display: none;
    }

    .QTab {
        display: none;
    }


    /* Style the list */
    ul.tab {
        list-style-type: none;
        padding: 0;
        overflow: hidden;
        border: 1px solid #ccc;
        background-color: #f1f1f1;
        margin-bottom: 10px;
    }

        /* Float the list items side by side */
        ul.tab li {
            float: left;
            width: auto;
        }

            /* Style the links inside the list items */
            ul.tab li a {
                display: inline-block;
                color: black;
                text-align: center;
                padding: 14px 10px;
                text-decoration: none;
                transition: 0.3s;
                font-weight: 600;
                /*font-size: 17px;*/
            }

                /* Change background color of links on hover */
                ul.tab li a:hover {
                    background-color: #ddd;
                }

                /* Create an active/current tablink class */
                ul.tab li a:focus, .active {
                    background-color: #ccc;
                }
</style>

<table>


    <tr style="overflow: scroll; height: 100px;">

        <td colspan="3">
            <ul class="tab">
                <li><a href="javascript:void(0)" class="tablinks active" onclick="ShowAuditData(1);">Till Last Week</a></li>
                <li><a href="javascript:void(0)" class="tablinks" onclick="ShowAuditData(2);">Last Month</a></li>
                <li><a href="javascript:void(0)" class="tablinks" onclick="ShowAuditData(3);">Last Quarter</a></li>
                <li><a href="javascript:void(0)" class="tablinks" onclick="ShowAuditData(4);">Show All</a></li>
            </ul>
            <div style="overflow: scroll; height: 215px;">
                <asp:Repeater ID="rptUserAudit" runat="server" OnItemDataBound="OnItemDataBound">
                    <HeaderTemplate>
                        <table id="tblAuditGrd" class="table filter_section" style="margin-left: 0px;" cellspacing="0" rules="all" border="1">
                            <tr class="trHeader titlerow">
                                <th scope="col">&nbsp;
                                </th>
                                <th scope="col">Login on
                                </th>
                                <th scope="col">Time Spent
                                </th>
                                <th scope="col">No of Pages Visit
                                </th>
                            </tr>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr class="<%# Container.ItemIndex % 2 == 0 ? "FirstRow" : "AlternateRow" %>  <%# Eval("TimeTabGrp") %>" data-filtertabitem='<%# Eval("TimeTabGrp") %>'>
                            <td>
                                <img alt="" style="cursor: pointer" src="../img/plus.png" />
                                <asp:Panel ID="pnlOrders" runat="server" Style="display: none">
                                    <asp:Repeater ID="rptAuditDtl" runat="server">
                                        <HeaderTemplate>
                                            <table class="ChildGrid" style="margin-left: 0;" cellspacing="0" rules="all" border="1">
                                                <tr class="trHeader">
                                                    <th scope="col">Sr.No
                                                    </th>
                                                    <th scope="col">Visited  Time
                                                    </th>
                                                    <th scope="col">Page
                                                    </th>
                                                </tr>
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <tr class="<%# Container.ItemIndex % 2 == 0 ? "FirstRow" : "AlternateRow" %>">
                                                <td>
                                                    <asp:Label ID="lblSrNo" runat="server" Text='<%# Eval("Id") %>' />
                                                </td>
                                                <td>
                                                    <asp:Label ID="lblVisitedOn" runat="server" Text='<%# Eval("VisitedOn") %>' />
                                                </td>
                                                <td>
                                                    <a href="<%# Eval("PageName") %>" target="_blank" ><%# Eval("PageName") %></a>
                                                    <%--<asp:Label ID="lblPageName" runat="server" Text='<%# Eval("PageName") %>' />--%>
                                                </td>
                                            </tr>
                                        </ItemTemplate>
                                        <FooterTemplate>
                                            </table>
                                        </FooterTemplate>
                                    </asp:Repeater>
                                </asp:Panel>
                                <asp:HiddenField ID="hfAuditID" runat="server" Value='<%# Eval("AuditID") %>' />
                            </td>
                            <td style="text-align: center">
                                <asp:Label ID="lblLastLoginOn" runat="server" Text='<%# Eval("LastLoginOn") %>' />
                            </td>
                            <td style="text-align: center" class="rowDataSd">
                                <%--<asp:Label ID="lblLogOutTime" runat="server" Text='<%# Eval("LogOutTime") %>' />  --%>
                                <asp:Label ID="Label1" runat="server" Text='<%# Eval("TotalVisiteTime") %>' />
                            </td>
                            <td style="text-align: center">
                                <asp:Label ID="lblVisitCount" runat="server" Text='<%# Eval("PageVisitCount") %>' />
                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate>
                        <tr class="totalColumn">
                            <td></td>
                            <td style="text-align: right; font-weight: 700;">Total:</td>
                            <td class="totalCol" style="font-weight: 700; text-align: center"></td>
                            <td></td>
                        </tr>
                        </table>
                    </FooterTemplate>
                </asp:Repeater>
            </div>
        </td>
    </tr>

</table>







<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
<script type="text/javascript">
    function ShowAuditData(TabId) {
        var i, tablinks;

        $('.dayTab').hide();
        $('.MonthTab').hide();
        $('.QTab').hide();
        //ClosingAllTheChildTables();

        tablinks = document.getElementsByClassName("tablinks");
        for (i = 0; i < tablinks.length; i++) {
            tablinks[i].className = tablinks[i].className.replace(" active", "");
        }

        switch (TabId) {

            case 1:
                $('.dayTab').show(900);
                GetTimeTotal('dayTab');

                break;
            case 2:
                $('.MonthTab').show(900);
                GetTimeTotal('MonthTab');

                break;
            case 3:
                $('.QTab').show(900);
                GetTimeTotal('QTab');
                break;
            case 4:
                //Show all
                $('.dayTab , .MonthTab, .QTab').show(800);
                GetTimeTotal('ALL');
                break;
        }
    }



    $("body").on("click", "[src*=plus]", function () {

        //$(this).closest("tr").after("<tr><td></td><td colspan = '999'>" + $(this).next().html() + "</td></tr>")
        $(this).closest("tr").after("<tr><td colspan = '999'>" + $(this).next().html() + "</td></tr>")
        $(this).attr("src", "../img/minus.png");
    });
    $("body").on("click", "[src*=minus]", function () {
        $(this).attr("src", "../img/plus.png");
        $(this).closest("tr").next().remove();
    });


    //Footer Total Cal START



    function GetTimeTotal(ShowTotalCalFor) {
        var totals = [[0, 0, 0], [0, 0, 0], [0, 0, 0]];
        var $dataRows = $("#tblAuditGrd tr:not('.totalColumn, .titlerow')");

        if (ShowTotalCalFor == 'dayTab') {
            //showing calculation for respective selected tab only.
            $dataRows = $("#tblAuditGrd tr:not('.totalColumn, .titlerow, .MonthTab, .QTab')");
        }
        else if (ShowTotalCalFor == 'MonthTab') {
            $dataRows = $("#tblAuditGrd tr:not('.totalColumn, .titlerow, .dayTab, .QTab')");
        }
        else if (ShowTotalCalFor == 'QTab') {
            $dataRows = $("#tblAuditGrd tr:not('.totalColumn, .titlerow, .MonthTab, .dayTab')");
        }

        $dataRows.each(function () {

            //$(this).find('.rowDataSd').each(function (i) {
            $(this).find('.rowDataSd').each(function (i) {

                addtime = $(this).find('span').text()
                addtime = "00:" + addtime

                time = addtime.split(":")
                totals[i][2] += parseInt(time[2]);
                if (totals[i][2] > 60) {
                    totals[i][2] %= 60;
                    totals[i][1] += parseInt(time[1]) + 1;
                }
                else
                    totals[i][1] += parseInt(time[1]);

                if (totals[i][1] > 60) {
                    totals[i][1] %= 60;
                    totals[i][0] += parseInt(time[0]) + 1;
                }
                else
                    totals[i][0] += parseInt(time[0]);
            });
        });
        $("#tblAuditGrd td.totalCol").each(function (i) {
            console.log(totals[i]);
            $(this).html(totals[i][0] + ":" + totals[i][1] + ":" + totals[i][2]);
        });

    }

    //Footer Total Cal END

    $(document).ready(function () {
        GetTimeTotal('dayTab');
    });

</script>
