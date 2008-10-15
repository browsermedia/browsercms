document.observe('dom:loaded', function() { 
  $$('textarea.editor').each(function(e){
    if(editorEnabled()) {
      loadEditor(e.id);
    }
  });
});

function editorEnabled() {
  return Cookies.get('editorDisabled') != "true";
}

function toggleEditor(id) {
  if(loadEditor(id)) {
    Cookies.put('editorDisabled', false);      
  } else {
    $(id+'___Frame').toggle(); 
    $(id).toggle();  
    Cookies.put('editorDisabled', $(id).visible());      
  }
}

function loadEditor(id) {
  if(typeof(FCKeditorAPI) == "undefined" || FCKeditorAPI.GetInstance(id) == null) {
    var editor = new FCKeditor(id);
    editor.BasePath = "/fckeditor/";
    editor.ToolbarSet = 'CMS';   
    editor.Width = 540; 
    editor.ReplaceTextarea();    
    return true;
  } else {
    return false;
  }
}

