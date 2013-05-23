//= require 'jquery'
//= require 'bootstrap'

// Code for working with the new sitemap structure.


// Make sections collapsible/expandable
$(function() {
  $('a[data-toggle="collapse"]').click(function() {
    if ($(this).siblings('ul').hasClass('in') == true) {
      $(this).find('i:first').attr('class', 'icon-folder-close');
    } else {
      $(this).find('i:first').attr('class', 'icon-folder-open');
    }
  });
});

// Make Sitemap filters work.
$(function() {
  $('#sitemap li[data-nodetype]').hide();
  $('#filtershow').change(function() {
    $('#sitemap li[data-nodetype]').slideUp();
    var what = $(this).val();
    if (what == "none") {
      $('#sitemap li[data-nodetype]').slideUp();
    } else if (what == "all") {
      $('#sitemap li[data-nodetype]').slideDown();
      $('#sitemap li[data-nodetype]').parents('li').children('a[data-toggle]').click();
    } else {
      $('#sitemap li[data-nodetype="' + what + '"]').slideDown();
      $('#sitemap li[data-nodetype="' + what + '"]').parents('li').children('a[data-toggle]').click();
    }
  });
});