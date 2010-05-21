/* 
  A SproutCore object designed to bridge text areas and bespin editors.
  
  On creation it requires the ID of a text area which will be hidden, replaced
  with a bespin area of approximately the same size and the value will be kept in sync as 
  the contents of the editor changes
*/

BespinArea = SC.Object.extend({
  textAreaInput: null, // The DOM object of the text area input
  bespinEditor: null, // The Bespin object tied to the text editor
  editingDiv: null,  // The DOM object of our initial div, where we place bespin
  hide: function() {
    this.editingDiv.style.visibility="hidden";
    this.editingDiv.style.display="none";
    
    this.textAreaInput.style.display="block";
  },
  show: function(){
    this.editingDiv.style.display="block";
    this.editingDiv.style.visibility="visible";   
    
    this.textAreaInput.style.display="none";
    
    if (this.bespinEditor != null) {
      this.bespinEditor.setValue(this.textAreaInput.value);
    }
  },
  toggle: function() {
    if (this.editingDiv.style.visibility == "visible") {
      this.hide();
    }
    else {
      this.show();
    }
  },
  init: function() {
    this.sc_super();
    this.set('textAreaInput', document.getElementById(this.textAreaInputId));
    this.set('editingDiv', document.getElementById(this.textAreaInputId + "_editor"));
                      
    var width = this.textAreaInput.style.width;
    var height = this.textAreaInput.style.height;
    
    if (tiki.require("bespin:util/util").isString(width) === false || width == "") {
      width =  this.textAreaInput.scrollWidth + "px"; 
    }
    
    if (tiki.require("bespin:util/util").isString(height) === false || height == "") {
      height = this.textAreaInput.scrollHeight + "px"; 
    }
    
    this.editingDiv.style.height = height;
    this.editingDiv.style.width = width;
    this.show();
    
    //Load up bespin
    var bespinEditor = tiki.require("embedded").useBespin(this.editingDiv, this.bespinOptions);
    //Set the initial content
    if (this.initialContent !== null) bespinEditor.setValue(this.initialContent);
    
    //Update the textarea when the text of the editor changes
    var input = this.textAreaInput;
    bespinEditor.addEventListener('textChange', function() {
      input.value = bespinEditor.getValue();
    });
    
    //Store them for later reference
    this.set('bespinEditor', bespinEditor);
  }
});