//= require 'jquery'
//= require 'bootstrap'

// Code for working with the new sitemap structure.

var Sitemap = function() {
};
Sitemap.prototype.selectSection = function(section) {
  this.selectedSection = section;
};

Sitemap.prototype.clearSelection = function() {
  $('.active').removeClass('active');
  disableButtons();
};

// Selecting a row in the sitemap
// @param [HtmlElement] row The selected row.
Sitemap.prototype.selectRow = function(row) {
  this.clearSelection();
  this.selectedRow = row;
  if (this.selectedRow.data('type') != 'section') {
    this.selectSection(this.selectedRow.parents('ul:first')[0]);
  }else {
    this.selectSection(this.selectedRow[0]);
  }

  // Highlight the row as selected.
  this.selectedRow.parents('li:first').addClass('active');
};
var sitemap = new Sitemap();

var disableButtons = function() {
  $('a.button').addClass('disabled').click(function() {
    return false;
  });
};

// Enable buttons for Selecting pages
$(function() {
  $('.selectable').click(function() {
    sitemap.selectRow($(this));
  });
});

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