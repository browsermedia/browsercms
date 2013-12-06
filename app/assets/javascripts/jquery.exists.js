// Determine if an element exists.
//  i.e. if($('.some-class').exists()){ // do something }
jQuery.fn.exists = function() {
  return this.length > 0;
};