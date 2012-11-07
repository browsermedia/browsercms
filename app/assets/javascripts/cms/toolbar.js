//
//  A manifest file for all CMS toolbar related js.
//= require jquery
//= require jquery-ui
//= require jquery.cookie
//= require jquery.selectbox
//= require jquery.taglist
//= require cms/core_library
//= require cms/attachment_manager
//= require bootstrap


// Add an information popup to the Edit Properties button on the Page Toolbar
$(function () {
    $('#edit_properties_button').popover({placement:'bottom'});
});

jQuery(function ($) {

    $.cms_ajax = {

        // Invoke a Rails aware (w/ CSRF token) PUT request.
        put: function (path, success) {
            $.ajaxSetup({
                beforeSend: function (xhr) {
                    xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
                    xhr.setRequestHeader("Accept", "application/json");
                }
            });

            $.ajax({
                type:'POST',
                url:path,
                data:{ _method:'PUT'},
                success: success
            });

        }
    }
});

