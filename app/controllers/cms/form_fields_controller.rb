module Cms
  class FormFieldsController < Cms::BaseController

    layout false

    def new
      @field = Cms::FormField.new(label: 'Untitled', field_type: params[:field_type], form_id: params[:form_id])
    end

    def preview
      @form = Cms::Form.find(params[:id])
      @field = Cms::FormField.new(label: 'Untitled', name: :untitled, field_type: params[:field_type], form: @form)
    end

    def create
      form = Cms::Form.find(params[:form_field].delete(:form_id))
      field = FormField.new(form_field_params)
      field.form = form
      if field.save
        include_edit_path_in_json(field)
        include_delete_path_in_json(field)
        render json: field
      else
        render json: {
            errors: field.errors.full_messages
        },
               success: false,
               status: :unprocessable_entity
      end
    end

    def edit
      @field = FormField.find(params[:id])
      render :new
    end

    def update
      field = FormField.find(params[:id])
      if field.update form_field_params
        include_edit_path_in_json(field)
        render json: field
      else
        render text: "Fail", status: 500
      end
    end

    def destroy
      field = FormField.find(params[:id])
      field.destroy
      render json: field, success: true
    end

    def insert_at
      field = FormField.find(params[:id])
      field.insert_at(params[:position])
      render json: field
    end

    protected

    # For UI to update for subsequent editing.
    def include_edit_path_in_json(field)
      field.edit_path = cms.edit_form_field_path(field)
    end

    def include_delete_path_in_json(field)
      field.delete_path = cms.form_field_path(field)
    end

    def form_field_params()
      params.require(:form_field).permit(FormField.permitted_params)
    end
  end
end