//This runs when the pages loads and applies various handlers to certain events. Unobtrusive JabbaScript FTW!
document.observe('dom:loaded', function() { 
    
  //Function used to handle a click on a page/section
  //It is defined as a variable here local to this function
  //So we can attach it as a click handler and call it
  //elsewhere in this function, but it will not be directly
  //visable outside of the scope of this function
  var clickHandler = function(element) {

    var doubleClick = element.hasClassName('selected');
    
    //Unselect all other pages/sections
    $$('#sitemap span').each(function(e) { e.removeClassName('selected') })
    
    //Disable All Buttons
    $$('.button-to input[type=submit]').each(function(e){ e.disabled = true })
    
    //Set actions and enable buttons where appropriate
    if(element.hasClassName('page')) {
      var page_id = element.up('li').id.sub('page_','');
      var url = '/cms/pages/'+page_id;
      
      //WARING: Questionable usability decision
      //If the page is already selected, 
      //then clicking it again will result in going to that page
      if(doubleClick) {
        window.location = url;
        return false;
      }
      
      $('edit-button').form.action = url;
      $('edit-button').disabled = false;

      $('properties-button').form.action = url+'/edit';
      $('properties-button').disabled = false;
      
    } else if(element.hasClassName('section')) {
      var section_id = element.up('li').id.sub('section_','');
      var url = '/cms/sections/'+section_id;
      
      $('properties-button').form.action = url+'/edit';
      $('properties-button').disabled = false;        

      $('add-page-button').form.action = url+'/pages/new';
      $('add-page-button').disabled = false;        

      $('add-section-button').form.action = url+'/sections/new';
      $('add-section-button').disabled = false;        
      
    }
    
    //Show this page as selected
    element.addClassName('selected');
    
  }
  
  //Iterate through all spans, which contain the page/section name
  $$('#sitemap span').each(function(e) {
    
    //Attach the mouseover/mouseout events
    e.observe('mouseover', function(){ $(this).addClassName('hover') });
    e.observe('mouseout', function(){ $(this).removeClassName('hover') });
    
    //Attach the click handler
    e.observe('click', function(event){ 
      clickHandler(event.element()) 
    });
    
  }); //End find all spans

  //Make all the list items draggable
  $$('#sitemap li').each(function(e){
    new Draggable(e, {revert: true });    
  });
  
  //Make all the section links and labels droppable
  $$('#sitemap span.section').each(function(e){
    Droppables.add(e, {
      hoverclass: 'drop-target',
      onDrop: function(e) {
        if(e != this.element.up()) {
          
          //Figure out the id of the page/section
          if(e.hasClassName('page')) {
            var url = '/cms/pages/'+e.id.sub('page_','');
          } else if(e.hasClassName('section')) {
            var url = '/cms/sections/'+e.id.sub('section_','');
          } else {
            return; //WTF?
          }
          
          //Figure out section we are moving to
          var section = this.element.up();
          
          //Let the server know about the move
          url += '/move_to/'+section.id.sub('section_','')+'.js';
          new Ajax.Request(url, {method: 'put'});

          //Open the section and put the page/section into it
          var list = section.down('ul');
          list.show();
          section.down('img').src = '/images/cms/icons/actions/folder_open.png';
          list.appendChild(e);  
          e.setStyle({'z-index': 0, top: 0, left: 0});
        }
      }
    });    
  }); //End droppables
  
  //Attach click handlers to the icons
  $$('#sitemap a.section').each(function(e){
    e.observe('click', function(event){ 
      var a = $(event.element());
      var parent = a.up('li');
      var list = parent.down('ul');
      list.toggle();
      if(list.visible()) {
        parent.down('img').src = '/images/cms/icons/actions/folder_open.png';
      } else {
        parent.down('img').src = '/images/cms/icons/actions/folder.png';
      }
    })
  }); //End icon click handlers
  
  //Open up the current section and all it's parent sections
  //We are defining an anonymous function and then calling it
  //The anonymous function is recursive
  (function(section) {
    if(section) {
      section.down('ul').show();
      section.down('img').src = '/images/cms/icons/actions/folder_open.png';
      var parent;
      if(parent = section.up('li.section')) {
        arguments.callee(parent);
      }              
    }
  })($('sitemap').down('li.selected_section'));
  
  //Select the selected_page, if there is one
  var selectedPage = $('sitemap').down('span.selected_page');
  if(selectedPage) {
    clickHandler(selectedPage);
  }
  
});