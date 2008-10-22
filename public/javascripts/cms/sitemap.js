$J(document).ready(function(){
  $J('#buttons a.disabled').click(function(){ return false })
  
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
