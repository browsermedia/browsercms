/*
  jQuery taglist plugin

  Defines a widget for allowing users to selecting tags in BrowserCMS. This is part of the BrowserCMS core project.

  Please see the accompanying LICENSE.txt for licensing information.
*/
(function($){
  $.fn.tagList = function(tags) {
    var tagListInput = this;
    var tagSeparator = " ";
    
    var getTagList = function() {
      return $('#'+$(tagListInput).attr('id')+'-tag-list');
    }
    
    var getCurrentTag = function() {
      var value = $(tagListInput).val();
      if(value == "" || value.match(/\s$/)) {
        return ""
      } else {
        var tags = value.split(tagSeparator)
        return tags[tags.length-1]
      }
    }
    
    var getSelectedTag = function() {
      return getTagList().find('li.selected')
    }
    
    var getFirstTag = function() {
      return getTagList().find('li:first')
    }
    
    var positionAndSizeTagList = function() {
      getTagList().css('top', $(tagListInput).offset().top+$(tagListInput).outerHeight())
        .css('left', $(tagListInput).offset().left)
        .css('width', $(tagListInput).outerWidth())
    }
    
    var createEmptyTagList = function() {
      var id = $(tagListInput).attr('id') + '-tag-list';
      $(tagListInput).after('<ul id="'+id+'" class="tag-list" style="display: none"></ul>')
      positionAndSizeTagList()
    }          

    var matchesInputValue = function(tag, value) {
      return tag && value && (tag.toLowerCase().indexOf(value.toLowerCase()) == 0);
    }

    var showTagList = function(value) {
      var html = []
      $.each(tags, function(i, tag){
        if(matchesInputValue(tag, value)) {
          html.push('<li>'+tag+'</li>');  
        }
      })
      getTagList().html(html.join("\n")).show()
      getTagList().find('li').click(function(){
        selectTag(this); 
        acceptTag();
        return false;
      });
    }
    
    var updateTagList = function() {
      var value = getCurrentTag()
      if(value && value != "") {
        showTagList(value)
      } else {
        getTagList().hide();
      }
    }
    
    var handleNavKeys = function(event) {
      switch(event.keyCode) {
        case 38: //Up Arrow
          selectPrevTag()
          break;
        case 40: //Down Arrow
          selectNextTag()
          break;
        case 9: //Tab
        case 13: //Return
          return !getTagList().is(':visible') || acceptTag();
      }            
    }
    
    var handleInput = function(event) {
      switch(event.keyCode) {
        case 9:
        case 13:
        case 38:
        case 40:
          break;
        default:
          updateTagList();
      }
    }
    
    var selectTag = function(tag) {
      getTagList().find('li').removeClass('selected')
      $(tag).addClass('selected')
    }

    var selectPrevTag = function() {
      if(getSelectedTag().length > 0 && getSelectedTag().prev().length > 0) {
        selectTag(getSelectedTag().prev())
      } else {
        selectTag(getFirstTag())
      }
    }
    
    var selectNextTag = function() {
      if(getSelectedTag().length > 0 && getSelectedTag().next().length > 0) {
        selectTag(getSelectedTag().next())
      } else {
        selectTag(getFirstTag())
      }
    }
    
    var acceptTag = function() {
      if(getSelectedTag().length == 0) {
        if(getTagList().find('li').length > 0) {
          selectTag(getFirstTag())  
        } else {
          return true;
        }        
      }
      var tags = $(tagListInput).val().split(tagSeparator)
      tags.pop()
      tags.push(getSelectedTag().text())
      $(tagListInput).val(tags.join(tagSeparator))
      getTagList().hide()
      return false;            
    }
    
    createEmptyTagList()
    $(this).keydown(handleNavKeys).keyup(handleInput)
    $(this).attr('autocomplete', 'off') //Disable autofill on FF
    $(this).blur(function(){getTagList().hide()})
  }
})(jQuery);