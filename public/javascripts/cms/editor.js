jQuery(function($){
  $('textarea.editor').each(function(e){
    if(editorEnabled()) {
      loadEditor(this.id)
    }
  });  
})

function editorEnabled() {
  return $.cookie('editorEnabled') ? $.cookie('editorEnabled') == "true" : true
}

function disableEditor(id) {
  if(typeof(FCKeditorAPI) != "undefined" && FCKeditorAPI.GetInstance(id) != null) {
    $('#'+id).val(FCKeditorAPI.GetInstance(id).GetHTML()).show()
    console.log('Copied data from WYSIWYG to textarea')
    $('#'+id+'___Frame').hide()
    $.cookie('editorEnabled', false, { expires: 90, path: '/' })    
  }
}

function enableEditor(id) {
  if(typeof(FCKeditorAPI) != "undefined" && FCKeditorAPI.GetInstance(id) != null) {
    FCKeditorAPI.GetInstance(id).SetHTML($('#'+id).val())
    console.log('Copied data from textarea to WYSIWYG')
    $('#'+id).hide()
    $('#'+id+'___Frame').show()  
    $.cookie('editorEnabled', true, { expires: 90, path: '/' })    
  }
}

function toggleEditor(id, status) {
  loadEditor(id)
  if(status == 'Simple Text' || status.value == 'disabled'){
    disableEditor(id) 
  } else {
    enableEditor(id) 
  }
}

function loadEditor(id) {
  if(typeof(FCKeditorAPI) == "undefined" || FCKeditorAPI.GetInstance(id) == null) {
    var editor = new FCKeditor(id)
    editor.BasePath = "/fckeditor/"
    editor.ToolbarSet = 'CMS'
    editor.Width = 598
    editor.Height = 400
    editor.ReplaceTextarea()
    return true
  } else {
    return false
  }
}
