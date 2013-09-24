class AttachmentsInput < SimpleForm::Inputs::Base

  def input
    definitions = Cms::Attachment.definitions_for(object.class.name, :multiple)
    if definitions.empty?
      template.render(partial: 'cms/attachments/no_attachments_defined', locals: {object: object})
    else
      names = definitions.keys.sort
      names.unshift "Select a type to upload a file" if names.size > 1
      template.render(partial: 'cms/attachments/attachment_manager', locals: {:asset_definitions => definitions, :asset_types => names, f: @builder, object: object})
    end
  end

end