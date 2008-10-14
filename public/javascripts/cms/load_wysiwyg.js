document.observe('dom:loaded', function() { 
  $$('textarea.wysiwyg').each(function(e){
    var editor = new FCKeditor(e.id);
    editor.BasePath = "/fckeditor/";
    editor.ReplaceTextarea();
  });
});
