//
//  A manifest file for all CMS toolbar related js.
//= require jquery
//= require jquery.selectbox
//= require cms/application

// Add an information popup to the Edit Properties button on the Page Toolbar
$(function(){
    $('#edit_properties_button').popover({placement: 'bottom'});
});