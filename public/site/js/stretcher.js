
	//the main function, call to the effect object
	function init(){
		var stretchers = document.getElementsByClassName('stretcher'); //div that stretches
		var toggles = document.getElementsByClassName('display'); //h2s where I click on
		//accordion effect
		var myAccordion = new fx.Accordion(
			toggles, stretchers, {opacity: true, duration: 400}
		);
		//hash function
		function checkHash(){
			var found = false;
			toggles.each(function(h2, i){
				if (window.location.href.indexOf(h2.title) > 0) {
					myAccordion.showThisHideOpen(stretchers[i]);
					found = true;
				}
			});
			return found;
		}
		if (!checkHash()) myAccordion.showThisHideOpen(stretchers[0]);
		toggleViewHeadline('viewHeadline0')
	}
	function toggleViewHeadline(x){
		var toggles = document.getElementsByClassName('view');
		if (toggles.length){
			for(var i=0;i<toggles.length;i++){
				toggles[i].style.visibility='visible';
			}
		}
		//document.getElementById(x).style.visibility='hidden';
	}
