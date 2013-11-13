/*! jquery.infieldLabel.js v 1.0 | Author: Jeremy Fields [jeremy.fields@viget.com], 2013 | License: MIT */

(function($){

	$.infieldLabel = function(el, options){

		// To avoid scope issues, use 'base' instead of 'this'
		// to reference this class from internal events and functions.
		var base = this;

		// Access to jQuery and DOM versions of element
		base.$el = $(el);
		base.el = el;

		// Add a reverse reference to the DOM object
		base.$el.data("infieldLabel", base);

		// internal variables
		base.$input = null;

		base.init = function() {
			base.options = $.extend({}, $.infieldLabel.defaultOptions, options);

			base.setup();
		};


		// setup
		// ==========================================================================

		// first time input setup
		base.setup = function() {
			base.$input = base.$el.find("input[type=text],input[type=password]");

			// hide label if there's already a value
			base.blur();

			// bind events
			base.bind();
		};

		// binds the focus, blur and change events
		base.bind = function() {
			base.$input
				.on("focus.infield", function() {
					base.$el
						.removeClass(base.options.hideClass)
						.addClass(base.options.focusClass);

				}).on("blur.infield change.infield", function() {
					base.blur();
				});
		};

		base.blur = function() {
			if (base.$input.val() !== "") {
				base.$el
					.removeClass(base.options.focusClass)
					.addClass(base.options.hideClass);

			} else {
				base.$el.removeClass(base.options.focusClass + " " + base.options.hideClass);
			}
		};

		// run initializer
		// ==========================================================================
		base.init();
	};

	$.infieldLabel.defaultOptions = {
		focusClass: "placeholder-focus",
		hideClass: "placeholder-hide"
	};

	$.fn.infieldLabel = function(options){
		this.each(function(){
			(new $.infieldLabel(this, options));
		});
	};

})(jQuery);