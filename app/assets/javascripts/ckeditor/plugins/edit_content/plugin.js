//= require cms/ajax

CKEDITOR.plugins.add('edit_content', {
    icons:'editcontent',
    init:function (editor) {
        editor.ui.addButton('EditContent', {
            label:'Edit this content in the full editor.',
            command:'editContent',
            toolbar:'tools'
        });

        editor.addCommand('editContent', {
            exec:function (editor) {
                window.parent.location = $.cms_editor.selectedConnector().data('edit-path');
            }
        });
    }
});