//This runs when the pages loads and applies various handlers to certain events. Unobtrusive JabbaScript FTW!
document.observe('dom:loaded', function() { 
    
  //First we find all spans
  $$('#sitemap span').each(function(e) {
    
    //Attach the mouseover/mouseout events
    e.observe('mouseover', function(){ $(this).addClassName('hover') });
    e.observe('mouseout', function(){ $(this).removeClassName('hover') });
    
    //Attach the click handler
    e.observe('click', function(event) {
      $$('#sitemap span').each(function(e) { e.removeClassName('selected') })
      event.element().addClassName('selected');
    });
    
  });

  //Now make all the list items draggable
  $$('#sitemap li').each(function(e){
    new Draggable(e, {revert: true });    
  });
  
  //Make all the section links and labels droppable
  $$('#sitemap a.section, #sitemap span.section').each(function(e){
    Droppables.add(e, {
      hoverclass: 'drop-target',
      onDrop: function(e) {
        if(e != this.element.up() && !e.descendantOf(this.element.up())) {
          parent = this.element.up();
          list = parent.down('ul');
          list.show();
          parent.down('img').src = '/images/cms/icons/actions/folder_open.png';
          list.appendChild(e);  
          e.setStyle({'z-index': 0, top: 0, left: 0});          
        }
      }
    });    
  });
  
  //Attach click handlers to the icons
  $$('#sitemap a.section').each(function(e){
    e.observe('click', function(event){ 
      parent = event.element().up().up();
      list = parent.down('ul');
      list.toggle();
      if(list.visible()) {
        parent.down('img').src = '/images/cms/icons/actions/folder_open.png';
      } else {
        parent.down('img').src = '/images/cms/icons/actions/folder.png';
      }
    })
  });
  
});