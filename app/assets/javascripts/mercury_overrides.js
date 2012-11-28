// Reload the page after updating the page so things like page title and draft status are correct.
$(window).bind('mercury:saved', function () {
    window.location.reload();
});

// Toggling between Preview/Edit mode in Mercury should also hide the CMS container controls.
jQuery(window).on('mercury:mode', function (event, data) {
    if (data.mode == 'preview') {
        var page = $('#mercury_iframe').contents();
        if (window.previewMode == undefined) {
            window.previewMode = false;
        }
        if (window.previewMode) {
            window.previewMode = false;
            page.find('.cms-add-content').show();
            page.find('.cms-container').removeClass('cms-container-preview');
        } else {
            window.previewMode = true;
            page.find('.cms-container').addClass('cms-container-preview');
            page.find('.cms-add-content').hide();
        }
    }
});

jQuery(window).bind('mercury:ready', function () {

    // The goal here was to disable the edit block buttons when non-connector regions were selected.
    // However, context only seems to fire when 'full' regions are selected, so it doesn't really work well.
    // Other than when the page is first loaded, when it disables the button when the page title is selected.
    Mercury.Toolbar.ButtonGroup.contexts.content_blocks = function (node, region) {
        var parents =  node.parents(".connector");
        return parents.size() > 0;
    };



});