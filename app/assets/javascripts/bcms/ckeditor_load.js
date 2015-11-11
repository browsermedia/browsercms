// Replace any <textarea class="editor"> with a ckeditor widget.
//
// Note: Uses noConflict version of jquery to avoid possible issues with loading ckeditor.
jQuery(function ($) {
    $('textarea.editor').each(function (e) {
        if (editorEnabled(this.id)) {
            loadEditor(this.id);
        }
    });
});

function editorEnabled(id) {
    return $.cookie(cookieName(id)) ? $.cookie(cookieName(id)) == "true" : false;
}

function disableEditor(id) {
    if (typeof(CKEDITOR) != "undefined" && CKEDITOR.instances[id] != null) {
        $('#' + id).val(CKEDITOR.instances[id].getData()).show();
        CKEDITOR.instances[id].destroy();
        $.cookie(cookieName(id), false, { expires:90, path:'/' });
    }
}

function enableEditor(id) {
    if (typeof(CKEDITOR) != "undefined" && CKEDITOR.instances[id] != null) {
        CKEDITOR.instances[id].setData($('#' + id).val());
        $('#' + id).hide();
        $.cookie(cookieName(id), true, { expires:90, path:'/' });
    }
}

function toggleEditor(id, status) {
    loadEditor(id);
    if (status == 'Simple Text' || status.value == 'disabled') {
        disableEditor(id);
    } else {
        enableEditor(id);
    }
}

function loadEditor(id) {
    if (typeof(CKEDITOR) != "undefined") {
        if (CKEDITOR.instances[id] == null) {
            editor = CKEDITOR.replace(id);
            editor.config.toolbar = 'Standard';
            editor.config.width = '100%';
            editor.config.height = 400;
        }
        $.cookie(cookieName(id), true, { expires:90, path:'/' });
        return true;
    } else {
        return false;
    }
}

function cookieName(id) {
    return 'editorEnabled_' + id + '_' + $('#' + id).data('path')
}
