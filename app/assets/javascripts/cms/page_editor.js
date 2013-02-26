//= require 'jquery'
//= require 'jquery_ujs'
//= require 'cms/core_library'
//= require 'bootstrap-modal'
//= require 'ckeditor-jquery'

// Since we are within the page editing iframe, add a 'target=_top' to all links so they refresh the entire page.
$(function () {
    $('a').attr('target', '_top');
});

$(function () {
    $.cms_editor = {
        // Returns the widget that a user has currently selected.
        // @return [JQuery.Element]
        selectedElement:function () {
            var editor = CKEDITOR.currentInstance;
            return $(editor.element.$);
        },
        selectedConnector:function () {
            var parents = $.cms_editor.selectedElement().parents();
            return $.cms_editor.selectedElement().parents(".connector");
        },
        // Reload the parent window
        reload:function () {
            window.parent.location.reload();
        },

        // Saves the changes using AJAX for the given editor.
        //
        // @param [CKEditor] editor
        saveChanges:function (currentEditor, afterSave) {
            var block_id = currentEditor.name;
            var block = $("#" + block_id);
            var attribute = block.data('attribute');
            var content_name = block.data('content-name');

            // Ensure the selected content is not gone, or skip updating.
            if (content_name == null) {
                return;
            }
            var content_id = block.data('id');
            var data = currentEditor.getData();
            var message = {
                page_id:block.data('page-id'),
                content:{}
            };
            message["content"][attribute] = data;
            var path = '/cms/inline_content/' + content_name + "/" + content_id;

            $.cms_ajax.put({
                url:path,
                success:function (result) {
                    eval(result);
                    currentEditor.resetDirty();
                    if(afterSave){
                        afterSave.apply();
                    }
                },
                data:message,
                beforeSend:$.cms_ajax.asJS()
            });
        }
    };
});

// On Ready
$(function () {

    // Click the 'Add Content' button (PLUS) when editing content.
    //
    // Rework this function to first update the URLs, then call 'click' on the 'Add content' button
    // Which should be invisible. This should place the backgroup modal toggle in the correct body (i.e. the parent, not the iframe)
    $('.cms-add-content').click(function () {
        var link = $("#insert_existing_content", window.parent.document);
        link.attr('href', $(this).data('insert-existing-content-path'));

        $('#modal-add-content', window.parent.document).modal({
            remote:$(this).data('remote')
        });
    });

    CKEDITOR.disableAutoInline = true;

    // Create editors for each content-block on the page.
    $(".content-block").each(function () {
        var id = $(this).attr('id');
        CKEDITOR.inline(id, {
            customConfig:'/assets/bcms/ckeditor_inline.js',
            toolbar:'inline',
            on:{
                blur:function (event) {
                    $.cms_editor.saveChanges(event.editor);
                }
            }
        });
    });


    /* warn user on leaving if he changed text */
//    var warn_on_leave = false;
//    CKEDITOR.on('currentInstance', function () {
//        try {
//            CKEDITOR.currentInstance.on('key', function () {
//                warn_on_leave = true;
//            });
//        } catch (err) {
//        }
//    });
    // show no popup when user saves changes
//    $(document.activeElement).submit(function () {
//        warn_on_leave = false;
//    });
    // show popup
//    $(window).bind('beforeunload', function () {
//        if (CKEDITOR.currentInstance) { // Ensure there was actually an editor here.
//            if (CKEDITOR.currentInstance.checkDirty()) {
//                return "Unsaved changes."
//            }
//        }
//
//    });

});