// Allows users to upload files via AJAX as attachments for a given block.
//
$(function () {
    $.cms.AttachmentManager = {
        upload:function (file) {
            var assetName = $('#attachment_attachable_type').val()
                    , attachableClass = $('#asset_attachable_class').val()
//                    , attachableIDField = $('#asset_attachable_id')
                    , attachableID = $('#asset_attachable_id').val()
                    , file = $('#asset_add_file')
                    , form = $('<form target="asset_add_uploader" method="post" action="/cms/attachments" enctype="multipart/form-data" style="visibility:hidden">')
                    , fields = '';

            fields += '<input type="hidden" name="attachment[attachment_name]" value="' + assetName.toLowerCase() + '" />';
            fields += '<input type="hidden" name="attachment[attachable_class]" value="' + attachableClass + '" />';
            fields += '<input type="hidden" name="attachment[attachable_type]" value="' + attachableClass + '" />';
            fields += '<input type="hidden" name="attachment[attachable_id]" value="' + attachableID + '" />';
            fields += '<input type="hidden" name="authenticity_token" value="' + $.cms.csrfToken() + '" />';

            $('body').append(form);
            form.append(fields);
            form.append(file);
            $('label[for="asset_add_file"]').after(file.clone());

            var inp = $('<input type="file" name="attachment[data]" id="asset_add_file" onchange="$.cms.AttachmentManager.upload(this)" />');

            form.submit();

            $('#upload-attachment').modal('hide');
        },
        enableDeleteButtons:function(){
          // Handle delete attachment button
          var delete_attachments_btns = $("a[data-purpose='delete-attachment']");
          if(delete_attachments_btns.exists()){
              delete_attachments_btns.off('click').on('click', function(){
                  var id = $(this).data('id');
                  $.cms.AttachmentManager.destroy(id);
              });
          }
        },
        // @param [Integer] id The id of the attachment to delete.
        destroy:function (id) {
            if (confirm("Are you sure want to delete this attachment?")) {
                $.post('/cms/attachments/' + id, {_method:'delete', authenticity_token:$.cms.csrfToken()}, function (attachment_id) {
//                    console.log(attachment_id);
                    $("#attachment_" + attachment_id).hide();
                    if ($("#assets_table > table tr:visible").length <= 2) {
                        $("#assets_table > table").hide();
                    }
                    $('#attachments_manager_changed').val(true);
                }, 'script');

            }
            return false;
        }
    }

    $('#asset_types').selectbox({width:'445px'});

    $('#asset_types').change(function () {
        if ($(this).val().indexOf('Select') != 0) {
            $('#asset_add').show();
        } else {
            $('#asset_add').hide();
        }
    });

    // After an attachment is uploaded, copy the values into the main attachment table.
    $('#asset_add_uploader').load(function () {
        $('#attachments_manager_changed').val(true); // Mark that the list of attachment has changed
        var response = $(this).contents();

        if (response.find('tr').html()) {
            var asset = $(response).find('tr').clone();
            var id = $(response).find("#asset-id").html();
            var asset_ids = $('#attachment_manager_ids_list');

            $(asset_ids).val($(asset_ids).val() + id + ",");
            $('#file-asset-uploader').remove();
            $('#assets_table > table').append(asset).show();
            $('div.buttons').show();
        }
        $('.empty-row').hide();
        $.cms.AttachmentManager.enableDeleteButtons();
    });

  $.cms.AttachmentManager.enableDeleteButtons();
});
