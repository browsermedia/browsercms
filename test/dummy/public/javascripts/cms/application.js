//CMS related functions
jQuery(function($) {
  
  //It would be cool if these were added to the real jQuery
    //You can call this a few ways:
    //createElement('p') => "<p/>"
    //createElement('p','hi') => "<p>hi</p>"
    //createElement('p', {align: 'center'}) => "<p align="center"/>"
    //createElement('p','hi',{align: 'center'}) => "<p align="center">hi</p>"    
    $.createElement = function(tag_name, tag_value, tag_attrs) {
      var name = tag_name
      if(typeof tag_value == "object") {
        var value = null
        var attrs = tag_value
      } else {
        var value = tag_value
        var attrs = tag_attrs
      }
      var element = $(document.createElement(tag_name))
      if(attrs) {
        $.each(attrs, function(k,v) {
          element.attr(k,v)
        })
      }
      if(value) {
        element.html(value)
      }
      return element
    }
  
  var sanitizationRegexes = [[/\s/, "_"], [/[&+()]/, "-"], [/[=?!'"{}\[\]#<>%]/, ""]]
  
  $.cms = {
    sanitizeFileName: function(s) {
      var split = s.split(/\/|\\/)
      s = split[split.length-1]
      $.each(sanitizationRegexes, function(i,e){
        var r = new RegExp(e[0].source, 'g')
        s = s.replace(r, e[1])
      })
      return s;
    },
    slug: function(s) {
      return $.trim(s.toLowerCase().replace(/\W+/g, ' ')).replace(/\ +/g, '-')
    },
    showNotice: function(msg) {
      $('#message').removeClass('error').addClass('notice').html(msg).parent().show().animate({opacity: 1.0}, 3000).fadeOut("normal")
    },
    showError: function(msg) {
      $('#message').removeClass('notice').addClass('error').html(msg).parent().show().animate({opacity: 1.0}, 3000).fadeOut("normal")
    },
    attachEventHandlers: function(context) {
	$('a.button', context).click(function(){if($(this).hasClass('disabled')) return false;});
      $('a.http_post, a.http_put, a.http_delete', context).click(function() {
        if($(this).hasClass('disabled')) return false;
        if($(this).hasClass('confirm_with_title') ? confirm(this.title) : true) {

          // Create the form
          var f = document.createElement('form')
          f.style.display = 'none'
          this.parentNode.appendChild(f)
          f.method = "POST"
          f.action = this.href
          $(f).attr('target', $(this).attr('target'))

          //Create the _method hidden input
          var m = document.createElement('input')
          var http_method = $(this).attr('class').match(/http_([^ ]*)/)[1]
          $(m).attr('type', 'hidden').attr('name', '_method').attr('value', http_method)
          f.appendChild(m)
          
          //Create the authenticity_token hidden input
          if($.cms.authenticity_token && $.cms.authenticity_token != '') {
            var m = document.createElement('input')
            $(m).attr('type', 'hidden').attr('name', 'authenticity_token').attr('value', $.cms.authenticity_token)  
            f.appendChild(m)
          }
          
          f.submit()          
        }
        return false
      })      
    }
  }
  
  $.cms.attachEventHandlers(document);
  
  $('#message.notice').parent().show().animate({opacity: 1.0}, 3000).fadeOut("normal")
  $('#message.error').parent().show().animate({opacity: 1.0}, 3000).fadeOut("normal")
  
})

//CookieSet allows us to treat one cookie value as a set of values
jQuery(function($) {
  
  var sep = '|'
  
  $.cookieSet = {
    //Treats the cookie as an array 
    add: function(name, value, options) {
      this.remove(name, value, options)
      var set = this.get(name)
      if(set) {
        set.push(value)  
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