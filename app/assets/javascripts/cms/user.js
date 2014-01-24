//= require 'jquery.exists'
//= require 'cms/namespace'

Cms.User = function() {
};

// Find the current user and then take action based on whether the current user is authenticated or not.
// @todo - Avoid repeated AJAX calls to find the user if this is involved multiple times.
//
// @param [ObjectLiteral] options
// @option options [Function] :authenticated Call for authenticated users.
// @option options [Function] :guest (Optional) Call for guests.
//
// @example  Cms.User.current({
//    authenticated: function(user){ alert("Hello " + user.first_name);
// }); 
Cms.User.current = function(handler) {
  $.getJSON('/cms/user.json', function(user) {
//    console.log("current_user", user);
    if (user.is_logged_in) {
      handler.authenticated(user);
    } else if (handler.guest) {
      handler.guest(user);
    }
  });
};

// Default Handler for login portlet. Hide the form, show 'Hello $first_name'
jQuery(function($){
  if ($('.login-portlet').exists()) {
    Cms.User.current({
        authenticated: function(user) {
          $('.authenticated').show().find('.first-name').html(user.first_name);
          $('.guest').hide();
        }
      }
    );
  }
});

