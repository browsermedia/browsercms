/***
 * Slideshow.js
 * Tom McFarlin / March 2008
 * version 0.2 beta 1
 */

/*---------------------------------------------------------------------------*/
document.observe('dom:loaded', function() {
	var images = $$('div#slideshow-container img');
	var container = $('slideshow-container');
	if (images.length == 1 || !container) return;
	images.each(function(i) {
		if (images.first() != i) i.hide();
	});
});
Event.observe(window, 'load', function(evt) {
	new Slideshow($$('div#slideshow-container img'), $('slideshow-container'));
});
/*---------------------------------------------------------------------------*/
var Slideshow = Class.create({
	
	initialize: function(imgs, cntnr) {
		
		var This = this;
		this.images = imgs;
		this.container = cntnr;
		this.FADE = false;
		this.SPEED = 5;		
		this.activeImage = null;
		this.nextImage = null;

		this.start();
		
	},
	
	start: function() {
		
		this._setupImages();
		this._setupContainer();
		var This = this;
		new PeriodicalExecuter(function(pe) {
			This._rotate();
		}, This.SPEED)
		
	},
	
	_setupImages: function() {
		
		var This = this;
		this.images.each(function(i) {

			This._setStyle(i);
			
			if(This.images.first() == i) {
				This.activeImage = i;
			} else {
				i.hide();
			}

		});
		
	},
	
	_setupContainer: function() {
		
		var maxHeight = -1;
		var maxWidth = -1;
		this.images.each(function(i) {
			if (i.height > maxHeight) {
				maxHeight = i.height;
			}
			if (i.width > maxWidth) {
				maxWidth = i.width;
			}
		});
	
		this.container.setStyle({
			height: maxHeight + 'px',
			width: maxWidth + 'px'
		});
		
		var This = this;
		this.container.classNames().each(function(n) {
			if(n.toLowerCase() == 'fade') {
				This.FADE = true;
			} else if ((n * 0) == 0) {
				This.SPEED = n;
			}
		});
		
	},
	
	_rotate: function() {

		if(this.activeImage == this.images.last()) {
			this.nextImage = this.images.first();
		} else {
			this.nextImage = this.images[this.images.indexOf(this.activeImage) + 1];
		} 
		
		this._swap(this.activeImage, this.nextImage);

	},
	
	_swap: function(current, next) {
	
		/* opera's failsafe */
		this._setStyle(current);
	
		if(this.FADE) {
			new Effect.Fade(current);
			new Effect.Appear(next);
		} else {
			current.hide();
			next.show();
		}
		
		this.activeImage = this.nextImage;
		
	},
	
	_setStyle: function(image) {
	
		var margin = '-' + image.height + 'px';
		if(image.getStyle('margin-bottom') != margin) {
			image.setStyle({
				marginBottom: margin,
				float: 'left'
			});
		}
		
	}
	
});