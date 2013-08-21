//= require 'cms/core_library'

// CMS library for invoking ajax functions.
// A layer on top of jQuery .ajax that adds some Rails and CMS logic
jQuery(function ($) {
    $.cms_ajax = {

        // Sets the message Accepts to javascript.
        // Pass to beforeSend: when calling AJAX.
        asJS:function () {
            return function (xhr) {
                xhr.setRequestHeader('X-CSRF-Token', $.cms.csrfToken());
                xhr.setRequestHeader("Accept", "text/javascript, */*, q=0.1");
            }
        },
        asJSON:function () {
            return function (xhr) {
                xhr.setRequestHeader('X-CSRF-Token', $.cms.csrfToken());
                xhr.setRequestHeader("Accept", "application/json, */*, q=0.1");
            }
        },
        // Invoke a Rails aware (w/ CSRF token) PUT request.
        // @param [Hash] message A json message without the type.
        // See http://api.jquery.com/jQuery.ajax/ for acceptable format.
        put:function (message) {
            message['type'] = 'POST';
            message['data'] = message['data'] || {}
            message['data']['_method'] = 'PUT';

            $.ajax(message);

        },
        // Invoke a Rails aware (w/ CSRF token) DELETE request.
        // @param [Hash] message A json message without the type.
        // See http://api.jquery.com/jQuery.ajax/ for acceptable format.
        //      ex.
        //      $.cms_ajax.delete({
        //          url:'/event/1',
        //          success:function (result) {
        //             console.log("Got back " + result);
        //          }
        //      });
        //
        delete:function (message) {
            message['type'] = 'POST';
            message['data'] = message['data'] || {}
            message['data']['_method'] = 'DELETE';
            $.ajax(message);

        }
    };

    // Defaults for AJAX requests
    $.ajaxSetup({
        error:function (x, status, error) {
            alert("A " + x.status + " error occurred: " + error);
        },
        beforeSend: $.cms_ajax.asJSON()
    });
});
