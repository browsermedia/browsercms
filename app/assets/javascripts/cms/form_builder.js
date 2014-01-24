//= require cms/ajax
//= require underscore
//= require jquery.exists

/**
 * The UI for dynamically creating custom forms via the UI.
 * @constructor
 *
 */

var FormBuilder = function() {
};

// Add a new field to the form
// (Implementation: Clone existing hidden form elements rather than build new ones via HTML).
FormBuilder.prototype.newField = function(field_type) {
  this.hideNewFormInstruction();
  this.addPreviewFieldToForm(field_type);

};

FormBuilder.prototype.addPreviewFieldToForm = function(field_type) {
  $("#placeHolder").load($('#placeHolder').data('new-path') + '?field_type=' + field_type + ' .control-group', function() {
    var newField = $("#placeHolder").find('.control-group');
    newField.insertBefore('#placeHolder');
    formBuilder.enableFieldButtons();
    formBuilder.resetAddFieldButton();
  });
};

FormBuilder.prototype.resetAddFieldButton = function() {
  $("#form_new_entry_new_field").val('1');
};

FormBuilder.prototype.removeCurrentField = function() {
  this.field_being_editted.remove();
  this.field_being_editted = null;
};

// Function that triggers when users click the 'Delete' field button.
FormBuilder.prototype.confirmDeleteFormField = function() {
  formBuilder.field_being_editted = $(this).parents('.control-group');

  var path = $(this).attr('data-path');
  if (path == "") {
    formBuilder.removeCurrentField();
  } else {
    $('#modal-confirm-delete-field').modal({
      show: true
    });
  }
};

// Function that triggers when users click the 'Edit' field button.
FormBuilder.prototype.editFormField = function() {
  // This is the overall container for the entire field.
  formBuilder.field_being_editted = $(this).parents('.control-group');
  $('#modal-edit-field').modal({
    show: true,
    remote: $(this).attr('data-edit-path')
  });

};


FormBuilder.prototype.hideNewFormInstruction = function() {
  var no_fields = $("#no-field-instructions");
  if (no_fields.exists()) {
    no_fields.hide();
  }
};

// Add handler to any edit field buttons.
FormBuilder.prototype.enableFieldButtons = function() {
  $('.edit_form_button').unbind('click').on('click', formBuilder.editFormField);
  $('.delete_field_button').unbind('click').on('click', formBuilder.confirmDeleteFormField);
};

FormBuilder.prototype.newFormField = function() {
  return $('#ajax_form_field');
};

// Delete field from form, then remove it from the field
FormBuilder.prototype.deleteFormField = function() {
  var element = formBuilder.field_being_editted.find('.delete_field_button');
  var url = element.attr('data-path');
  $.cms_ajax.delete({
    url: url,
    success: function(field) {
      formBuilder.removeCurrentField();
      formBuilder.removeFieldId(field.id);
    }
  });
};

// @param [Number] value The id of the field that is to be removed from the form.
FormBuilder.prototype.removeFieldId = function(value) {
  var field_ids = $('#field_ids').val().split(" ");
  field_ids.splice($.inArray(value.toString(), field_ids), 1);
  formBuilder.setFieldIds(field_ids);
};

// @param [Array<String>] value
FormBuilder.prototype.setFieldIds = function(value) {
  var spaced_string = value.join(" ");
  $('#field_ids').val(spaced_string);
};

FormBuilder.prototype.addFieldIdToList = function(new_value) {
  $('#field_ids').val($('#field_ids').val() + " " + new_value);
};

// Save a new Field to the database for the current form.
FormBuilder.prototype.createField = function() {
  var form = formBuilder.newFormField();
  var data = form.serialize();
  var url = form.attr('action');

  $.ajax({
    type: "POST",
    url: url,
    data: data,
    global: false,
    datatype: $.cms_ajax.asJSON()
  }).done(
    function(field) {
      formBuilder.clearFieldErrorsOnCurrentField();

      formBuilder.addFieldIdToList(field.id);
      formBuilder.field_being_editted.find('input').attr('data-id', field.id);
      formBuilder.field_being_editted.find('label').html(field.label);
      formBuilder.field_being_editted.find('a').attr('data-edit-path', field.edit_path);
      formBuilder.field_being_editted.find('a.delete_field_button').attr('data-path', field.delete_path);
      formBuilder.field_being_editted.find('.help-block').html(field.instructions);

    }
  ).fail(function(xhr, textStatus, errorThrown) {
      formBuilder.displayErrorOnField(formBuilder.field_being_editted, xhr.responseJSON);
    });

};

FormBuilder.prototype.clearFieldErrorsOnCurrentField = function() {
  var field = formBuilder.field_being_editted;
  field.removeClass("error");
  field.find('.help-inline').remove();
};

FormBuilder.prototype.displayErrorOnField = function(field, json) {
  var error_message = json.errors[0];
//  console.log(error_message);
  field.addClass("error");
  var input_field = field.find('.input-append');
  input_field.after('<span class="help-inline">' + error_message + '</span>');
};

// Edit Field should handle Enter by submitting the form via AJAX.
    // Enter within textareas should still add endlines as normal.
FormBuilder.prototype.onEnterSubmitFormViaAjax = function() {
  this.newFormField().on("keypress", function(e) {
    if (e.which == 13 && e.target.tagName != 'TEXTAREA') {
      formBuilder.createField();
      e.preventDefault();
      $('#modal-edit-field').modal('hide');
      return false;
    }
  });
};
// Attaches behavior to the proper element.
FormBuilder.prototype.setup = function() {
  var select_box = $('.add-new-field');
  if (select_box.exists()) {
    select_box.change(function() {
      formBuilder.newField($(this).val());
    });

    this.enableFieldButtons();
    $("#delete_field").on('click', formBuilder.deleteFormField);

    $('#modal-edit-field').on('hidden.bs.modal', function(e) {
      $(this).removeData('bs.modal');
    });

    // Allow fields to be sorted.
    $('#form-preview').sortable({
      axis: 'y',
      delay: 250,

      // When form element is moved
      update: function(event, ui) {
        var field_id = ui.item.find('input').attr('data-id');
        var new_position = ui.item.index() + 1;
        formBuilder.moveFieldTo(field_id, new_position);
      }
    });
    this.setupConfirmationBehavior();
    this.enableFormCleanup();
  }
};

// Since we create a form for the #new action, we need to delete it if the user doesn't save it explicitly.
FormBuilder.prototype.enableFormCleanup = function() {
  var cleanup_element = $('#cleanup-before-abandoning');
  if (cleanup_element.exists()) {
    var cleanup_on_leave = true;
    $(":submit").on('click', function() {
      cleanup_on_leave = false;
    });
    $(window).bind('beforeunload', function() {
      if (cleanup_on_leave) {
        var path = cleanup_element.attr('data-path');
        $.cms_ajax.delete({url: path, async: false});
      }
    });
  }
};

// Updates the server with the new position for a given field.
FormBuilder.prototype.moveFieldTo = function(field_id, position) {
  var url = '/cms/form_fields/' + field_id + '/insert_at/' + position;

  var success = function(data) {
    console.log("Success:", data);
  };
  console.log('For', field_id, 'to', position);
  $.post(url, success);
};

FormBuilder.prototype.setupConfirmationBehavior = function() {
  // Confirmation Behavior
  $("#form_confirmation_behavior_show_text").on('click', function() {
    $(".form_confirmation_text").show();
    $(".form_confirmation_redirect").hide();
  });
  $("#form_confirmation_behavior_redirect").on('click', function() {
    $(".form_confirmation_redirect").show();
    $(".form_confirmation_text").hide();
  });
  $("#form_confirmation_behavior_show_text").trigger('click');
};
var formBuilder = new FormBuilder();

// Register FormBuilder handlers on page load.
jQuery(function($){
  formBuilder.setup();


  // Include a text field to start (For easier testing)
//  formBuilder.newField('text_field');
});
