CKEDITOR.plugins.add('move_content', {
    icons:'movecontentup,movecontentdown',
    init:function (editor) {
        editor.ui.addButton('MoveContentUp', {
            label:'Move this content up',
            command:'moveContentUp',
            toolbar:'tools'
        });
        editor.ui.addButton('MoveContentDown', {
            label:'Move this content down.',
            command:'moveContentDown',
            toolbar:'tools'
        });
        editor.addCommand('moveContentDown', {
            exec:function (editor) {
                $.cms_editor.moveContent(editor, 'move-down');
            }
        });
        editor.addCommand('moveContentUp', {
            exec:function (editor) {
                $.cms_editor.moveContent(editor, 'move-up');
            }
        });
    }
});