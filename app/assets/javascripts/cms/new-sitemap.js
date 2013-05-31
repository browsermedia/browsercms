//= require 'jquery'
//= require 'jquery-ui'
//= require 'jquery.cookie'
//= require 'bootstrap'
//= require 'cms/ajax'
//= require 'underscore'

// Code for working with the new sitemap structure.

var GlobalMenu = function() {

};

// Setting the 'New Page' path should update the global menu
GlobalMenu.prototype.addPagePath = function(path) {
  $('#new-content-button').attr('href', path);
  $('.add-page-button').attr('href', path);
};

GlobalMenu.prototype.addSectionPath = function(path) {
  $('.add-link-button').attr('href', path);
};

GlobalMenu.prototype.addLinkPath = function(path) {
  $('.add-section-button').attr('href', path);
};

var globalMenu = new GlobalMenu();

var Sitemap = function() {
};

Sitemap.STATE = 'cms.sitemap.opened';

// @return [Selector] The currently selected section in the sitemap. If a page or other child is selected, this will be
//    that element's parent.
Sitemap.prototype.currentSection = function() {
  return $(this.selectedSection);
};

Sitemap.prototype.selectSection = function(section) {
  this.selectedSection = section;
};

Sitemap.prototype.clearSelection = function() {
  $('.active').removeClass('active');
};

// Different Content types have different behaviors when double clicked.
Sitemap.prototype._doubleClick = function(event) {
  var type = $(event.target).data('type');
  switch(type) {
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
Sitemap.prototype.configureNewButton = function() {
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

// @param [Number] node_id
// @param [Number] target_node_id
// @param [Number] position A 1 based position for order
Sitemap.prototype.move_to = function(node_id, target_node_id, position) {
  var path = "/cms/section_nodes/" + node_id + '/move_to_position'
  $.cms_ajax.put({
    url: path,
    data: {
      target_node_id: target_node_id,
      position: position
    },
    success: function(result) {
      sitemap.clickWebsite();
    }
  });
  console.log("Dropping node", node_id, "into", target_node_id, "at position", position);

};

// @param [Selector] A selected link (<a>)
Sitemap.prototype.isOpen = function(link){
  return link.siblings('ul').hasClass('in') == true
};

// @param [Selector] link A selected link (<a>)
// @param [String] icon The full name of the icon (icon-folder-open)
Sitemap.prototype.changeIcon = function(link, icon){
  link.find('i:first').attr('class', icon);
};

// @param [Number] id
Sitemap.prototype.openedSection = function(id){
  $.cookieSet.add(Sitemap.STATE, id);
};
Sitemap.prototype.closedSection = function(id){
  $.cookieSet.remove(Sitemap.STATE, id);
};

// Reopen all sections that the user was last working with.
Sitemap.prototype.restoreOpenState = function(){
  var section_ids = $.cookieSet.get(Sitemap.STATE);
  _.each(section_ids, function(id){
    var link = $('.selectable[data-type="section"][data-id=' + id + ']');
    sitemap.changeIcon(link, 'icon-folder-open');
    $(link.data('target')).addClass('in');
  });
};

var sitemap = new Sitemap();

$(function() {
  // Enable buttons for Selecting pages
  $('.selectable').on('click', function() {
    sitemap.selectRow($(this));
  });
  $('.selectable').on('dblclick', sitemap._doubleClick);
  sitemap.clickWebsite();
  $('#sitemap ul ul').sortable({
    connectWith: '#sitemap ul ul',
    placeholder: 'ui-placeholder',
    delay: 250,
    start: function(event, ui) {
      sitemap.clearSelection();
    },
    stop: function(event, ui) {
      var parent_section = ui.item.parents('ul:first');
      var moving_node_id = ui.item.children('a:first').data('node-id');
      sitemap.move_to(moving_node_id, parent_section.data('node-id'), ui.item.index() + 1);
    }
  });

});

// Change the folder icon when they are opened/closed.
$(function() {
  sitemap.restoreOpenState();
  console.log("On page load, these sections should be open", $.cookie('sitemap.opened'));
  $('a[data-toggle="collapse"]').click(function() {
    if (sitemap.isOpen($(this))) {
//      console.log("Section", $(this).data('id'), "was closed.");
      sitemap.closedSection($(this).data('id'));
      sitemap.changeIcon($(this), 'icon-folder-close');
    } else {
//      console.log("Section", $(this).data('id'), "was opened.");
      sitemap.openedSection($(this).data('id'));
      sitemap.changeIcon($(this), 'icon-folder-open');
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