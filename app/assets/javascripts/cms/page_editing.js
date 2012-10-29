//= require 'jquery'
//= require 'jquery_ujs'
//= require 'cms/core_library'

// Since we are within the page editing iframe, add a 'target=_top' to all links so links refresh the entire page.
$(function () {
   $('a').attr('target', '_top');
});