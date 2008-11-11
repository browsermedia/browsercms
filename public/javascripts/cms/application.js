//CMS related functions
jQuery(function($) {
  $.cms = {
    showNotice: function(msg) {
      $('#message').removeClass('error').addClass('notice').html(msg).show().animate({opacity: 1.0}, 3000).fadeOut("normal")
    },
    showError: function(msg) {
      $('#message').removeClass('notice').addClass('error').html(msg).show().animate({opacity: 1.0}, 3000).fadeOut("normal")
    }
  }
})

//CookieSet allows us to treat one cookie value as a set of values
jQuery(function($) {
  
  var sep = '|'
  
  $.cookieSet = {
    //Treats the cookie as an array 
    add: function(name, value, options) {
      var set = this.get(name)
      if(set) {
        if(!this.contains(name, value)) {
          set.push(value)  
        }
      } else {
        var set = [value]
      }
      $.cookie(name, set.join(sep), options)
      return this.get(name)
    },

    get: function(name) {
      var val = $.cookie(name)
      if(val) {
        return val.split(sep)
      } else {
        return null
      }
    },

    remove: function(name, value, options) {
      var set = this.get(name)
      if(set) {
        var arr = []
        $.each(set, function() {
          if(this != value+'') {
            arr.push(this)  
          }          
        })
        $.cookie(name, arr.join(sep), options)
        return this.get(name)         
      } else {
        return null
      }
    },

    //Treats the cookie as an array 
    contains: function(name, value) {
      var set = this.get(name)
      if(set) {
        return $.inArray(value+'', set) > -1
      } else {
        return false
      }
    }    
  }
  
})