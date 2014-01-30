//= require 'jquery'
//= require 'jquery.ui.all'
//= require 'jquery.cookie'
//= require 'bootstrap'
//= require 'cms/ajax'
//= require 'underscore'
//= require 'cms/new_content_button'

// Sitemap uses JQuery.Draggable/Droppable to handling moving elements, with custom code below.
// Open/Close are handled as code below.
var Sitemap = function() {
};

// Name of cookie that stores SectionNode ids that should be opened.
Sitemap.STATE = 'cms.sitemap.open_folders';

Sitemap.prototype.select = function(selectedRow) {
  $('.nav-list-span').removeClass('active');
  selectedRow.addClass('active');
  newContentButton.updateButtons(selectedRow);
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

// @param [Number] node_id
// @param [Number] target_node_id
// @param [Number] position A 1 based position for order
Sitemap.prototype.moveTo = function(node_id, target_node_id, position) {
  var path = "/cms/section_nodes/" + node_id + '/move_to_position'
  $.cms_ajax.put({
    url: path,
    data: {
      target_node_id: target_node_id,
      position: position
    },
    success: function(result) {
      //console.log(result);
    }
  });
};

// @param [Selector] Determines if a section is open.
Sitemap.prototype.isOpen = function(row) {
  return row.find('.type-icon').hasClass('icon-folder-open');
};

// @param [Selector] link A selected link (<a>)
// @param [String] icon The full name of the icon (icon-folder-open)
Sitemap.prototype.changeIcon = function(row, icon) {
  row.find('.type-icon').attr('class', 'type-icon').addClass(icon);
};

// @param [Number] id
Sitemap.prototype.saveAsOpened = function(id) {
  $.cookieSet.add(Sitemap.STATE, id);
};

// @param [Number] id
Sitemap.prototype.saveAsClosed = function(id) {
  $.cookieSet.remove(Sitemap.STATE, id);
};

// Reopen all sections that the user was last working with.
Sitemap.prototype.restoreOpenState = function() {
  var section_node_ids = $.cookieSet.get(Sitemap.STATE);
  _.each(section_node_ids, function(id) {
    var row = $('.nav-list-span[data-id=' + id + ']');
    sitemap.open(row, {animate: false});
  });
};

// Determines if the selected row is a Folder or not.
Sitemap.prototype.isFolder = function(row) {
  return row.data('type') == 'folder';
};

Sitemap.prototype.isClosable = function(row) {
  return row.data('closable') == true;
};

// @param [Selector] link
// @param [Object] options
Sitemap.prototype.open = function(row, options) {
  options = options || {}
  _.defaults(options, {animate: true});
  this.changeIcon(row, 'icon-folder-open');
  var siblings = row.siblings('.children');
  if (options.animate) {
    siblings.slideToggle();
  }
  else {
    siblings.show();
  }
  this.saveAsOpened(row.data('id'));
};

// Attempts to open the given row. Will skip if the item cannot or is already open.
Sitemap.prototype.attemptOpen = function(row, options) {
  if (this.isClosable(row) && !this.isOpen(row)) {
    this.open(row, options);
  }
};

Sitemap.prototype.close = function(row) {
  this.changeIcon(row, 'icon-folder');
  row.siblings('.children').slideToggle();
  this.saveAsClosed(row.data('id'));
};

Sitemap.prototype.toggleOpen = function(row) {
  if (!this.isClosable(row)) {
    return;
  }
  if (this.isOpen(row)) {
    this.close(row);
  } else {
    this.open(row);
  }
};

Sitemap.prototype.updateDepth = function(element, newDepth) {
  var depthClass = "level-" + newDepth;
  element.attr('class', 'ui-draggable ui-droppable nav-list-span').addClass(depthClass);
  element.attr('data-depth', newDepth);
};

var sitemap = new Sitemap();

// Enable dragging of items around the sitemap.
jQuery(function($){
  if ($('#sitemap').exists()) {

    $('#sitemap .draggable').draggable({
      containment: '#sitemap',
      revert: true,
      revertDuration: 0,
      axis: 'y',
      delay: 250,
      cursor: 'move',
      stack: '.nav-list-span'
    });

    $('#sitemap .nav-list-span').droppable({
      hoverClass: "droppable",
      drop: function(event, ui) {
        var elementToMove = ui.draggable.parents('.nav-list').first();
        var elementDroppedOn = $(this).parents('.nav-list').first();
        var targetDepth = $(this).data('depth');


        if (sitemap.isFolder($(this))) {
          // Drop INTO sections
          sitemap.attemptOpen($(this));
          sitemap.updateDepth(ui.draggable, targetDepth + 1);
          elementDroppedOn.find('li').first().append(elementToMove);
          var newParentId = $(this).data('id');
        } else {
          sitemap.updateDepth(ui.draggable, targetDepth);
          // Drop AFTER pages
          var newParentId = elementDroppedOn.parents('.nav-list:first').find('.nav-list-span:first').data('id');
          elementToMove.insertAfter(elementDroppedOn);
        }

        // Move item on server
        var nodeIdToMove = ui.draggable.data('id');
        var newPosition = elementToMove.index();
        console.log("Move section_node", nodeIdToMove, " to parent:", newParentId, 'at position', newPosition);
        sitemap.moveTo(nodeIdToMove, newParentId, newPosition);

        // Need a manual delay otherwise the animation happens before the insert.
        window.setTimeout(function() {
          ui.draggable.effect({effect: 'highlight', duration: 500, color: '#0079c1'});
        }, 250);
      }
    });
  }
});

// Open/close folders when rows are clicked.
jQuery(function($){
  // Ensure this only loads on sitemap page.
  if ($('#sitemap').exists()) {
    sitemap.restoreOpenState();
    $('.nav-list-span').on('click', function(event) {
      sitemap.toggleOpen($(this));
      sitemap.select($(this));
    });
  }

});

// Make Sitemap filters show specific content types.
jQuery(function($){
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