//= require 'jquery'
//= require 'jquery_ujs'
//= require 'cms/core_library'
//= require 'bootstrap-modal'

// Since we are within the page editing iframe, add a 'target=_top' to all links so they refresh the entire page.
$(function () {
    $('a').attr('target', '_top');
});

$(function () {

    // Click the 'Add Content' button (PLUS) when editing content.
    //

    // Rework this function to first update the URLs, then call 'click' on the 'Add content' button
    // Which should be invisible. This should place the backgroup modal toggle in the correct body (i.e. the parent, not the iframe)
    $('.cms-add-content').click(function () {
        var link = $("#insert_existing_content", window.parent.document);
        link.attr('href', $(this).data('insert-existing-content-path'));

        $('#modal-add-content', window.parent.document).modal({
            remote:  $(this).data('remote')
        });
    });
});