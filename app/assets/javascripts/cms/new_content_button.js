//= require 'cms/namespace'

Cms.NewContentButton = function() {

};

// Setting the 'New Page' path should update the global menu
Cms.NewContentButton.prototype.addPagePath = function(path) {
  $('#new-content-button').attr('href', path);
  $('.add-page-button').attr('href', path);
};

Cms.NewContentButton.prototype.addSectionPath = function(path) {
  $('.add-link-button').attr('href', path);
};

Cms.NewContentButton.prototype.addLinkPath = function(path) {
  $('.add-section-button').attr('href', path);
};

Cms.NewContentButton.prototype.updateButtons = function(selectedElement) {
  this.addPagePath(selectedElement.data('add-page-path'));
  this.addLinkPath(selectedElement.data('add-link-path'));
  this.addSectionPath(selectedElement.data('add-section-path'));
};

var newContentButton = new Cms.NewContentButton();