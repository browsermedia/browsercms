jQuery(function($){
  $('textarea.editor').each(function(e){
    if(editorEnabled()) {
      loadEditor(this.id)
    }
  });  
})

function editorEnabled() {
  return $.cookie('editorDisabled') != "true"
}

function setEditor(id, status) {
    if (status == 'Simple Text' || status.value == 'disabled'){
	$('#'+id+'___Frame').hide();
	$('#'+id).show();
       $.cookie('editorDisabled', true, { expires: 90, path: '/' })    
    } else {
	loadEditor(id);
	$('#'+id+'___Frame').show();
	$('#'+id).hide();
        $.cookie('editorDisabled', false, { expires: 90, path: '/' })    
    }
}

function toggleEditor(id) {
  if(loadEditor(id)) {
    $.cookie('editorDisabled', false, { expires: 90, path: '/' })    
  } else {
    $('#'+id+'___Frame').toggle()
    $('#'+id).toggle()
    $.cookie('editorDisabled', true, { expires: 90, path: '/' })    
  }
}

function loadEditor(id) {
  if(typeof(FCKeditorAPI) == "undefined" || FCKeditorAPI.GetInstance(id) == null) {
    var editor = new FCKeditor(id)
    editor.BasePath = "/fckeditor/"
    editor.ToolbarSet = 'CMS'
    editor.Width = 540
    editor.Height = 400
    editor.ReplaceTextarea()   
    return true
  } else {
    return false
  }
}

