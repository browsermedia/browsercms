//= require 'jquery'
//= require 'bootstrap'
//= require 'cms/ajax'

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

// @return [Selector]
Sitemap.prototype.selectedContent= function(){
  return $(this.selectedRow);
};

// Selecting a row in the sitemap
// @param [HtmlElement] row The selected row.
Sitemap.prototype.selectRow = function(row) {
  this.clearSelection();
  this.selectedRow = row;
  if (this.selectedRow.data('type') != 'section') {
    this.selectSection(this.selectedRow.parents('ul:first')[0]);
  } else {
    this.selectSection(this.selectedRow[0]);
  }

  // Highlight the row as selected.
  this.selectedRow.parents('li:first').addClass('active');
  this.enableButtons();
};

Sitemap.prototype.deleteButton = function() {
  return $('#delete_button');
};

Sitemap.prototype._deleteContent = function(event) {
  event.preventDefault();
  if (confirm('Are you sure you want to delete this page?')) {
    $.cms_ajax.delete({
      url: sitemap.deleteButton().attr('href'),
      success: function(result) {
        sitemap.selectedContent().parents('li:first').remove();
      }
    });
  }
};

Sitemap.prototype.enableButtons = function() {
  $('#edit-button').removeClass('disabled').attr('href', $(this.selectedRow).data('edit-path'));
  $('#properties-button').removeClass('disabled').attr('href', $(this.selectedRow).data('configure-path'));
  $('#delete_button')
    .unbind('click')
    .click(this._deleteContent)
    .removeClass('disabled')
    .attr('href', $(this.selectedRow)
    .data('delete-path'));

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