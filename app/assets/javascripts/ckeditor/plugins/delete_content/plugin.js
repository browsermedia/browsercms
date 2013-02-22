//= require cms/ajax

CKEDITOR.plugins.add('delete_content', {
    icons:'deletecontent',
    init:function (editor) {
        editor.ui.addButton('DeleteContent', {
            label:'Remove this content from the page (It will remain in Content Library)',
            command:'deleteContent',
            toolbar:'tools'
        });

        editor.addCommand('deleteContent', {
            exec:function (editor) {
                var sc = $.cms_editor.selectedConnector();
                var remove_path = sc.data('remove');
                $.cms_ajax.delete({
                    url:remove_path,
                    success:function(){
                        sc.remove();
                    },
                    beforeSend:$.cms_ajax.asJSON()
                });
            }
        });
    }
});