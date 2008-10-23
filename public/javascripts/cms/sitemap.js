jQuery(function($){
  
  //Disable all "buttons"
  $('#buttons a.disabled').click(function(){ return false })

  var dragNode = false;
  var origNode = false;
  
  //drag/drop functionality
  $('#sitemap tbody div').draggable({
    revert: true,
    revertDuration: 200,
    refreshPositions: true,
    delay: 200
  }).droppable({
    accept: 'div',
    over: function(e, ui) {
      $(this).css('border-bottom','1px dotted #999')
    },
    out: function(e, ui) {
      $(this).css('border', 'none')
    },
    drop: function(e, ui) {
      $.log(ui.element[0])
      $.log('landed on')
      $.log(this)
      return false;
    }
  });
  // $('#sitemap tbody td').mousedown(function(e){
  //   origNode = $(this);
  //   var div = $('>div', origNode);
  //   var offset = div.offset();
  //   var clone = div.clone();
  //   origNode.hide();
  //   dragNode = clone.css({display: "block", position: "absolute", left: offset.left+"px", top: offset.top+"px", opacity: 0.6, border:'none'}).appendTo('body');   
  // }).mousemove(function(e){
  //   if(dragNode) {
  //     var offset = $(this).offset();
  //     var x = e.pageX - offset.left;
  //     var y = e.pageY - offset.top;
  //     if(y > $(this).height()/2) {
  //       $('div', this).css('border','none').css('border-bottom','1px dotted #999')
  //     } else {
  //       $('div', this).css('border','none').css('border-top','1px dotted #999')
  //     }      
  //   }
  // }).mouseout(function(e){
  //   $('div', this).css('border','none')
  // }).mouseup(function(e){
  //   $.log('td up')
  // })
  // 
  // $('body').mousemove(function(e){
  //   if(dragNode) {
  //     dragNode.css({left: e.pageX, top: e.pageY})
  //   }
  // }).mouseup(function(e){
  //   if(dragNode && origNode) {
  //     dragNode.remove()
  //     dragNode = false;
  //     origNode.show();
  //     origNode = false;
  //     $.log('body up')
  //   }
  // })
  
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
