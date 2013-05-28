//= require 'jquery'
//= require 'bootstrap'
//= require 'cms/ajax'

// Code for working with the new sitemap structure.

var GlobalMenu = function() {

};

// Setting the 'New Page' path should update the global menu
GlobalMenu.prototype.addPagePath = function(path){
  $('#new-content-button').attr('href', path);
  $('.add-page-button').attr('href', path);
};

GlobalMenu.prototype.addSectionPath = function(path){
  $('.add-link-button').attr('href', path);
};

GlobalMenu.prototype.addLinkPath = function(path){
  $('.add-section-button').attr('href', path);
};

var globalMenu = new GlobalMenu();

var Sitemap = function() {
};

// @return [Selector] The currently selected section in the sitemap. If a page or other child is selected, this will be
//    that element's parent.
Sitemap.prototype.currentSection = function(){
  return $(this.selectedSection);
};

Sitemap.prototype.selectSection = function(section) {
  this.selectedSection = section;
};

Sitemap.prototype.clearSelection = function() {
  $('.active').removeClass('active');
};

// Different Content types have different behaviors when double clicked.
Sitemap.prototype._doubleClick = function(event){
  var type = $(event.target).data('type');
  switch(type)
  {
  case 'section':
  case 'link':
    $('#properties-button')[0].click();
    break;
  default:
    $('#edit-button')[0].click();
  }
};

// @return [Selector]
Sitemap.prototype.selectedContent = function() {
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
  this.enableMenuButtons();
  this.configureNewButton();
};

// Configure the 'New' button for content that is added directly to sections.
Sitemap.prototype.configureNewButton = function(){
  globalMenu.addPagePath(this.currentSection().data('add-page-path'));
  globalMenu.addLinkPath(this.currentSection().data('add-link-path'));
  globalMenu.addSectionPath(this.currentSection().data('add-section-path'));
};

// @return [Selector]
Sitemap.prototype.deleteButton = function() {
  return $('#delete_button');
};

// @return [String] The name for the type of content which is currently selected.
Sitemap.prototype.typeOfSelectedContent = function() {
  return this.selectedContent().data('type');
};

Sitemap.prototype._deleteContent = function(event) {
  event.preventDefault();
  if (confirm('Are you sure you want to delete this ' + sitemap.typeOfSelectedContent() + '?')) {
    $.cms_ajax.delete({
      url: sitemap.deleteButton().attr('href'),
      success: function(result) {
        sitemap.selectedContent().parents('li:first').remove();
        sitemap.clickWebsite();
      }
    });
  }
};

Sitemap.prototype.clickWebsite = function() {
  $('.nav-stacked a')[0].click();
};


// Enable the button if the current user has edit permission and if the button should be enabled.
//
// @return [Boolean] Whether or not the button was (and should have been) enabled.
//                   Not all functions are available with each button.
Sitemap.prototype.enable = function(button_name, path_name) {
  if ($(this.selectedRow).is('[data-' + path_name + ']') && this.selectedContent().data('editable') != false) {
    $(button_name).removeClass('disabled').attr('href', $(this.selectedRow).data(path_name));
    return true;
  } else {
    $(button_name).addClass('disabled').attr('href', '#');
    return false;
  }
};

Sitemap.prototype.enableMenuButtons = function() {
  this.enable('#edit-button', 'edit-path');
  this.enable('#properties-button', 'configure-path');
  if (this.enable('#delete_button', 'delete-path')) {
    $('#delete_button')
      .unbind('click')
      .click(this._deleteContent);
  }

};
var sitemap = new Sitemap();

$(function() {
  // Enable buttons for Selecting pages
  $('.selectable').click(function() {
    sitemap.selectRow($(this));
  });
  $('.selectable').dblclick(sitemap._doubleClick);
  sitemap.clickWebsite();
});

// Change the folder icon when they are opened/closed.
$(function() {
  $('a[data-toggle="collapse"]').click(function() {
    if ($(this).siblings('ul').hasClass('in') == true) {
      $(this).find('i:first').attr('class', 'icon-folder-close');
    } else {
      $(this).find('i:first').attr('class', 'icon-folder-open');
    }
  });
});

// Make Sitemap filters show specific content types.
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