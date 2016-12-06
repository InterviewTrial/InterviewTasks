<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ucTaskHistory.ascx.cs" Inherits="JG_Prospect.Sr_App.Controls.ucTaskHistory" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<link href="../../css/magnific-popup.css" rel="stylesheet" />
<script src="../../Scripts/jquery.magnific-popup.min.js"></script>
<div>
    <asp:UpdatePanel ID="upTaskHistory" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:TabContainer ID="tcTaskHistory" runat="server" ActiveTabIndex="0" AutoPostBack="false">
                <asp:TabPanel ID="tpTaskHistory_All" runat="server" TabIndex="0">
                    <HeaderTemplate>All</HeaderTemplate>
                    <ContentTemplate>
                        <div class="grid">
                            <asp:UpdatePanel ID="upTaskUsers" runat="server" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <table cellspacing="0" rules="rows" border="1" style="background-color: White; width: 100%; border-collapse: collapse;">
                                        <tbody>
                                            <tr class="trHeader " style="color: White; background-color: Black;">
                                                <th scope="col" style="font-size: Small; width: 10%;">User</th>
                                                <th scope="col" style="font-size: Small; width: 20%;">Date &amp; Time</th>
                                                <th scope="col" style="font-size: Small; width: 60%;">Notes</th>
                                                <th scope="col" style="font-size: Small; width: 10%;">&nbsp;</th>
                                            </tr>
                                            <tr style="background-color: #FFFACD;">
                                                <td colspan="3">
                                                    <asp:UpdatePanel ID="upTaskHelpText" runat="server" UpdateMode="Conditional">
                                                        <ContentTemplate>
                                                            <div style="margin-bottom: 2px; width: 100%; clear: both;">
                                                                <div id="divHelpText" runat="server" onclick="javascript:divHelpText_OnClick(this);"></div>
                                                                <textarea id="txtHelpTextEditor" runat="server" rows="4" style="width: 100%; display: none;"></textarea>
                                                                <asp:Button ID="btnSaveHelpText" Style="display: none;" runat="server" Text="Save Help Text"
                                                                    OnClick="btnSaveHelpText_Click" />
                                                            </div>
                                                        </ContentTemplate>
                                                    </asp:UpdatePanel>
                                                    <div style="border-bottom: 1px dashed black; margin-bottom: 2px; width: 100%; clear: both;">
                                                        Task Description<span style="color: red;">*</span>:
                                                   
                                                    </div>
                                                    <asp:Literal ID="ltlTaskDesc" runat="server"></asp:Literal>
                                                    <asp:TextBox ID="txtTaskDesc" runat="server" TextMode="MultiLine" Rows="7" Style="width: 99%;"></asp:TextBox>
                                                    <asp:RequiredFieldValidator ID="rfvDesc" ValidationGroup="Submit"
                                                        runat="server" ControlToValidate="txtTaskDesc" ForeColor="Red" ErrorMessage="Please Enter Task Description" Display="None">                                 
                                                    </asp:RequiredFieldValidator>
                                                    <asp:ValidationSummary ID="vsDesc" runat="server" ShowMessageBox="True"
                                                        ShowSummary="False" ValidationGroup="Submit" />
                                                </td>

                                                <td>
                                                    <asp:Button ID="btnSaveDesc" Style="display: none;" runat="server" OnClick="btnSaveDesc_Click" Text="Save" CssClass="ui-button" />

                                                    <input id="hdnTaskID" runat="server" type="hidden" />
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                    <asp:GridView ID="gdTaskUsers" runat="server"
                                        EmptyDataText="No task history available!"
                                        AutoGenerateColumns="false"
                                        Width="100%"
                                        AllowSorting="false"
                                        BackColor="White"
                                        PageSize="3"
                                        ShowHeader="false"
                                        GridLines="Horizontal"
                                        OnRowDataBound="gdTaskUsers_RowDataBound"
                                        OnRowCommand="gdTaskUsers_RowCommand"
                                        OnRowEditing="gdTaskUsers_RowEditing"
                                        OnRowUpdating="gdTaskUsers_RowUpdating"
                                        OnRowCancelingEdit="gdTaskUsers_RowCancelingEdit">
                                        <%--<EmptyDataTemplate>
                                                                </EmptyDataTemplate>--%>

                                        <EmptyDataRowStyle ForeColor="White" HorizontalAlign="Center" />

                                        <RowStyle CssClass="FirstRow" BorderStyle="Solid" />
                                        <AlternatingRowStyle CssClass="AlternateRow " />
                                        <Columns>
                                            <asp:TemplateField ShowHeader="True" Visible="false" HeaderText="Note Id" ControlStyle-ForeColor="White"
                                                HeaderStyle-Font-Size="Small" HeaderStyle-Width="10%"
                                                ItemStyle-HorizontalAlign="Left">
                                                <ItemTemplate>
                                                    <asp:Label ID="lblNoteId" runat="server" Text='<%#Eval("ID")%>'></asp:Label>
                                                </ItemTemplate>
                                                <ControlStyle ForeColor="Black" />
                                                <ControlStyle ForeColor="Black" />
                                                <HeaderStyle Font-Size="Small"></HeaderStyle>
                                                <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderStyle-Font-Size="Small" HeaderStyle-Width="10%" ItemStyle-Width="10%"
                                                ItemStyle-HorizontalAlign="Center">
                                                <ItemTemplate>
                                                    <div style="text-align: center;">
                                                        <%# string.Concat(string.IsNullOrEmpty(Eval("FristName").ToString())== true ? 
                                                            Eval("UserFirstName").ToString() : Eval("FristName").ToString() , " ", Eval("LastName").ToString()) %><br />
                                                        <asp:Image CssClass="img-Profile" ID="imgProfile" runat="server" ImageUrl='<%# String.IsNullOrEmpty(Eval("Picture").ToString())== true ? "~/img/JG-Logo-white.gif": Eval("Picture").ToString() %>' />
                                                        <br />
                                                        <asp:HyperLink ForeColor="Blue" runat="server" NavigateUrl='<%# Eval("UserId", Page.ResolveUrl("CreateSalesUser.aspx?id={0}")) %>'>
                                                            <%# string.IsNullOrEmpty(Eval("UserInstallId").ToString())? Eval("UserId") : Eval("UserInstallId") %>
                                                        </asp:HyperLink>
                                                    </div>
                                                </ItemTemplate>
                                                <HeaderStyle Font-Size="Small"></HeaderStyle>
                                                <ItemStyle HorizontalAlign="Center"></ItemStyle>
                                            </asp:TemplateField>
                                            <asp:TemplateField ControlStyle-ForeColor="White"
                                                HeaderStyle-Font-Size="Small" HeaderStyle-Width="20%" ItemStyle-Width="20%"
                                                ItemStyle-HorizontalAlign="Left">
                                                <ItemTemplate>
                                                    <asp:Label ID="lblupdateDate" runat="server" Text='<%#Eval("UpdatedOn")%>'></asp:Label>
                                                </ItemTemplate>
                                                <ControlStyle ForeColor="Black" />
                                                <ControlStyle ForeColor="Black" />
                                                <HeaderStyle Font-Size="Small"></HeaderStyle>
                                                <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                            </asp:TemplateField>
                                            <asp:TemplateField ControlStyle-ForeColor="White" HeaderStyle-Font-Size="Small"
                                                ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="60%" ItemStyle-Width="60%">
                                                <ItemTemplate>
                                                    <div>
                                                        <asp:Label ID="lblNotes" runat="server" Text='<%#Eval("Notes")%>'></asp:Label>
                                                        <div id="divFile" runat="server" visible="false">

                                                            <div style="text-align: center;">
                                                                <asp:LinkButton ID="linkDownLoadFiles" runat="server" CommandName="DownLoadFile" CommandArgument='<%# Eval("Attachment")%>'>
                                                                    <img id="imgFile" alt='<%#Eval("AttachmentOriginal")%>' runat="server" style="width: 100px; height: 100px;" />
                                                                </asp:LinkButton>
                                                            </div>
                                                            <div style="text-align: center;">
                                                                <asp:LinkButton ID="linkOriginalfileName" runat="server" Style="display: none;" CommandName="viewFile" CommandArgument='<%# Eval("Attachment")%>'><small><%#Eval("AttachmentOriginal")%></small></asp:LinkButton>
                                                                <small><%#Eval("AttachmentOriginal")%></small>
                                                            </div>
                                                            <div style="text-align: center; display: none;">
                                                                <asp:LinkButton ID="LinkButton1" OnClick="linkDownLoadFiles_Click"
                                                                    runat="server" Text="Download" CommandName='<%#Eval("Attachment")%>' CommandArgument='<%# Eval("Attachment")%>'></asp:LinkButton>

                                                            </div>
                                                        </div>
                                                    </div>
                                                </ItemTemplate>
                                                <EditItemTemplate>
                                                    <asp:TextBox ID="txtNotes" runat="server" Text='<%#Eval("Notes") %>' TextMode="MultiLine" Width="90%" CssClass="textbox"></asp:TextBox>
                                                </EditItemTemplate>
                                                <ControlStyle ForeColor="Black" />
                                                <ControlStyle ForeColor="Black" />
                                                <HeaderStyle Font-Size="Small"></HeaderStyle>
                                                <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                            </asp:TemplateField>
                                            <%--<asp:TemplateField ShowHeader="True" ControlStyle-ForeColor="White" HeaderStyle-Font-Size="Small"
                                                                            ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="10%">
                                                                            <ItemTemplate>
                                                                                   
                                                                            </ItemTemplate>
                                                                            <ControlStyle ForeColor="Black" />
                                                                            <ControlStyle ForeColor="Black" />
                                                                            <HeaderStyle Font-Size="Small"></HeaderStyle>
                                                                            <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                                                        </asp:TemplateField>--%>
                                            <asp:TemplateField ShowHeader="True" HeaderText="Status"
                                                ControlStyle-ForeColor="White" HeaderStyle-Font-Size="Small" Visible="false"
                                                ItemStyle-HorizontalAlign="Left">
                                                <ItemTemplate>
                                                    <asp:Label ID="lblStatus" runat="server"></asp:Label>
                                                </ItemTemplate>
                                                <ControlStyle ForeColor="Black" />
                                                <ControlStyle ForeColor="Black" />
                                                <HeaderStyle Font-Size="Small"></HeaderStyle>
                                                <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                            </asp:TemplateField>
                                            <asp:TemplateField ShowHeader="True" HeaderText="Status"
                                                ControlStyle-ForeColor="White" HeaderStyle-Font-Size="Small" Visible="false"
                                                ItemStyle-HorizontalAlign="Left">
                                                <ItemTemplate>
                                                    <asp:Label ID="lableFileType" runat="server" Text='<%#Eval("FileType")%>'></asp:Label>
                                                </ItemTemplate>
                                                <ControlStyle ForeColor="Black" />
                                                <ControlStyle ForeColor="Black" />
                                                <HeaderStyle Font-Size="Small"></HeaderStyle>
                                                <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderStyle-Width="10%" ItemStyle-Width="10%">
                                                <EditItemTemplate>
                                                    <asp:Button ID="ButtonUpdate" runat="server" CommandName="Update" Text="Update" />
                                                    <asp:Button ID="ButtonCancel" runat="server" CommandName="Cancel" Text="Cancel" />
                                                </EditItemTemplate>
                                                <ItemTemplate>

                                                    <asp:Button ID="ButtonEdit" runat="server" Style="display: none;" CommandName="Edit" Text="Edit" />
                                                </ItemTemplate>
                                                <ControlStyle ForeColor="Black" />
                                                <ControlStyle ForeColor="Black" />
                                                <HeaderStyle Font-Size="Small"></HeaderStyle>
                                                <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                            </asp:TemplateField>
                                        </Columns>
                                        <HeaderStyle BackColor="Black" ForeColor="White"></HeaderStyle>
                                    </asp:GridView>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </div>
                    </ContentTemplate>
                </asp:TabPanel>

                <asp:TabPanel ID="tpTaskHistory_Notes" runat="server" TabIndex="0">
                    <HeaderTemplate>Notes</HeaderTemplate>

                    <ContentTemplate>
                        <div>
                            <div class="grid">
                                <asp:GridView ID="gdTaskUsersNotes" runat="server"
                                    EmptyDataText="No task not history available!"
                                    ShowHeaderWhenEmpty="true"
                                    AutoGenerateColumns="false"
                                    Width="100%"
                                    HeaderStyle-BackColor="Black"
                                    HeaderStyle-ForeColor="White"
                                    AllowSorting="false"
                                    BackColor="White"
                                    PageSize="3"
                                    GridLines="Horizontal"
                                    OnRowEditing="gdTaskUsersNotes_RowEditing"
                                    OnRowUpdating="gdTaskUsersNotes_RowUpdating"
                                    OnRowCancelingEdit="gdTaskUsersNotes_RowCancelingEdit"
                                    OnRowDataBound="gdTaskUsersNotes_RowDataBound">

                                    <EmptyDataRowStyle ForeColor="White" HorizontalAlign="Center" />
                                    <HeaderStyle CssClass="trHeader " />
                                    <RowStyle CssClass="FirstRow" BorderStyle="Solid" />
                                    <AlternatingRowStyle CssClass="AlternateRow " />

                                    <Columns>
                                        <asp:TemplateField ShowHeader="True" Visible="false" HeaderText="Note Id" ControlStyle-ForeColor="White"
                                            HeaderStyle-Font-Size="Small" HeaderStyle-Width="10%"
                                            ItemStyle-HorizontalAlign="Left">
                                            <ItemTemplate>
                                                <asp:Label ID="lblNoteId" runat="server" Text='<%#Eval("ID")%>'></asp:Label>
                                            </ItemTemplate>
                                            <ControlStyle ForeColor="Black" />
                                            <ControlStyle ForeColor="Black" />
                                            <HeaderStyle Font-Size="Small"></HeaderStyle>
                                            <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                        </asp:TemplateField>

                                        <asp:TemplateField ShowHeader="True" HeaderText="User"
                                            HeaderStyle-Font-Size="Small" HeaderStyle-Width="20%"
                                            ItemStyle-HorizontalAlign="Center">
                                            <ItemTemplate>
                                                <div style="text-align: center;">
                                                    <%# string.Concat(String.IsNullOrEmpty(Eval("FristName").ToString())== true ? 
                                                            Eval("UserFirstName").ToString() : Eval("FristName").ToString() , " ", Eval("LastName").ToString()) %><br />
                                                    <asp:Image CssClass="img-Profile" ID="imgProfile" runat="server" ImageUrl='<%# String.IsNullOrEmpty(Eval("Picture").ToString())== true ? "~/img/JG-Logo-white.gif": Eval("Picture").ToString() %>' />
                                                    <br />
                                                    <asp:HyperLink ForeColor="Blue" runat="server" NavigateUrl='<%# Eval("UserId", Page.ResolveUrl("CreateSalesUser.aspx?id={0}")) %>'>
                                                        <%# string.IsNullOrEmpty(Eval("UserInstallId").ToString())? Eval("UserId") : Eval("UserInstallId") %>
                                                    </asp:HyperLink>
                                                </div>
                                            </ItemTemplate>
                                            <HeaderStyle Font-Size="Small"></HeaderStyle>
                                            <ItemStyle HorizontalAlign="Center"></ItemStyle>
                                        </asp:TemplateField>

                                        <asp:TemplateField ShowHeader="True" HeaderText="Date & Time" ControlStyle-ForeColor="White"
                                            HeaderStyle-Font-Size="Small" HeaderStyle-Width="10%"
                                            ItemStyle-HorizontalAlign="Left">
                                            <ItemTemplate>
                                                <asp:Label ID="lblupdateDate" runat="server" Text='<%#Eval("UpdatedOn")%>'></asp:Label>
                                            </ItemTemplate>
                                            <ControlStyle ForeColor="Black" />
                                            <ControlStyle ForeColor="Black" />
                                            <HeaderStyle Font-Size="Small"></HeaderStyle>
                                            <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Employee Name" HeaderStyle-Width="50%">
                                            <ItemTemplate>
                                                <asp:Label ID="lblNotes" runat="server" Text='<%#Eval("Notes") %>'></asp:Label>
                                            </ItemTemplate>
                                            <EditItemTemplate>
                                                <asp:TextBox ID="txtNotes" runat="server" Text='<%#Eval("Notes") %>' TextMode="MultiLine" Width="90%" CssClass="textbox"></asp:TextBox>
                                            </EditItemTemplate>
                                            <ControlStyle ForeColor="Black" />
                                            <ControlStyle ForeColor="Black" />
                                            <HeaderStyle Font-Size="Small"></HeaderStyle>
                                            <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderStyle-Width="10%">
                                            <EditItemTemplate>
                                                <asp:Button ID="ButtonUpdate" runat="server" CommandName="Update" Text="Update" />
                                                <asp:Button ID="ButtonCancel" runat="server" CommandName="Cancel" Text="Cancel" />
                                            </EditItemTemplate>
                                            <ItemTemplate>
                                                <asp:Button ID="ButtonEdit" runat="server" Style="display: none;" CommandName="Edit" Text="Edit" />
                                            </ItemTemplate>
                                            <ControlStyle ForeColor="Black" />
                                            <ControlStyle ForeColor="Black" />
                                            <HeaderStyle Font-Size="Small"></HeaderStyle>
                                            <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                        </asp:TemplateField>

                                    </Columns>
                                    <HeaderStyle BackColor="Black" ForeColor="White"></HeaderStyle>
                                </asp:GridView>
                            </div>
                        </div>
                    </ContentTemplate>
                </asp:TabPanel>

                <asp:TabPanel ID="tpTaskHistory_FilesAndDocs" runat="server" TabIndex="0" CssClass="task-history-tab">
                    <HeaderTemplate>Files & docs</HeaderTemplate>
                    <ContentTemplate>
                        <div>
                            <asp:Repeater ID="reapeaterLogDoc" runat="server" OnItemDataBound="reapeaterLogDoc_ItemDataBound">
                                <ItemTemplate>
                                    <div style="width: 200px; height: 200px; float: left;">


                                        <div style="text-align: center;">
                                            <asp:Label ID="linkOriginalfileName" runat="server" Text='<%#Eval("AttachmentOriginal")%>' CommandName="viewFile" CommandArgument='<%# Eval("Attachment")%>'></asp:Label>
                                        </div>
                                        <div style="text-align: center;">
                                            <asp:Image ID="imgDoc" runat="server" Width="120px" Height="120px" />
                                            <asp:Label ID="lblMessage" ForeColor="Red" runat="server" Visible="false" />
                                        </div>
                                        <div style="text-align: center;">
                                            <%--<asp:LinkButton ID="linkDownLoadFiles" runat="server" Text="Download" CommandName="DownLoadFiles" CommandArgument='<%# Eval("Attachment")%>'></asp:LinkButton>--%>

                                            <asp:LinkButton ID="linkDownLoadFiles" OnClick="linkDownLoadFiles_Click"
                                                runat="server" Text="Download" CommandName='<%# Eval("AttachmentOriginal")%>' CommandArgument='<%# Eval("Attachment")%>'></asp:LinkButton>

                                        </div>
                                        <div style="text-align: center;">
                                            <asp:Label ID="lblDate" runat="server" Text='<%#Eval("UpdatedOn")%>'></asp:Label>
                                        </div>

                                        <div style="display: none">
                                            <asp:Label ID="lableFileExtension" runat="server" Text='<%#Eval("FileType")%>' Visible="false"></asp:Label>
                                        </div>
                                    </div>

                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </ContentTemplate>
                </asp:TabPanel>

                <asp:TabPanel ID="tpTaskHistory_Images" runat="server" TabIndex="0" CssClass="task-history-tab">
                    <HeaderTemplate>Images</HeaderTemplate>
                    <ContentTemplate>
                        <div>
                            <asp:Repeater ID="reapeaterLogImages" runat="server">
                                <ItemTemplate>
                                    <div style="width: 200px; height: 200px; float: left;">


                                        <div style="text-align: center;">
                                            <asp:LinkButton ID="linkOriginalfileName" runat="server" Text='<%#Eval("AttachmentOriginal")%>' CommandName="viewFile" CommandArgument='<%# Eval("Attachment")%>'></asp:LinkButton>
                                        </div>
                                        <div style="text-align: center;">
                                            <asp:ImageButton ID="imgImages" runat="server" ImageUrl='<%# String.Concat("~/TaskAttachments/",Server.UrlEncode(Eval("Attachment").ToString()))%>'
                                                Width="120px" Height="120px" Style="cursor: pointer" OnClientClick="return LoadDiv(this.src);" />
                                            <asp:Label ID="lblMessage" ForeColor="Red" runat="server" Visible="false" />
                                        </div>
                                        <div style="text-align: center;">
                                            <%--<asp:LinkButton ID="linkDownLoadFiles" runat="server" Text="Download" CommandName="DownLoadFiles" CommandArgument='<%# Eval("Attachment")%>'></asp:LinkButton>--%>

                                            <asp:LinkButton ID="linkDownLoadFiles" OnClick="linkDownLoadFiles_Click"
                                                runat="server" Text="Download" CommandName='<%#Eval("Attachment")%>' CommandArgument='<%# Eval("Attachment")%>'></asp:LinkButton>

                                        </div>
                                        <div style="text-align: center;">
                                            <asp:Label ID="lblDate" runat="server" Text='<%#Eval("UpdatedOn")%>'></asp:Label>
                                        </div>

                                        <div style="display: none">
                                            <asp:Label ID="lableFileType" runat="server" Text='<%#Eval("FileType")%>' Visible="false"></asp:Label>
                                        </div>
                                    </div>

                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </ContentTemplate>
                </asp:TabPanel>

                <asp:TabPanel ID="tpTaskHistory_Links" runat="server" TabIndex="0" CssClass="task-history-tab" Visible="false">
                    <HeaderTemplate>Links</HeaderTemplate>
                    <ContentTemplate>
                        HTML Goes here 4
                                   
                   
                    </ContentTemplate>
                </asp:TabPanel>

                <asp:TabPanel ID="tpTaskHistory_Videos" runat="server" TabIndex="0" CssClass="task-history-tab">
                    <HeaderTemplate>Videos</HeaderTemplate>
                    <ContentTemplate>
                        <div>
                            <asp:Repeater ID="reapeaterLogVideoc" runat="server" OnItemDataBound="reapeaterLogVideoc_ItemDataBound" OnItemCommand="reapeaterLogImages_ItemCommand">
                                <ItemTemplate>
                                    <div style="width: 200px; height: 200px; float: left;">
                                        <div style="text-align: center;">
                                            <asp:LinkButton runat="server" Text='<%#Eval("AttachmentOriginal")%>' ID="linkOriginalfileName" CommandName="viewFile"
                                                OnClientClick='<%# string.Format("return ViewDetails({0}, \"{1}\", \"{2}\", \"{3}\");", Eval("Id"), Eval("Attachment"), Eval("AttachmentOriginal"), Eval("FileType")) %>'
                                                CommandArgument='<%# Eval("Attachment")%>'>
                                            </asp:LinkButton>
                                        </div>
                                        <div style="text-align: center;">
                                            <asp:Image ID="imgImages" runat="server"
                                                Width="120px" Height="120px" />
                                            <asp:Label ID="lblMessage" ForeColor="Red" runat="server" Visible="false" />
                                        </div>
                                        <div style="text-align: center;">
                                            <%-- <asp:LinkButton ID="linkDownLoadFiles" runat="server" Text="Download" CommandName="DownLoadFiles" CommandArgument='<%# Eval("Attachment")%>'></asp:LinkButton>--%>

                                            <asp:LinkButton ID="linkDownLoadFiles" OnClick="linkDownLoadFiles_Click"
                                                runat="server" Text="Download" CommandName='<%#Eval("AttachmentOriginal")%>' CommandArgument='<%# Eval("Attachment")%>'></asp:LinkButton>

                                        </div>
                                        <div style="text-align: center;">
                                            <asp:Label ID="lblDate" runat="server" Text='<%#Eval("UpdatedOn")%>'></asp:Label>
                                        </div>

                                        <div style="display: none">
                                            <asp:Label ID="lableFileType" runat="server" Text='<%#Eval("FileType")%>' Visible="false"></asp:Label>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </ContentTemplate>
                </asp:TabPanel>

                <asp:TabPanel ID="tpTaskHistory_Audios" runat="server" TabIndex="0" CssClass="task-history-tab">
                    <HeaderTemplate>Audios</HeaderTemplate>
                    <ContentTemplate>
                        <div>
                            <asp:Repeater ID="reapeaterLogAudio" runat="server" OnItemDataBound="reapeaterLogAudio_ItemDataBound"
                                OnItemCommand="reapeaterLogImages_ItemCommand">
                                <ItemTemplate>
                                    <div style="width: 200px; height: 200px; float: left;">
                                        <div style="text-align: center;">
                                            <%-- <asp:LinkButton ID="linkOriginalfileName" runat="server" Text='<%#Eval("AttachmentOriginal")%>' 
                                                                                    CommandName="viewFile" CommandArgument='<%# Eval("Attachment")%>'></asp:LinkButton>--%>

                                            <asp:LinkButton runat="server" Text='<%#Eval("AttachmentOriginal")%>' ID="linkOriginalfileName" CommandName="viewFile"
                                                OnClientClick='<%# string.Format("return ViewDetails({0}, \"{1}\", \"{2}\", \"{3}\");", Eval("Id"), Eval("Attachment"), Eval("AttachmentOriginal"), Eval("FileType")) %>'
                                                CommandArgument='<%# Eval("Attachment")%>'>
                                            </asp:LinkButton>

                                        </div>
                                        <div style="text-align: center;">
                                            <asp:Image ID="imgImages" runat="server" ImageUrl='<%#Eval("FilePath")%>'
                                                Width="120px" Height="120px" />
                                            <asp:Label ID="lblMessage" ForeColor="Red" runat="server" Visible="false" />
                                        </div>
                                        <div style="text-align: center;">
                                            <%--<asp:LinkButton ID="linkDownLoadFiles" runat="server" Text="Download" CommandName="DownLoadFiles" CommandArgument='<%# Eval("Attachment")%>'></asp:LinkButton>--%>

                                            <asp:LinkButton ID="linkDownLoadFiles" OnClick="linkDownLoadFiles_Click"
                                                runat="server" Text="Download" CommandName='<%#Eval("AttachmentOriginal")%>' CommandArgument='<%# Eval("Attachment")%>'>
                                            </asp:LinkButton>

                                        </div>
                                        <div style="text-align: center;">
                                            <asp:Label ID="lblDate" runat="server" Text='<%#Eval("UpdatedOn")%>'></asp:Label>
                                        </div>

                                        <div style="display: none">
                                            <asp:Label ID="lableFileType" runat="server" Text='<%#Eval("FileType")%>' Visible="false"></asp:Label>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>

                        </div>
                    </ContentTemplate>
                </asp:TabPanel>
            </asp:TabContainer>

            <div style="margin-top: 5px" id="divTableNote" runat="server">
                <div>
                    <div>
                        <div>
                            <table style="width: 100%">
                                <tr>

                                    <td>Notes:
                                  
                                        <div style="clear: both;">
                                            <asp:TextBox ID="txtNote" runat="server" TextMode="MultiLine" Width="100%" CssClass="textbox" Rows="7" ValidationGroup="Validation"></asp:TextBox>
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidatorName" runat="server" ControlToValidate="txtNote"
                                                Display="None" ErrorMessage="Please Enter Note" ValidationGroup="Validation"></asp:RequiredFieldValidator>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>

                <div id="divAddNoteOrImage" runat="server">
                    <table style="width: 100%">
                        <tr>
                            <td style="width: 50%">
                                <div class="btn_sec" style="text-align: right;">
                                    <asp:Button ID="btnAddNote" runat="server" Text="Add Note" CssClass="ui-button" OnClick="btnAddNote_Click" ValidationGroup="Validation" />
                                    <asp:ValidationSummary ID="ValidationSummary2" runat="server" ShowMessageBox="True"
                                        ShowSummary="False" ValidationGroup="Validation" />
                                </div>
                            </td>
                            <td style="width: 50%">
                                <div id="divNoteDropzone" runat="server" class="dropzone work-file-Note">
                                    <div class="fallback">
                                        <input name="file" type="file" multiple />
                                        <input type="submit" value="Upload" />
                                    </div>
                                </div>
                                <div id="divNoteDropzonePreview" runat="server" class="dropzone-previews work-file-previews-note">
                                </div>
                                <div class="hide">
                                    <asp:Button ID="btnUploadLogFiles" runat="server" Text="Upload File" CssClass="ui-button" OnClick="btnUploadLogFiles_Click" ValidationGroup="Submit" />
                                </div>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</div>
<input id="hdnNoteId" runat="server" type="hidden" />
<input id="hdnNoteAttachments" runat="server" type="hidden" />
<input id="hdnNoteFileType" runat="server" type="hidden" />

<div class="hide">
    <div id="divFilePreviewPopup" runat="server" title="File Preview">
        <table width="100%" cellpadding="0" cellspacing="5">
            <tr style="background-color: gray">
                <td align="center" colspan="2" style="color: White; font-weight: bold; font-size: 1.2em; padding: 3px">
                    <asp:Label ID="lblFileName" ForeColor="White" runat="server" />
                </td>
            </tr>
        </table>
        <div style="padding: 5px">
            <asp:Image ID="imgPreview" Height="98%" Width="98%" runat="server" Visible="false" />
            <div runat="server" height="98%" width="98%" id="divVideo">
                <video height="98%" width="98%" id="tagVideo" controls>
                    <source type="video/mp4" runat="server" id="videomp4" />
                    <source type="video/3gpp" runat="server" id="video3gpp" />
                    <source type="video/mpeg" runat="server" id="videompeg" />
                    <source type="video/x-ms-wmv" runat="server" id="videowmv" />
                    <source type="video/webm" runat="server" id="videowebm" />
                </video>
            </div>
            <div runat="server" height="98%" width="98%" id="divAudio">
                <audio height="98%" width="98%" controls>
                    <source type="audio/mp3" runat="server" id="audiomp3" />
                    <source type="audio/mp4" runat="server" id="audiomp4" />
                    <source type="audio/x-ms-wma" runat="server" id="audiowma" />
                </audio>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">

    Dropzone.autoDiscover = false;

    $(function () {
        ucTaskHistory_Initialize();

    });

    var prmTaskGenerator = Sys.WebForms.PageRequestManager.getInstance();

    prmTaskGenerator.add_endRequest(function () {
        ucTaskHistory_Initialize();

    });

    function ucTaskHistory_Initialize() {
        ucTaskHistory_ApplyDropZone();
        //BindDescriptionAutoSaveevent();
    }

    function divHelpText_OnClick(sender) {
        var txtHelpTextEditor = $('#<%=txtHelpTextEditor.ClientID%>');
        if (txtHelpTextEditor.length > 0) {
            txtHelpTextEditor.show();
            $(sender).hide();

            SetCKEditorForPageContent(txtHelpTextEditor.attr('id'), '#<%= btnSaveHelpText.ClientID %>');
        }
    }

    function BindDescriptionAutoSaveevent() {

        $('#<%=txtTaskDesc.ClientID %>').blur(

            function () {
                var TaskId = $('#<%=hdnTaskID.ClientID%>').val();
                if (TaskId != "" && TaskId != "0") {
                    $('#<%=btnSaveDesc.ClientID %>').click();
                }
            }

            );
        }

        var objNoteDropzone;

        function ucTaskHistory_ApplyDropZone() {
            //debugger;
            ////User's drag and drop file attachment related code

            //remove already attached dropzone.
            if (objNoteDropzone) {
                objNoteDropzone.destroy();
                objNoteDropzone = null;
            }
            objNoteDropzone = GetWorkFileDropzone("#<%=divNoteDropzone.ClientID%>", '#<%=divNoteDropzonePreview.ClientID%>', '#<%= hdnNoteAttachments.ClientID %>', '#<%=btnUploadLogFiles.ClientID%>');
        }

        function ViewDetails(Id, longName, shortName, fileType) {

            $("#<%=lblFileName.ClientID %>").text(shortName);
            var filePath = '../TaskAttachments/' + longName;

            var fileName = filePath;
            var fileExtension = fileName.substring(fileName.lastIndexOf('.') + 1);

            var tv_main_channel = "";

            if (fileType == 3) // Video
            {
                $('#Vedioplayer').show();
                $('#Audiolayer').hide();
                if (fileExtension == "mp4") {
                    tv_main_channel = $('#mp4Source');
                }
                tv_main_channel.attr('src', filePath);
                var video_block = $('#Vedioplayer');
                video_block.load();
            }

            if (fileType == 2) // Audio
            {
                $('#Vedioplayer').hide();
                $('#Audiolayer').show();
                if (fileExtension == "mp4") {
                    tv_main_channel = $('#mp4Source');
                }
                if (fileExtension == "mp3") {
                    tv_main_channel = $('#mp3Source');
                }

                tv_main_channel.attr('src', filePath);
                var audio_block = $('#Audiolayer');
                audio_block.load();
            }
        }
        function LoadDiv(url) {

            var img = new Image();
            var bcgDiv = document.getElementById("divBackground");
            var imgDiv = document.getElementById("divImage");
            var imgFull = document.getElementById("imgFull");
            var imgLoader = document.getElementById("imgLoader");
            imgLoader.style.display = "block";
            img.onload = function () {
                imgFull.src = img.src;
                imgFull.style.display = "block";
                imgLoader.style.display = "none";
            };
            img.src = url;
            var width = document.body.clientWidth;
            if (document.body.clientHeight > document.body.scrollHeight) {
                bcgDiv.style.height = document.body.clientHeight + "px";
            }
            else {
                bcgDiv.style.height = document.body.scrollHeight + "px";
            }
            imgDiv.style.left = (width - 650) / 2 + "px";
            imgDiv.style.top = "20px";
            bcgDiv.style.width = "100%";

            bcgDiv.style.display = "block";
            imgDiv.style.display = "block";
            return false;
        }
        function HideDiv() {
            var bcgDiv = document.getElementById("divBackground");
            var imgDiv = document.getElementById("divImage");
            var imgFull = document.getElementById("imgFull");
            if (bcgDiv != null) {
                bcgDiv.style.display = "none";
                imgDiv.style.display = "none";
                imgFull.style.display = "none";
            }
        }


</script>
