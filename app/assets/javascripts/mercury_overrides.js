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

//    console.log("Mercury has loaded.");
    Mercury.Toolbar.Button.contexts.moveBlockUp = function (node, region) {
//        console.log("I'm looking at region:");
//        console.log(region);
    }
//    console.log(Mercury.Toolbar.Button.contexts);
//    console.log(Mercury.Toolbar.ButtonGroup.contexts);

//  Mercury.modalHandlers.foo = function() { alert('foo') };
});