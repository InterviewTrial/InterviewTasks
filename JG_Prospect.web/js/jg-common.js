function htmlEncode(value) {
    //create a in-memory div, set it's inner text(which jQuery automatically encodes)
    //then grab the encoded contents back out.  The div never exists on the page.
    return $('<div/>').text(value).html();
}

function htmlDecode(value) {
    return $('<div/>').html(value).text();
}

/********************************************* CK Editor (Html Editor) ******************************************************/
function SetCKEditor(Id) {

    var $target = $('#' + Id);

    // The inline editor should be enabled on an element with "contenteditable" attribute set to "true".
    // Otherwise CKEditor will start in read-only mode.

    $target.attr('contenteditable', true);

    CKEDITOR.inline(Id,
        {
            // Show toolbar on startup (optional).
            startupFocus: true,
            enterMode: CKEDITOR.ENTER_BR
        });

    var editor = CKEDITOR.instances[Id];

    editor.on('fileUploadResponse', function (evt) {
        // Prevent the default response handler.
        evt.stop();

        // Ger XHR and response.
        var data = evt.data,
            xhr = data.fileLoader.xhr,
            response = xhr.responseText.split('|');

        var jsonarray = JSON.parse(response[0]);

        if (jsonarray && jsonarray.uploaded != "1") {
            // Error occurred during upload.                
            evt.cancel();
        } else {
            data.url = jsonarray.url;
        }
    });
}

function SetCKEditorForPageContent(Id, AutosavebuttonId) {

    var $target = $('#' + Id);

    // The inline editor should be enabled on an element with "contenteditable" attribute set to "true".
    // Otherwise CKEditor will start in read-only mode.

    $target.attr('contenteditable', true);

    CKEDITOR.inline(Id,
        {
            // Show toolbar on startup (optional).
            startupFocus: true,
            enterMode: CKEDITOR.ENTER_BR,
            on: {
                blur: function (event) {

                    event.editor.updateElement();
                    // event.editor.destroy();
                    $(AutosavebuttonId).click();
                },
                fileUploadResponse: function (event) {
                    // Prevent the default response handler.
                    event.stop();

                    // Ger XHR and response.
                    var data = event.data,
                        xhr = data.fileLoader.xhr,
                        response = xhr.responseText.split('|');

                    var jsonarray = JSON.parse(response[0]);

                    if (jsonarray && jsonarray.uploaded != "1") {
                        // Error occurred during upload.                
                        event.cancel();
                    } else {
                        data.url = jsonarray.url;
                    }
                }

            }
        });

}

function GetCKEditorContent(Id) {

    var editor = CKEDITOR.instances[Id];

    var encodedHTMLData = editor.getData();

    //editor.updateElement();

    var $target = $('#' + Id);

    $target.html(encodedHTMLData);

    $target.attr('contenteditable', false);

    CKEDITOR.instances[Id].destroy();

    return encodedHTMLData;
}

/********************************************* Dialog (jQuery Ui Popup) ******************************************************/
function ShowPopupWithTitle(varControlID, strTitle) {
    var objDialog = ShowPopup(varControlID);
    // this will update title of current dialog.
    objDialog.parent().find('.ui-dialog-title').html(strTitle);
}

function HidePopup(varControlID) {
    $(varControlID).dialog("close");
}

/********************************************* Dropzone (File upload on drag - drop) ******************************************************/
function GetWorkFileDropzone(strDropzoneSelector, strPreviewSelector, strHiddenFieldIdSelector, strButtonIdSelector) {
    var strAcceptedFiles = '';
    if ($(strDropzoneSelector).attr("data-accepted-files")) {
        strAcceptedFiles = $(strDropzoneSelector).attr("data-accepted-files");
    }

    return new Dropzone(strDropzoneSelector,
        {
            maxFiles: 5,
            url: "taskattachmentupload.aspx",
            thumbnailWidth: 90,
            thumbnailHeight: 90,
            acceptedFiles: strAcceptedFiles,
            previewsContainer: strPreviewSelector,
            init: function () {
                this.on("maxfilesexceeded", function (data) {
                    //var res = eval('(' + data.xhr.responseText + ')');
                    alert('you are reached maximum attachment upload limit.');
                });

                // when file is uploaded successfully store its corresponding server side file name to preview element to remove later from server.
                this.on("success", function (file, response) {
                    var filename = response.split("^");
                    $(file.previewTemplate).append('<span class="server_file">' + filename[0] + '</span>');
                    AddAttachmenttoViewState(filename[0] + '@' + file.name, strHiddenFieldIdSelector);
                    if (typeof (strButtonIdSelector) != 'undefined' && strButtonIdSelector.length > 0) {
                        // saves attachment.
                        $(strButtonIdSelector).click();
                        //this.removeFile(file);
                    }
                });

                //when file is removed from dropzone element, remove its corresponding server side file.
                //this.on("removedfile", function (file) {
                //    var server_file = $(file.previewTemplate).children('.server_file').text();
                //    RemoveTaskAttachmentFromServer(server_file);
                //});

                // When is added to dropzone element, add its remove link.
                //this.on("addedfile", function (file) {

                //    // Create the remove button
                //    var removeButton = Dropzone.createElement("<a><small>Remove file</smalll></a>");

                //    // Capture the Dropzone instance as closure.
                //    var _this = this;

                //    // Listen to the click event
                //    removeButton.addEventListener("click", function (e) {
                //        // Make sure the button click doesn't submit the form:
                //        e.preventDefault();
                //        e.stopPropagation();
                //        // Remove the file preview.
                //        _this.removeFile(file);
                //    });

                //    // Add the button to the file preview element.
                //    file.previewElement.appendChild(removeButton);
                //});
            }

        });
}

function AddAttachmenttoViewState(serverfilename, hdnControlID) {

    var attachments;

    if ($(hdnControlID).val()) {
        attachments = $(hdnControlID).val() + serverfilename + "^";
    }
    else {
        attachments = serverfilename + "^";
    }

    $(hdnControlID).val(attachments);
}

function copyToClipboard(strDataToCopy) {
    window.prompt("Copy to clipboard: Ctrl+C, Enter", strDataToCopy);

    //var $temp = $('<button/>', {
    //    id: 'btnClipBoardContext'
    //});

    //$temp.attr("data-clipboard-text",strDataToCopy);
    //$temp.attr("class", "contextcopy");

    //$("body").append($temp);

    //var clipboard = new Clipboard('.contextcopy');

    //clipboard.on('success', function (e) {       
    //    console.info('Text:', e.text);
    //   e.clearSelection();
    //});

   
   // $temp.remove();

    //clipboard.destroy();
}
//common code check query string parameter, if already exists then replace value else add that parameter. 
function updateQueryStringParameter(uri, key, value) {
    var re = new RegExp("([?&])" + key + "=.*?(&|$)", "i");
    var separator = uri.indexOf('?') !== -1 ? "&" : "?";
    if (uri.match(re)) {
        return uri.replace(re, '$1' + key + "=" + value + '$2');
    }
    else {
        return uri + separator + key + "=" + value;
    }
}


