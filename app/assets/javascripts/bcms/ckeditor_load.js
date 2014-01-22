// Replace any <textarea class="editor"> with a ckeditor widget.
//
// Note: Uses noConflict version of jquery to avoid possible issues with loading ckeditor.
jQuery(function ($) {
    $('textarea.editor').each(function (e) {
        if (editorEnabled()) {
            loadEditor(this.id);
        }
    });
});

function editorEnabled() {
    return $.cookie('editorEnabled') ? $.cookie('editorEnabled') == "true" : true;
}

function disableEditor(id) {
    if (typeof(CKEDITOR) != "undefined" && CKEDITOR.instances[id] != null) {
        $('#' + id).val(CKEDITOR.instances[id].getData()).show();
        CKEDITOR.instances[id].destroy();
        $.cookie('editorEnabled', false, { expires:90, path:'/' });
    }
}

function enableEditor(id) {
    if (typeof(CKEDITOR) != "undefined" && CKEDITOR.instances[id] != null) {
        CKEDITOR.instances[id].setData($('#' + id).val());
        $('#' + id).hide();
        $.cookie('editorEnabled', true, { expires:90, path:'/' });
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
        $.cookie('editorEnabled', true, { expires:90, path:'/' });
        return true;
    } else {
        return false;
    }
}