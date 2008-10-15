document.observe('dom:loaded', function() { 
  $$('textarea.wysiwyg').each(function(e){
    if(wysiwygEnabled()) {
      loadWysiwyg(e.id);
    }
  });
});

function wysiwygEnabled() {
  return Cookies.get('wysiwygDisabled') != "true";
}

function toggleWysiwyg(id) {
  if(loadWysiwyg(id)) {
    Cookies.put('wysiwygDisabled', false);      
  } else {
    $(id+'___Frame').toggle(); 
    $(id).toggle();  
    Cookies.put('wysiwygDisabled', $(id).visible());      
  }
}

function loadWysiwyg(id) {
  if(typeof(FCKeditorAPI) == "undefined" || FCKeditorAPI.GetInstance(id) == null) {
    var editor = new FCKeditor(id);
    editor.BasePath = "/fckeditor/";
    editor.ToolbarSet = 'CMS';    
    editor.ReplaceTextarea();    
    return true;
  } else {
    return false;
  }
}

