jQuery(function($){
  $('textarea.editor').each(function(e){
    if(editorEnabled()) {
      loadEditor(this.id);
    }
  });  
})

function editorEnabled() {
  return $J.cookie('editorDisabled') != "true";
}

function toggleEditor(id) {
  if(loadEditor(id)) {
    $J.cookie('editorDisabled', false, { expires: 90, path: '/' });      
  } else {
    $(id+'___Frame').toggle(); 
    $(id).toggle();  
    $J.cookie('editorDisabled', $(id).visible(), { expires: 90, path: '/' });      
  }
}

function loadEditor(id) {
  if(typeof(FCKeditorAPI) == "undefined" || FCKeditorAPI.GetInstance(id) == null) {
    var editor = new FCKeditor(id);
    editor.BasePath = "/fckeditor/";
    editor.ToolbarSet = 'CMS';   
    editor.Width = 540;
    editor.Height = 400; 
    editor.ReplaceTextarea();    
    return true;
  } else {
    return false;
  }
}

