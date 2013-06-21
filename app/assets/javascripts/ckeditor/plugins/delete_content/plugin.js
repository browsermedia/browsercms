CKEDITOR.plugins.add('delete_content', {
    icons:'deletecontent',
    init:function (editor) {
        editor.ui.addButton('DeleteContent', {
            label:'Remove this content from the page (It will remain in Content Library)',
            command:'deleteContent',
            toolbar:'tools'
        });

        editor.addCommand('deleteContent', new CKEDITOR.dialogCommand('deleteContent'));

        CKEDITOR.dialog.add('deleteContent', function (editor) {
            return {
                title:'Remove Content',
                minWidth:300,
                minHeight:100,
                contents:[
                    {
                        id:'tab1',
                        label:'Confirm Delete',
                        elements:[
                            {
                                type:'html',
                                html:'<p>Do you want to remove this content from the page?</p><br /><p>(It will remain in the content library)</p>'
                            }
                        ]
                    }
                ],

                onOk:function () {
                    $.cms_editor.deleteContent();
                }
            };
        });
    }
});