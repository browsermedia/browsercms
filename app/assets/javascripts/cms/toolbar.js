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
//= require cms/ajax


// Add an information popup to the Edit Properties button on the Page Toolbar
$(function () {
    $('#edit_properties_button').popover({placement:'bottom'});
});



