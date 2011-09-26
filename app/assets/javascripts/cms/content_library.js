jQuery(function($){
    
    //----- Helper Functions -----------------------------------------------------
    //In all of this code, we are defining functions that we use later
    //None of this actually manipulates the DOM in any way
    
    //This is used to get the id part of an elementId
    //For example, if you have section_node_5, 
    //you pass this 'section_node_5', 'section_node' 
    //and this returns 5
    var getId = function(elementId, s) {
	return elementId.replace(s,'')
    }
    

    var nodeOnDoubleClick = function() {
	if($('#edit_button').hasClass('disabled')) {
	    //$('#view_button').click()
	    location.href = $('#view_button')[0].href
	} else {
	    //$('#edit_button').click()      
	    location.href = $('#edit_button')[0].href
	}
    }
    
    var addNodeOnDoubleClick = function() {
	$('#blocks tr').dblclick(nodeOnDoubleClick)
    }
    
    //----- Init -----------------------------------------------------------------
    //In other words, stuff that happens when the page loads
    //This is where we actually manipulate the DOM, fire events, etc.
    
    addNodeOnDoubleClick()

})
