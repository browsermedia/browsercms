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
    new Draggable(e, {revert: true});    
  });
  
  //Attach click handlers to the icons
  $$('#sitemap a').each(function(e){
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