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
    $.ajaxSetup({
        beforeSend:function (xhr) {
            xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
            xhr.setRequestHeader("Accept", "application/json");
        },
        error:function (x, status, error) {
            alert("A " + x.status + " error occurred: " + error);
        }
    });
    $.cms_ajax = {
        // Invoke a Rails aware (w/ CSRF token) PUT request.
        put:function (path, success) {
//            $.cms_ajax.setup();
            $.ajax({
                type:'POST',
                url:path,
                data:{ _method:'PUT'},
                success:success
            });

        },
        // Invoke a Rails aware (w/ CSRF token) DELETE request.
        delete:function (path, success) {
            $.ajax({
                type:'POST',
                url:path,
                data:{ _method:'DELETE'},
                success:success
            });

        }
    };

    $.cms_editor = {


        // Returns the widget that a user has currently selected.
        // @return [JQuery.Element]
        selectedElement:function () {
            return $($('#mercury_iframe').contents()[0].activeElement);
        },
        selectedConnector:function () {
            var parents = $.cms_editor.selectedElement().parents();
            return $.cms_editor.selectedElement().parents(".connector");
        },

        // Triggers a save, which should also reload the page.
        save:function () {
            Mercury.trigger('action', {action:'save'});
        }
    };
});

