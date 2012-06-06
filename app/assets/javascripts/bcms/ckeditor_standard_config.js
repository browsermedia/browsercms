// This is a custom configuration file that will be used by BrowserCMS to load instances of 
// the CKEditor.
// As per http://docs.cksource.com/ckeditor_api/symbols/CKEDITOR.config.html#.customConfig using a custom config
// avoids the need to 'mask' the core default config.js file that CKEDITOR comes packaged with.

CKEDITOR.config.toolbar_CMS = [
  ['Source','-','Cut','Copy','Paste','PasteText','PasteFromWord','-','SpellChecker','Scayt','-','Undo','Redo','Find','Replace','RemoveFormat','-','NumberedList','BulletedList','Outdent','Indent','HorizontalRule'],
  '/',
  ['Link','Unlink','Anchor','Image','Table','SpecialChar','-','Bold','Italic','Underline','JustifyLeft','JustifyCenter','JustifyRight','JustifyFull','-','TextColor','Styles']
];

CKEDITOR.config.toolbar_CMSForms = [
	['Source','-','Cut','Copy','Paste','PasteText','PasteFromWord','-','SpellChecker','Scayt','-','Undo','Redo','Find','Replace','RemoveFormat','-','NumberedList','BulletedList','Outdent','Indent','HorizontalRule'],
  '/',
	['Link','Unlink','Anchor','Image','Table','SpecialChar','Bold','Italic','Underline','JustifyLeft','JustifyCenter','JustifyRight','JustifyFull','TextColor','Styles'],
	'/',
	['TextField','Select','Checkbox','Radio','Textarea','Button','ImageButton','HiddenField']
];

CKEDITOR.config.width = 598;
CKEDITOR.config.height = 400;
CKEDITOR.config.toolbar = 'CMS';