jQuery(function($){
  
  //----- Helper Functions -----------------------------------------------------
  //In all of this code, we are defining functions that we use later
  //None of this actually manipulates the DOM in any way
  
  //This is used to get the id part of an elementId
  //For example, if you have section_node_5, 
  //you pass this 'section_node_5', 'section_node' 
  //and this returns 5
  var getId = function(elementId, s) {
    return elementId.replace(s,'')
  }
  
  var addHoverToSectionNodes = function() {
    $('#sitemap tr.section_node').hover(
      function() { $(this).addClass('hover')},
      function() { $(this).removeClass('hover')}
    )    
  }
  
  var disableButtons = function() {
    $('a.button').addClass('disabled').click(function(){return false})
  }
  
  var makeMovableRowsDraggable = function() {
    $('#sitemap tr.movable').draggable({
      revert: 'invalid',
      revertDuration: 200,
      helper: 'clone',
      delay: 200,
      start: function(event, ui) {
        ui.helper.removeClass('hover').removeClass('selected')
      }
    })    
  }
  
  var moveSectionNode = function(sectionNodeId, beforeOrAfter, otherSectionNodeId) {
    var url = '/cms/section_nodes/move_'+beforeOrAfter+'/'+sectionNodeId
    $.post(url, { _method: "PUT", section_node_id: otherSectionNodeId },
      function(data){
        if(data.success) {
          $.cms.showNotice(data.message)
        } else {
          $.cms.showError(data.message)
        }
      }, "json"
    );
  }
  
  var nodeOnDrop = function(e, ui) {
    //Remove any drop zone highlights still hanging out
    $('#sitemap td.drop-before, #sitemap td.drop-after').removeClass('drop-over')

    //Get the object and the id for the src (what we are droping) 
    //and the dest (where we are dropping)
    var src = ui.draggable
    var sid = getId(src[0].id, 'section_node_')
    var dest = $(this).parents('tr.section_node')
    var did = getId(dest[0].id, 'section_node_')

    //insert before or after, based on the class of the drop zone
    if($(this).hasClass('drop-before') || $(this).hasClass('drop-after')) {
      if($(this).hasClass('drop-before')) {
        var move = 'before'
        src.insertBefore(dest)
      } else {
        var move = 'after'          
        src.insertAfter(dest)
      }

      //Update the parent/ancestors as well as the depth
      var old_class = src.attr('class')
      var old_depth = parseInt($('td.node img', src).css('padding-left').replace('px','')) || 0
      var new_class = dest.attr('class')
      var new_depth = parseInt($('td.node img', dest).css('padding-left').replace('px','')) || 0

      src.attr('class', new_class).addClass('section_node')
      $('td.node img', src).css('padding-left', new_depth+'px')

      //Modify the depth of all children
      $('.p'+sid+' td.node img, .a'+sid+' td.node img').each(function(){
        var cur_depth = parseInt(($(this).css('padding-left').replace('px','')) || 0);
        $(this).css('padding-left', (new_depth - old_depth + cur_depth)+'px')
      })

      //Now remove all the old ancestors and add back the new ones on the children
      $(old_class.replace('p','a').split(' ')).each(function(){ 
        $('.p'+sid+', .a'+sid).removeClass(this) 
      })
      $(new_class.replace('p','a').split(' ')).each(function(){ 
        $('.p'+sid+', .a'+sid).addClass(this) 
      })

      //Now we move over all the decendents of the src
      var prev_node = src;
      $('#sitemap tr.section_node').each(function(){
        if($(this).hasClass('p'+sid) || $(this).hasClass('a'+sid)) {
          $(this).insertAfter(prev_node)
          prev_node = $(this)
        }
      })

      //Now we move over all the decendents of the dest
      prev_node = dest;
      $('#sitemap tr.section_node').each(function(){
        if($(this).hasClass('p'+did) || $(this).hasClass('a'+did)) {
          $(this).insertAfter(prev_node)
          prev_node = $(this)
        }
      })

      //Make the thing we are dropping be selected
      selectSectionNode(ui.draggable)

      //Finally do the ajax request
      moveSectionNode(sid, move, did)
    }    
  }
  
  var enableDropZones = function() {
    $('#sitemap td.drop-before, #sitemap td.drop-after').droppable({
      accept: 'tr',
      tolerance: 'pointer',
      over: function(e, ui) {
        $(this).addClass('drop-over')
      },
      out: function(e, ui) {
        $(this).removeClass('drop-over')
      },
      drop: nodeOnDrop
    });    
  }  
    
  var clearSelectedSectionNode = function() {
    disableButtons()
    $('#sitemap tr.section_node').removeClass('selected')    
  }
  
  var selectSectionNode = function(sectionNode) {
    clearSelectedSectionNode(sectionNode)
    enableButtonsForSectionNode(sectionNode)
    $(sectionNode).addClass('selected')    
  }
  
  var enableButtonsForSectionNode = function(sectionNode) {
    enableButtonsForNode($(sectionNode).find('td.node')[0])
  }
  
  var enableButtonsForNode = function(node) {
    var id = getId(node.id, /(section|page|link)_/)
    if($(node).hasClass('section')) {
      enableButtonsForSection(id)
    } else if($(node).hasClass('page')) {
      enableButtonsForPage(id)
    } else if($(node).hasClass('link')) {
      enableButtonsForLink(id)
    }  
  }
  
  var enableButtonsForSection = function(id) {
    $('#properties-button')
      .removeClass('disabled')
      .attr('href','/cms/sections/edit/'+id)
      .unbind('click')
      .click(function(){return true})
    
    $('#add-page-button')
      .removeClass('disabled')
      .attr('href','/cms/pages/new?section_id='+id)
      .unbind('click')
      .click(function(){return true})

    $('#add-section-button')
      .removeClass('disabled')
      .attr('href','/cms/sections/new?section_id='+id)
      .unbind('click')
      .click(function(){return true})
      
    $('#add-link-button')
      .removeClass('disabled')
      .attr('href','/cms/links/new?section_id='+id)
      .unbind('click')
      .click(function(){return true})    
  }
  
  var enableButtonsForPage = function(id) {
    $('#edit-button')
      .removeClass('disabled')
      .attr('href','/cms/pages/show/'+id)
      .unbind('click')
      .click(function(){return true})

    $('#properties-button')
      .removeClass('disabled')
      .attr('href','/cms/pages/edit/'+id)
      .unbind('click')
      .click(function(){return true})

    $('#delete-button')
      .removeClass('disabled')
      .attr('href','/cms/pages/destroy/'+id+'.json')
      .unbind('click')
      .click(function(){
        if(confirm('Are you sure you want to delete this page?')) {
          $.post($(this).attr('href'), { _method: "DELETE" },
            function(data){
              if(data.success) {
                $.cms.showNotice(data.message)
              } else {
                $.cms.showError(data.message)
              }
            }, "json");
          $('#page_'+id).parents('.section_node').remove()            
        }
        return false;
      })    
  }
  
  var enableButtonsForLink = function(id) {
    $('#properties-button')
      .removeClass('disabled')
      .attr('href','/cms/links/edit/'+id)
      .unbind('click')
      .click(function(){return true})    
  }
  
  var toggleSection = function(sectionNode) {
    if($(sectionNode).find('img.folder-open').length) {
      closeSection(sectionNode)
    } else if($(sectionNode).find('img.folder').length) {
      openSection(sectionNode)
    } else {
      //WTF?
    }    
  }

  var openSection = function(sectionNode) {
    var id = getId(sectionNode.id, 'section_node_')
    
    //Remember to re-open this section
    $.cookieSet.add('openSectionNodes', id, {path: '/', expires: 90})
    
    $('.p'+id).show()
    $(sectionNode).find('img.folder').attr('src','/images/cms/icons/actions/folder_open.png').addClass("folder-open")    
  }
  
  var closeSection = function(sectionNode) {
    var id = getId(sectionNode.id, 'section_node_')
    
    //Remove this section from the set of open nodes
    $.cookieSet.remove('openSectionNodes', id, {path: '/', expires: 90})

    //close children
    $('.p'+id+', .a'+id).hide().find('img.folder').attr('src','/images/cms/icons/actions/folder.png').removeClass("folder-open")

    //close this
    $(sectionNode).find('img.folder').attr('src','/images/cms/icons/actions/folder.png').removeClass("folder-open")    
  }
  
  var sectionNodeIsOpen = function(sectionNode) {
    return $(sectionNode).find('img.folder-open').length
  }
  
  var nodeOnClick = function() {
    var selected = $(this).hasClass('selected')
    clearSelectedSectionNode()
    $(this).addClass('selected')
    
    var node = $(this).find('td.node')[0]
    var id = getId(node.id, /(section|page|link)_/)
    
    selectSectionNode(this)
    if(!$(node).hasClass('root') && $(node).hasClass('section')) {
      if(sectionNodeIsOpen(this) && selected) {
        closeSection(this)  
      } else {
        openSection(this)
      }
    }
  }  
  
  var addNodeOnClick = function() {
    $('#sitemap tr.section_node').click(nodeOnClick)    
  }
  
  //Whenever you open a section, a cookie is updated so that next time you view the sitemap
  //that section will start in open state
  var fireOnClickForOpenSectionNodes = function() {
    var openSectionNodeIds = $.cookieSet.get('openSectionNodes')
    $('#sitemap tr.section_node:first').click()
    if(openSectionNodeIds) {
      var openSectionNodeSelector = $.map(openSectionNodeIds, function(e,i){ return "#section_node_"+e }).join(', ')
      $(openSectionNodeSelector).click()
    }    
  }  
  
  //----- Init -----------------------------------------------------------------
  //In other words, stuff that happens when the page loads
  //This is where we actually manipulate the DOM, fire events, etc.
  
  addHoverToSectionNodes()  
  disableButtons()
  makeMovableRowsDraggable()
  enableDropZones()  
  addNodeOnClick()
  fireOnClickForOpenSectionNodes()

})
