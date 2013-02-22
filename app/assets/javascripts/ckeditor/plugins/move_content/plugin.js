//= require cms/ajax

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
                var move_down_path = $.cms_editor.selectedConnector().data('move-down');
                $.cms_ajax.put({
                    url:move_down_path,
                    success:function () {
                        $.cms_editor.reload();
                    },
                    beforeSend:$.cms_ajax.asJSON()
                });
            }
        });
        editor.addCommand('moveContentUp', {
            exec:function (editor) {
                var current_connector = $.cms_editor.selectedConnector();
                var move_up_path = current_connector.data('move-up');

                $.cms_ajax.put({
                    url:move_up_path,
                    success:function (result) {
                        $.cms_editor.reload();
                    },
                    beforeSend:$.cms_ajax.asJSON()
                });
            }
        });
    }
});