jQuery(function($) {

    //----- Helper Functions -----------------------------------------------------
    //In all of this code, we are defining functions that we use later
    //None of this actually manipulates the DOM in any way

    //This is used to get the id part of an elementId
    //For example, if you have section_node_5, 
    //you pass this 'section_node_5', 'section_node' 
    //and this returns 5
    var getId = function(elementId, s) {
        return elementId.replace(s, '')
    }


    var nodeOnDoubleClick = function() {
        if ($('#edit_button').hasClass('disabled')) {
            //$('#view_button').click()
            location.href = $('#view_button')[0].href
        } else {
            //$('#edit_button').click()
            location.href = $('#edit_button')[0].href
        }
    }

    var addNodeOnDoubleClick = function() {
        $('#blocks tr').dblclick(nodeOnDoubleClick)
    }

    //----- Init -----------------------------------------------------------------
    //In other words, stuff that happens when the page loads
    //This is where we actually manipulate the DOM, fire events, etc.

    addNodeOnDoubleClick()

});

// Makes the toolbar for the Content table correctly work based on the selected row.
//  I.e. Select a row, the 'View' button becomes active and the URL goes to the right path.
//
//  Any element with class='cms-content-table' will have this applied to it.
(function($) {
    $.fn.cmsContentToolbar = function() {

        var content_type = this.data('content_type')
        var is_versioned = this.data('versioned')
        var can_publish = this.data('can_publish')
        var plural_title = this.data('plural_title')

        $('table.data tbody tr').hover(
            function() {
                $(this).addClass('hover')
            },
            function() {
                $(this).removeClass('hover')
            }).click(function() {
                var view_path = $(this).data('view_path');
                var edit_path = $(this).data('edit_path');
                var delete_path = $(this).data('delete_path');
                var new_path = $(this).data('new_path');
                var versions_path = $(this).data('versions_path');
                var publish_path = $(this).data('publish_path') + '?_redirect_to=' + location.href;
                var status = $(this).data('status');

                var editable = !$(this).hasClass("non-editable");
                var publishable = !$(this).hasClass("non-publishable");
                $('table.data tbody tr').removeClass('selected');
                $(this).addClass('selected');
                $('#functions .button').addClass('disabled').attr('href', '#');
                $('#add_button').removeClass('disabled').attr('href', new_path);
                $('#view_button').removeClass('disabled').attr('href', view_path);
                if (editable) $('#edit_button').removeClass('disabled').attr('href', edit_path);
                if (is_versioned) {
                    $('#revisions_button').removeClass('disabled').attr('href', versions_path);
                } else {
                    $('#revisions_button').addClass('disabled')
                        .attr('title', plural_title + ' are not versioned');
                }
                var cannot_be_deleted_message = $(this).find('.cannot_be_deleted_message');
                if (cannot_be_deleted_message.length > 0) {
                    $('#delete_button').addClass('disabled')
                        .attr('title', $.trim(cannot_be_deleted_message.text()));
                } else {
                    if (publishable) {
                        $('#delete_button').removeClass('disabled')
                            .attr('href', delete_path)
                            .attr('title', 'Are You Sure You Want To Delete This Record?');
                    }
                }
                if (can_publish) {
                    if (status == 'draft' && publishable) {
                        $('#publish_button').removeClass('disabled').attr('href', publish_path);
                    }
                }
            })
    };
})(jQuery);

$(function() {
    $('.cms-content-table').cmsContentToolbar();
});

