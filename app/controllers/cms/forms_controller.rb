class Cms::FormsController < Cms::ContentBlockController

  before_filter :associate_form_fields, only: [:create, :update]
  before_filter :strip_new_entry_params, only: [:create, :update]

  helper do
    # For new forms, if the user doesn't complete and save them, we need to delete them from the database.
    # The reason :new creates a form object (which is not conventional) is to allow AJAX FormField creation/association.
    def cleanup_before_abandoning
      ["new", "create"].include? action_name
    end
  end

  def new
    super
    @block.confirmation_text = "Thanks for filling out this form."
    @block.save!
  end

  protected

  # Split the space separated list of ids into an actual array of ids.
  # Rails might have a more conventional way to do this, but I couldn't figure it out.'
  def associate_form_fields
    field_ids = params[:field_ids].split(" ")
    params[:form][:field_ids] = field_ids
  end


  # params[:form][:new_entry] is just a garbage parameter that exists to make displaying forms work.
  # We want to ignore anything submitted here
  def strip_new_entry_params
    params[:form].delete(:new_entry)
  end
end
