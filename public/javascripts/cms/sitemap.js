jQuery(function($){
  
  //Disable all "buttons"
  $('#buttons a.disabled').click(function(){ return false })

  var dragNode = false;
  var origNode = false;
  
  //drag/drop functionality
  $('#sitemap .icon_node div').draggable({
    revert: true,
    revertDuration: 200,
    helper: 'clone',
    delay: 200
  })
  $('#sitemap .node .drop_before, #sitemap .node .drop_after').droppable({
    accept: 'div',
    tolerance: 'pointer',
    over: function(e, ui) {
      $(this).css('background-color','#00c')
    },
    out: function(e, ui) {
      $(this).css('background-color', '#fff')
    },
    drop: function(e, ui) {
      $.log(ui.element[0])
      $.log('landed on')
      $.log(this)
      return false;
    }
  });

  //onClick for the folder icon for each section, show/hide section
  $('#sitemap a.folder').click(function(){ 
    var id = this.id.replace(/folder_/,'')
    
    if($(this).hasClass("folder-open")) {
      $('.p'+id+', .a'+id).hide()
      $(this).find('img').attr('src','/images/cms/icons/actions/folder.png')
      $(this).removeClass("folder-open")
    } else {
      $('.p'+id).show()
      $(this).find('img').attr('src','/images/cms/icons/actions/folder_open.png')
      $(this).addClass("folder-open")
    }
    return false 
  })
  
  //onClick for the name of a section/page
  $('#sitemap span.node').click(function(){
    $('#buttons a').addClass('disabled').click(function(){return false})
    $('#sitemap span.node').removeClass('selected')
    $(this).addClass('selected')
        
    var id = this.id.replace(/(section|page)_/,'');
    
    if($(this).hasClass('root') || $(this).hasClass('section')) {
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
        
    } else if($(this).hasClass('page')) {
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
      
    }
  })
})
