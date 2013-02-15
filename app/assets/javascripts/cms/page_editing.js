//= require 'jquery'
//= require 'jquery_ujs'
//= require 'cms/core_library'
//= require 'bootstrap-modal'
//= require 'ckeditor-jquery'

// Since we are within the page editing iframe, add a 'target=_top' to all links so they refresh the entire page.
$(function () {
    $('a').attr('target', '_top');
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
                    var block_id = event.editor.name;
                    var block = $("#" + block_id);
                    console.log("Saving " + block_id);
                    console.log("Content Type: " + $("#" + block_id).data('class'));
                    var data = event.editor.getData();
                    console.log("The following content should be saved.\n" + data);
                }
            }
        });
    });
});