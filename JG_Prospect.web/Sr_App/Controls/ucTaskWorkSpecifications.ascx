<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ucTaskWorkSpecifications.ascx.cs" Inherits="JG_Prospect.Sr_App.Controls.ucTaskWorkSpecifications" %>

<div data-id="WorkSpecificationPlaceholder" data-parent-work-specification-id="0">
</div>

<script data-id="tmpWorkSpecificationSection" type="text/template" class="hide">
    <table data-id="tblWorkSpecification" data-parent-work-specification-id="{parent-id}" class="table" width="100%" cellspacing="0" cellpadding="0">
        <thead>
            <tr data-id="trActiveItemData">
                <td align="left" colspan="3">
                    <div style="font-size: 9px; float: left;">
                        <em data-id="emActiveIndex"></em> of <em data-id="emTotal"></em> specifications
                    </div>
                </td>
            </tr>
            <tr class="trHeader">
                <th style="width: 35px;">ID</th>
                <th>Description</th>
                <th style="width: 65px;">Sign Off</th>
            </tr>
        </thead>
        <tbody>
        </tbody>
        <tfoot>
            <tr class="FirstRow">
                <td>
                    <small>
                        <label data-id="lblCustomId{parent-id}_Footer" />
                    </small>
                </td>
                <td>
                    <input data-id="txtTitle{parent-id}_Footer" type="text" class="textbox" placeholder="Title" style="width: 25%;" /><input data-id="txtURL{parent-id}_Footer" class="textbox" placeholder="Url" type="text" style="width: 70%;" />
                    <br />
                    <textarea data-id="txtWorkSpecification{parent-id}_Footer" id="txtWorkSpecification{parent-id}_Footer" rows="7" style="width: 95%;"></textarea>
                    <button data-id="btnAdd{parent-id}_Footer" data-parent-work-specification-id="{parent-id}" onclick="javascript:return OnAddClick(this);">Add</button>
                </td>
                <td>
                    <div>
                        <input data-id="chkAdminApproval{parent-id}_Footer" class="fz fz-admin" data-parent-work-specification-id="{parent-id}" data-footer="true" type="checkbox" title="Admin" onchange='<%=GetPasswordCheckBoxChangeEvent(true,false,false)%>' />&nbsp;
                        <input data-id="chkITLeadApproval{parent-id}_Footer" class="fz fz-techlead" data-parent-work-specification-id="{parent-id}" data-footer="true" type="checkbox" title="IT Lead" onchange='<%=GetPasswordCheckBoxChangeEvent(false,true,false)%>' />&nbsp;
                        <input data-id="chkUserApproval{parent-id}_Footer" class="fz fz-user" data-parent-work-specification-id="{parent-id}" data-footer="true" type="checkbox" title="User" onchange='<%=GetPasswordCheckBoxChangeEvent(false,false,true)%>' />
                    </div>
                    <div data-id="divPassword{parent-id}_Footer">
                        <input data-id="txtPassword{parent-id}_Footer" type="password" placeholder='<%=GetPasswordPlaceholder()%>' class="textbox" style="width: 110px;"
                            data-parent-work-specification-id="{parent-id}" />
                    </div>
                </td>
            </tr>
            <tr class="pager">
                <td colspan="3">&nbsp;
                </td>
            </tr>
        </tfoot>
    </table>
</script>
<script data-id="tmpWorkSpecificationRow" type="text/template" class="hide">
    <tr data-work-specification-id="{id}">
        <td valign="top" style="width: 35px;">
            <small>
                <label data-id="lblCustomId{id}" />
            </small>
        </td>
        <td>
            <div style="margin-bottom: 5px;">
                <div data-id="divViewWorkSpecification{id}" data-work-specification-id="{id}" onclick="javascript:OndivViewWorkSpecificationClick(this);">
                    <div style="background-color: white; border-bottom: 1px solid silver;">
                        <label><small><i>TITLE:</i></small></label><div data-id="divTitle{id}" style="display: inline; line-height: 15px; min-height: 15px; background-color: white;"></div><br />
                        <label><small><i>URL:</i></small></label>
                        <div data-id="divURL{id}" style="display: inline; line-height: 15px; min-height: 15px;"></div>
                    </div>
                    <div data-id="divWorkSpecification{id}" style="padding: 3px; display: block; min-height: 15px; line-height: 15px; background-color: white;"></div>
                </div>
                <div data-id="divEditWorkSpecification{id}">
                    <input data-id="txtTitle{id}" placeholder="Title" class="textbox" type="text" style="width: 25%;" />
                    <input data-id="txtURL{id}" placeholder="Url" class="textbox" type="text" style="width: 70%;" />
                    <br />
                    <textarea data-id="txtWorkSpecification{id}" row="7" id="txtWorkSpecification{id}" style="width: 95%;"></textarea>
                </div>
                <div data-id="divViewWorkSpecificationButtons{id}" style="display: inline;">
                    <a href="javascript:void(0);" data-work-specification-id="{id}" onclick="javascript:return OnEditClick(this);">Edit</a>&nbsp;
                    <a href="javascript:void(0);" data-work-specification-id="{id}" data-parent-work-specification-id="{parent-id}" onclick="javascript:return OnDeleteClick(this);">Delete</a>&nbsp;
                </div>
                <div data-id="divEditWorkSpecificationButtons{id}" style="display: inline;">
                    <a href="javascript:void(0);" data-id="btnSave{id}" data-work-specification-id="{id}" data-parent-work-specification-id="{parent-id}" onclick="javascript:return OnSaveClick(this);">Save</a>&nbsp;
                    <a href="javascript:void(0);" data-work-specification-id="{id}" onclick="javascript:return OnCancelEditClick(this);">Cancel</a>&nbsp;
                </div>
                <a href="javascript:void(0);" data-id="btnAddSubSection{id}" data-work-specification-id="{id}" onclick="javascript:return OnAddSubSectionClick(this);">View More(+)</a>
                <a href="javascript:void(0);" data-id="btnViewSubSection{id}" data-work-specification-id="{id}" onclick="javascript:return OnViewSubSectionClick(this);">View More(+)</a>
                <a href="javascript:void(0);" data-id="btnHideSubSection{id}" data-work-specification-id="{id}" onclick="javascript:return OnHideSubSectionClick(this);">View Less(-)</a>
            </div>
            <div data-id="WorkSpecificationPlaceholder" data-parent-work-specification-id="{id}"></div>
        </td>
        <td valign="top" style="width: 65px;">
            <a href="javascript:void(0);" data-id="btnShowFeedbackPopup{id}" data-work-specification-id="{id}" onclick="javascript:return OnShowFeedbackPopupClick(this);">Comment</a>
            <div>
                <input data-id="chkAdminApproval{id}" class="fz fz-admin" data-footer="false" data-work-specification-id="{id}" type="checkbox" title="Admin" onchange='<%=GetPasswordCheckBoxChangeEvent(true,false,false)%>' />&nbsp;
                <input data-id="chkITLeadApproval{id}" class="fz fz-techlead" data-footer="false" data-work-specification-id="{id}" type="checkbox" title="IT Lead" onchange='<%=GetPasswordCheckBoxChangeEvent(false,true,false)%>' />&nbsp;
                <input data-id="chkUserApproval{id}" class="fz fz-user" data-footer="false" data-work-specification-id="{id}" type="checkbox" title="User" onchange='<%=GetPasswordCheckBoxChangeEvent(false,false,true)%>' />
            </div>
            <div data-id="divPassword{id}">
                <input data-id="txtPassword{id}" type="password" placeholder='<%=GetPasswordPlaceholder()%>' class="textbox" style="width: 110px;"
                    data-parent-work-specification-id="{parent-id}" data-work-specification-id="{id}"
                    onchange="javascript:OnApprovalPasswordChanged(this);" />
            </div>
        </td>
    </tr>
</script>
<div class="hide">
    <asp:UpdatePanel ID="upHidden" runat="server">
        <ContentTemplate>
            <asp:Button ID="btnUpdateTaskStatus" runat="server" CausesValidation="false" OnClick="btnUpdateTaskStatus_Click" />

            <asp:HiddenField ID="hdnFeedbackPopup" runat="server" />
            <asp:Button ID="btnShowFeedbackPopup" runat="server" CausesValidation="false" OnClick="btnShowFeedbackPopup_Click" />
        </ContentTemplate>
    </asp:UpdatePanel>
</div>

<%--Popup Stars--%>
<div class="hide">

    <%--Sub Task Feedback Popup--%>
    <div id="divTwsFeedbackPopup" runat="server" title="Task Work Specification Feedback">
        <asp:UpdatePanel ID="upTwsFeedbackPopup" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <fieldset>
                    <legend>
                        <asp:Literal ID="ltrlTwsFeedbackTitle" runat="server" /></legend>
                    <table id="tblAddEditTwsFeedback" runat="server" cellspacing="3" cellpadding="3" width="100%">
                        <tr>
                            <td colspan="2">&nbsp;
                            </td>
                        </tr>
                        <tr>
                            <td width="90" align="right" valign="top">Description:
                            </td>
                            <td>
                                <asp:TextBox ID="txtTwsComment" runat="server" CssClass="textbox" TextMode="MultiLine" Rows="4" Width="90%" />
                                <asp:RequiredFieldValidator ID="rfvComment" ValidationGroup="comment_tws"
                                    runat="server" ControlToValidate="txtTwsComment" ForeColor="Red" ErrorMessage="Please comment" Display="None" />
                                <asp:ValidationSummary ID="vsComment" runat="server" ValidationGroup="comment_tws" ShowSummary="False" ShowMessageBox="True" />
                            </td>
                        </tr>
                        <tr>
                            <td align="right" valign="top">Files:
                            </td>
                            <td>
                                <input id="hdnTwsAttachments" runat="server" type="hidden" />
                                <input id="hdnTwsFileType" runat="server" type="hidden" />
                                <div id="divTwsDropzone" runat="server" class="dropzone ">
                                    <div class="fallback">
                                        <input name="file" type="file" multiple />
                                        <input type="submit" value="Upload" />
                                    </div>
                                </div>
                                <div id="divTwsDropzonePreview" runat="server" class="dropzone-previews ">
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <div class="btn_sec">
                                    <asp:Button ID="btnSaveTwsFeedback" runat="server" ClientIDMode="AutoID" ValidationGroup="comment_tws" OnClick="btnSaveTwsFeedback_Click" CssClass="ui-button" Text="Save" />
                                    <asp:Button ID="btnSaveTwsAttachment" runat="server" OnClick="btnSaveTwsAttachment_Click" Style="display: none;" Text="Save Attachement" />
                                </div>
                            </td>
                        </tr>
                    </table>
                </fieldset>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>

</div>
<%--Popup Ends--%>

<%--Task Work Specifications Script--%>
<script type="text/javascript">

    var strWorkSpecificationSectionTemplate = $('script[data-id="tmpWorkSpecificationSection"]').html().toString();
    var strWorkSpecificationRowTemplate = $('script[data-id="tmpWorkSpecificationRow"]').html().toString();

    var TaskId = <%=this.TaskId%>;
    var AdminMode = <%=this.IsAdminMode.ToString().ToLower()%>;

    $(document).ready(function() {
    
        //Initialize_WorkSpecifications();

    });

    function Initialize_WorkSpecifications() {
        console.log('Initialize_WorkSpecifications');
        GetWorkSpecifications(0, OnWorkSpecificationsResponseReceived);
    }

    function OnWorkSpecificationsResponseReceived(result,intParentId){

        var $WorkSpecificationSectionTemplate = $(strWorkSpecificationSectionTemplate.replace(/{parent-id}/gi,intParentId));
        
        $WorkSpecificationSectionTemplate.find('label[data-id="lblCustomId'+intParentId+'_Footer"]').html(result.NextCustomId);
        $WorkSpecificationSectionTemplate.find('div[data-id="divPassword'+intParentId+'_Footer"]').hide();

        if(intParentId == 0) {
            $WorkSpecificationSectionTemplate.find('em[data-id="emActiveIndex"]').html(0);
            $WorkSpecificationSectionTemplate.find('em[data-id="emTotal"]').html(result.TotalRecordCount);
        }

        if(result.TotalRecordCount > 0) {

            var arrData = result.Records;

            for (var i = 0; i < arrData.length; i++) {
                var $WorkSpecificationRowTemplate = $(strWorkSpecificationRowTemplate.replace(/{parent-id}/gi,intParentId).replace(/{id}/gi,arrData[i].Id));

                if(i % 2 == 0) {
                    $WorkSpecificationRowTemplate.addClass('AlternateRow');
                }
                else {
                    $WorkSpecificationRowTemplate.addClass('FirstRow');
                }
                
                if(intParentId == 0) {
                    $WorkSpecificationRowTemplate.attr('data-index',(i+1));
                    $WorkSpecificationRowTemplate.attr('onclick','SetActiveItemIndex('+arrData[i].Id+')');
                    $WorkSpecificationRowTemplate.attr('title', (i+1) + ' of ' + result.TotalRecordCount);
                }

                $WorkSpecificationRowTemplate.find('label[data-id="lblCustomId'+arrData[i].Id+'"]').html(arrData[i].CustomId);
                $WorkSpecificationRowTemplate.find('textarea[data-id="txtWorkSpecification'+arrData[i].Id+'"]').html(arrData[i].Description);
                $WorkSpecificationRowTemplate.find('div[data-id="divWorkSpecification'+arrData[i].Id+'"]').html(arrData[i].Description);
                $WorkSpecificationRowTemplate.find('input[data-id="txtTitle'+arrData[i].Id+'"]').val(arrData[i].Title);
                $WorkSpecificationRowTemplate.find('div[data-id="divTitle'+arrData[i].Id+'"]').html(arrData[i].Title);
                $WorkSpecificationRowTemplate.find('input[data-id="txtURL'+arrData[i].Id+'"]').val(arrData[i].URL);
                $WorkSpecificationRowTemplate.find('div[data-id="divURL'+arrData[i].Id+'"]').html(arrData[i].URL);
                
                $WorkSpecificationRowTemplate.find('div[data-id="divEditWorkSpecification'+arrData[i].Id+'"]').hide();
                $WorkSpecificationRowTemplate.find('div[data-id="divEditWorkSpecificationButtons'+arrData[i].Id+'"]').hide();
                $WorkSpecificationRowTemplate.find('a[data-id="btnHideSubSection'+arrData[i].Id+'"]').hide();

                if(arrData[i].TaskWorkSpecificationsCount == 0) {
                    $WorkSpecificationRowTemplate.find('a[data-id="btnViewSubSection'+arrData[i].Id+'"]').hide();
                }
                else {
                    $WorkSpecificationRowTemplate.find('a[data-id="btnAddSubSection'+arrData[i].Id+'"]').hide();
                }

                if(arrData[i].AdminStatus) {
                    $WorkSpecificationRowTemplate.find('input[data-id="chkAdminApproval'+arrData[i].Id+'"]').attr('disabled','disabled');
                    $WorkSpecificationRowTemplate.find('input[data-id="chkAdminApproval'+arrData[i].Id+'"]').attr('checked',true);
                }
                if(arrData[i].TechLeadStatus) {
                    $WorkSpecificationRowTemplate.find('input[data-id="chkITLeadApproval'+arrData[i].Id+'"]').attr('disabled','disabled');
                    $WorkSpecificationRowTemplate.find('input[data-id="chkITLeadApproval'+arrData[i].Id+'"]').attr('checked',true);
                }
                if(arrData[i].OtherUserStatus) {
                    $WorkSpecificationRowTemplate.find('input[data-id="chkUserApproval'+arrData[i].Id+'"]').attr('disabled','disabled');
                    $WorkSpecificationRowTemplate.find('input[data-id="chkUserApproval'+arrData[i].Id+'"]').attr('checked',true);
                }

                $WorkSpecificationRowTemplate.find('div[data-id="divPassword'+arrData[i].Id+'"]').hide();
                if(arrData[i].AdminStatus && arrData[i].TechLeadStatus && arrData[i].OtherUserStatus) {
                    $WorkSpecificationRowTemplate.find('div[data-id="divPassword'+arrData[i].Id+'"]').remove();
                }
                
                $WorkSpecificationSectionTemplate.find('tbody').append($WorkSpecificationRowTemplate);
            }
        }

        // do not show header for sub sections.
        if(intParentId != 0) {
            $WorkSpecificationSectionTemplate.find('thead').remove();
        }
        
        // clear div and append new result.
        $('div[data-parent-work-specification-id="'+intParentId+'"]').html('');
        $('div[data-parent-work-specification-id="'+intParentId+'"]').append($WorkSpecificationSectionTemplate);
        
        // show ck editor in footer row.
        SetCKEditor('txtWorkSpecification' + intParentId + '_Footer');

        if( !AdminMode || (result.TotalRecordCount > 0 && result.PendingCount == 0)) {
            $('div[data-parent-work-specification-id="0"]').find('tfoot').html('');
            $('div[data-parent-work-specification-id="0"]').find('div[data-id*="divViewWorkSpecificationButtons"]').remove();
            $('div[data-parent-work-specification-id="0"]').find('div[data-id*="divEditWorkSpecification"]').remove();
            $('div[data-parent-work-specification-id="0"]').find('div[data-id*="divEditWorkSpecificationButtons"]').remove();
            $('div[data-parent-work-specification-id="0"]').find('a[data-id*="btnAddSubSection"]').hide();
        }
    }

    function GetWorkSpecifications(intParentId,callback) {
        
        ShowAjaxLoader();

        $.ajax
        (
            {
                url: '../WebServices/JGWebService.asmx/GetTaskWorkSpecifications',
                contentType: 'application/json; charset=utf-8;',
                type: 'POST',
                dataType: 'json',
                data: '{ TaskId: ' +TaskId + ', intParentTaskWorkSpecificationId: ' + intParentId + ' }',
                asynch: false,
                success: function (data) {
                    HideAjaxLoader();
                    if(typeof(callback)==="function"){
                        callback(data.d,intParentId);
                    }
                },
                error: function (a, b, c) {
                    console.log(a);
                    HideAjaxLoader();
                }
            }
        );
    }
    
    function SetActiveItemIndex(intId) {
        var $row = $('tr[data-work-specification-id="'+intId+'"]');
        if($row.attr('data-index')) {
            $('em[data-id="emActiveIndex"]').html($row.attr('data-index'));
        }
    }

    function OndivViewWorkSpecificationClick(sender) {
        var $sender = $(sender);

        var Id = $sender.attr('data-work-specification-id');
        
        if($('div[data-id="divEditWorkSpecification'+Id+'"]').length > 0) {
            OnEditClick(sender);
        }
    }

    function OnEditClick(sender) {
        var $sender = $(sender);
        
        var Id = $sender.attr('data-work-specification-id');

        // show edit and hide view section.
        $('div[data-id="divEditWorkSpecification' + Id + '"]').show();
        $('div[data-id="divEditWorkSpecificationButtons' + Id + '"]').show();
        $('div[data-id="divViewWorkSpecification' + Id + '"]').hide();
        $('div[data-id="divViewWorkSpecificationButtons' + Id + '"]').hide();

        SetCKEditor('txtWorkSpecification'+Id);

        SetActiveItemIndex(Id);

        return false;
    }

    function OnDeleteClick(sender) {

        if(confirm("Do you wish to delete work specification?")) {
        
            ShowAjaxLoader();

            $sender = $(sender);
        
            var Id = $sender.attr('data-work-specification-id');
            var intParentId = $sender.attr('data-parent-work-specification-id');

            $.ajax
            (
                {
                    url: '../WebServices/JGWebService.asmx/DeleteTaskWorkSpecification',
                    contentType: 'application/json; charset=utf-8;',
                    type: 'POST',
                    dataType: 'json',
                    data: '{ intId:' + Id + ' }',
                    asynch: false,
                    success: function (data) {
                        HideAjaxLoader();
                        if(data.d) {
                            GetWorkSpecifications(intParentId, OnWorkSpecificationsResponseReceived);
                            alert('Specification deleted successfully.');
                        }
                        else {
                            alert('Specification delete was not successfull, Please try again later.');
                        }
                    },
                    error: function (a, b, c) {
                        console.log(a);
                        HideAjaxLoader();
                    }
                }
            );
        }

        return false;
    }

    function OnCancelEditClick(sender) {
        $sender = $(sender);
        
        var Id = $sender.attr('data-work-specification-id');

        // show view and hide edit section.
        $('div[data-id="divViewWorkSpecification' + Id + '"]').show();
        $('div[data-id="divViewWorkSpecificationButtons' + Id + '"]').show();
        $('div[data-id="divEditWorkSpecification' + Id + '"]').hide();
        $('div[data-id="divEditWorkSpecificationButtons' + Id + '"]').hide();

        return false;
    }

    function OnAddClick(sender) { 
        
        ShowAjaxLoader();

        var Id= 0;
        var intParentId = $(sender).attr('data-parent-work-specification-id');
        var strCustomId = $.trim($('label[data-id="lblCustomId'+intParentId+'_Footer"]').text());
        var strDescription = GetCKEditorContent('txtWorkSpecification'+intParentId+'_Footer');
        var strPassword = $('input[data-id="txtPassword'+intParentId+'_Footer"]').val();
        var strTitle = $('input[data-id="txtTitle'+intParentId+'_Footer"]').val();
        var strURL = $('input[data-id="txtURL'+intParentId+'_Footer"]').val();

        var postData = '{ intId:' + Id + ', strCustomId: \'' + strCustomId + '\', strDescription: \'' + strDescription + '\', strTitle: \'' + strTitle + '\', strURL: \'' + strURL + '\', intTaskId: ' + TaskId  + ', intParentTaskWorkSpecificationId: ' + intParentId + ', strPassword: \'' + strPassword + '\'  }';
        
        console.log(postData.replace(/\\n/g, "\\n")
                            .replace(/\\'/g, "\\'")
                            .replace(/\\"/g, '\\"')
                            .replace(/\\&/g, "\\&")
                            .replace(/\\r/g, "\\r")
                            .replace(/\\t/g, "\\t")
                            .replace(/\\b/g, "\\b")
                            .replace(/\\f/g, "\\f"));

        $.ajax
        (
            {
                url: '../WebServices/JGWebService.asmx/SaveTaskWorkSpecification',
                contentType: 'application/json; charset=utf-8;',
                type: 'POST',
                dataType: 'json',
                data: postData,
                asynch: false,
                success: function (data) {
                    HideAjaxLoader();
                    if(data.d) {
                        // this will update task status from open to specs-in-progress and vice versa based on over all freezing status of work specifications.
                        $('#<%=btnUpdateTaskStatus.ClientID%>').click();
                    GetWorkSpecifications(intParentId, OnWorkSpecificationsResponseReceived);
                    alert('Specification saved successfully.');
                }
                else {
                    alert('Specification update was not successfull, Please try again later.');
                }
                },
                error: function (a, b, c) {
                    console.log(a);
                    HideAjaxLoader();
                }
            }
        );

        return false;
    }

    function OnSaveClick(sender) {
    
        ShowAjaxLoader();

        var Id= $(sender).attr('data-work-specification-id');
        var intParentId = $(sender).attr('data-parent-work-specification-id');
        var strCustomId = $.trim($('label[data-id="lblCustomId'+Id+'"]').text());
        var strDescription = GetCKEditorContent('txtWorkSpecification'+ Id);
        var strTitle = $('input[data-id="txtTitle'+Id+'"]').val();
        var strURL = $('input[data-id="txtURL'+Id+'"]').val();

        var postData = '{ intId:' + Id + ', strCustomId: \'' + strCustomId + '\', strDescription: \'' + strDescription + '\', strTitle: \'' + strTitle + '\', strURL: \'' + strURL + '\', intTaskId: ' + TaskId  + ', intParentTaskWorkSpecificationId: ' + intParentId + ', strPassword: \'\'  }';
        
        console.log(postData.replace(/\\n/g, "\\n")
                            .replace(/\\'/g, "\\'")
                            .replace(/\\"/g, '\\"')
                            .replace(/\\&/g, "\\&")
                            .replace(/\\r/g, "\\r")
                            .replace(/\\t/g, "\\t")
                            .replace(/\\b/g, "\\b")
                            .replace(/\\f/g, "\\f"));
        
        $.ajax
        (
            {
                url: '../WebServices/JGWebService.asmx/SaveTaskWorkSpecification',
                contentType: 'application/json; charset=utf-8;',
                type: 'POST',
                dataType: 'json',
                data:  postData,
                asynch: false,
                success: function (data) {
                    HideAjaxLoader();
                    if(data.d) {
                        // update div containing work specification content.
                        $('div[data-id="divTitle'+Id+'"]').text(strTitle);
                        $('div[data-id="divURL'+Id+'"]').text(strURL);
                        $('div[data-id="divWorkSpecification'+Id+'"]').html(strDescription);
                        
                        alert('Specification saved successfully.');
                        // this will update task status from open to specs-in-progress and vice versa based on over all freezing status of work specifications.
                        $('#<%=btnUpdateTaskStatus.ClientID%>').click();
                        OnCancelEditClick(sender);
                    }
                    else {
                        alert('Specification update was not successfull, Please try again later.');
                    }
                },
                error: function (a, b, c) {
                    console.log(a);
                    HideAjaxLoader();
                }
            }
        );

            return false;
        }

        function OnShowFeedbackPopupClick(sender) {
            var Id = $(sender).attr('data-work-specification-id');

            $('#<%=hdnFeedbackPopup.ClientID%>').val(Id);
            $('#<%=btnShowFeedbackPopup.ClientID%>').click();
        }

        function OnApprovalCheckBoxChanged(sender) {
            var intId= $(sender).attr('data-work-specification-id');
            var intParentId= $(sender).attr('data-parent-work-specification-id');
            var blFooter= $(sender).attr('data-footer');
        
            var strSelector = '';
            if(blFooter == 'true') {
                strSelector = 'div[data-id="divPassword' + intParentId + '_Footer"]';
            }
            else {
                strSelector = 'div[data-id="divPassword' + intId + '"]';
            }
        
            if($(sender).prop('checked')) {
                $(strSelector).show();
            }
            else {
                $(strSelector).hide();
            }
        }

        function OnApprovalPasswordChanged(sender) {
    
            ShowAjaxLoader();

            var Id= $(sender).attr('data-work-specification-id');
            var intParentId = $(sender).attr('data-parent-work-specification-id');

            $.ajax
            (
                {
                    url: '../WebServices/JGWebService.asmx/UpdateTaskWorkSpecificationStatusById',
                    contentType: 'application/json; charset=utf-8;',
                    type: 'POST',
                    dataType: 'json',
                    data:  '{ intId:' + Id + ', strPassword:\'' + $(sender).val() + '\'}',
                    asynch: false,
                    success: function (data) {
                        HideAjaxLoader();
                        if(data.d == -2) {
                            alert('Specification cannot be freezed as password is not valid.');
                        }
                        else if(data.d > 0) {
                            // this will update task status from open to specs-in-progress and vice versa based on over all freezing status of work specifications.
                            $('#<%=btnUpdateTaskStatus.ClientID%>').click();
                        GetWorkSpecifications(intParentId, OnWorkSpecificationsResponseReceived);
                        alert('Specification freezed successfully.');
                    }
                    else {
                        alert('Specification cannot be freezed, Please try again later.');
                    }
                },
                error: function (a, b, c) {
                    console.log(a);
                    HideAjaxLoader();
                }
            }
        );

        return false;
    }

    function OnAddSubSectionClick(sender) {
        $sender = $(sender);
        
        var Id = $sender.attr('data-work-specification-id');

        // load sub specifications section.
        GetWorkSpecifications(Id, OnWorkSpecificationsResponseReceived);
        
        // show view sub specifications section button.
        $('a[data-id="btnHideSubSection' + Id + '"]').show();

        $sender.hide();

        SetActiveItemIndex(Id);

        return false;
    }

    function OnViewSubSectionClick(sender) {
        $sender = $(sender);
        
        var Id = $sender.attr('data-work-specification-id');

        // load sub specifications section.
        GetWorkSpecifications(Id, OnWorkSpecificationsResponseReceived);
        
        // show view sub specifications section button.
        $('a[data-id="btnHideSubSection' + Id + '"]').show();

        $sender.hide();

        SetActiveItemIndex(Id);

        return false;
    }

    function OnHideSubSectionClick(sender) {
        $sender = $(sender);

        var Id = $sender.attr('data-work-specification-id');

        // hide / remove sub specifications section.
        $('table[data-parent-work-specification-id="' + Id + '"]').remove();

        // show view sub specifications section button.
        $('a[data-id="btnViewSubSection' + Id + '"]').show();

        $sender.hide();

        return false;
    }

    function ShowAjaxLoader(){
        $('.loading').show();
    }

    function HideAjaxLoader(){
        $('.loading').hide();
    }

</script>

<%--Task Work Specifications Feedback Script--%>
<script type="text/javascript">
    Dropzone.autoDiscover = false;

    $(function () {
        ucTaskWorkSpecifications_Initialize();
    });

    var prmTaskGenerator = Sys.WebForms.PageRequestManager.getInstance();

    prmTaskGenerator.add_endRequest(function () {
        ucTaskWorkSpecifications_Initialize();
    });

    function ucTaskWorkSpecifications_Initialize() {
        ucTaskWorkSpecifications_ApplyDropZone();
    }

    var objTwsNoteDropzone;

    function ucTaskWorkSpecifications_ApplyDropZone() {
        //Apply dropzone for comment section.
        if (objTwsNoteDropzone) {
            objTwsNoteDropzone.destroy();
            objTwsNoteDropzone = null;
        }
        objTwsNoteDropzone = GetWorkFileDropzone("#<%=divTwsDropzone.ClientID%>", '#<%=divTwsDropzonePreview.ClientID%>', '#<%= hdnTwsAttachments.ClientID %>', '#<%=btnSaveTwsAttachment.ClientID%>');
    }

</script>
