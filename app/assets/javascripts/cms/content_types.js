// Adds AJAX behavior primarily for List Portlet

jQuery(function($){
  var select_tag = $('*[data-role="content_type_selector"]');
  var order_field = $('*[data-role="order-fields"]');
  if(select_tag.exists()){
    select_tag.on('change', function(){
      var selected_option = $( this ).val();
      console.log("Changed to", selected_option );
      order_field.load( '/cms/content_types.js .load > .select', { "content_type": selected_option } )
    });
  }
});