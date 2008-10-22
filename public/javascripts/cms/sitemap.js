$J(document).ready(function(){
  
  //Disable all "buttons"
  $J('#buttons a.disabled').click(function(){ return false })
  
  //onClick for the folder icon for each section, show/hide section
  $J('#sitemap a.folder').click(function(){ 
    var id = this.id.replace(/folder_/,'')
    
    if($J(this).hasClass("folder-open")) {
      $J('.p'+id+', .a'+id).hide()
      $J(this).find('img').attr('src','/images/cms/icons/actions/folder.png')
      $J(this).removeClass("folder-open")
    } else {
      $J('.p'+id).show()
      $J(this).find('img').attr('src','/images/cms/icons/actions/folder_open.png')
      $J(this).addClass("folder-open")
    }
    return false 
  })
  
  //onClick for the name of a section/page
  $J('#sitemap span.node').click(function(){
    $J('#buttons a').addClass('disabled').click(function(){return false})
    $J('#sitemap span.node').removeClass('selected')
    $J(this).addClass('selected')
        
    var id = this.id.replace(/(section|page)_/,'');
    
    if($J(this).hasClass('root') || $J(this).hasClass('section')) {
      $J('#properties-button')
        .removeClass('disabled')
        .attr('href','/cms/sections/edit/'+id)
        .unbind('click')
        .click(function(){return true})
      
      $J('#add-page-button')
        .removeClass('disabled')
        .attr('href','/cms/pages/new?section_id='+id)
        .unbind('click')
        .click(function(){return true})

      $J('#add-section-button')
        .removeClass('disabled')
        .attr('href','/cms/sections/new?section_id='+id)
        .unbind('click')
        .click(function(){return true})
        
    } else if($J(this).hasClass('page')) {
      $J('#edit-button')
        .removeClass('disabled')
        .attr('href','/cms/pages/show/'+id)
        .unbind('click')
        .click(function(){return true})

      $J('#properties-button')
        .removeClass('disabled')
        .attr('href','/cms/pages/edit/'+id)
        .unbind('click')
        .click(function(){return true})
      
    }
  })
  
})
