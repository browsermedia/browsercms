var bcmsOrg = 
{
	init : function()
	{
		$('ul').find('li:last').addClass('last-child');
		$('ul').find('li:first').addClass('first-child');
		$('ul * li:last').each(function(){$(this).addClass('final'); $(this).parents('li').addClass('final')});
		
		Cufon.replace(Array('#topnav>ul>li>a'),{fontFamily:'HelveticaNeueCond'});
		Cufon.replace(Array('#slides .controls li a','h2','h3','h4','h5'),{fontFamily:'HelveticaNeueCondBold'});
		Cufon.replace(Array('#benefits blockquote ul.items li a.view'),{fontFamily:'HelveticaNeueBold',hover:true});
		Cufon.now();				
		
		$('#topnav>ul>li:last').hover(this.downloadHoverOn, this.downloadHoverOff);
		$('#browsercms .download').hover(this.downloadHoverOn, this.downloadHoverOff);

	},
	downloadHoverOn: function()
	{
		$('#browsercms .download').css({opacity:1, backgroundImage:'url(/images/download-on.gif)'});
		$('#topnav>ul>li:last>a').addClass('active');
	},
	downloadHoverOff: function()
	{
		$('#browsercms .download').css({opacity:0.19, backgroundImage:'url(/images/download.gif)'});
		$('#topnav>ul>li:last>a').removeClass('active');
	}
}