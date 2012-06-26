//= require 'jquery'

// Since we are within the page editting iframe, add a 'target=_top' to all links so links refresh the entire page.
$(function () {
   $('a').attr('target', '_top');
});