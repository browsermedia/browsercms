$(window).bind('mercury:saved', function() {
    // Reload the window after updating the page so things like page title, draft status are correct.
   window.location.reload();
});