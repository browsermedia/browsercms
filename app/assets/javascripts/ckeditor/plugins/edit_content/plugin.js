CKEDITOR.plugins.add('edit_content', {
    icons:'editcontent',
    init:function (editor) {
        editor.ui.addButton('EditContent', {
            label:'Edit this content in the full editor.',
            command:'editContent',
            toolbar:'tools'
        });

        // When the user clicks the 'Edit Content' button, save any changes they made already, then take them to
        editor.addCommand('editContent', {
            exec:function (editor) {
                var goto_edit = function(){
                    window.parent.location = $.cms_editor.selectedConnector().data('edit-path');
                };
                if (editor.checkDirty()) {
                    $.cms_editor.saveChanges(editor, goto_edit);
                } else {
                    goto_edit.apply();
                }
            }
        });
    }
});