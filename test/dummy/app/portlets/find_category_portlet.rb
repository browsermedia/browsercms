class FindCategoryPortlet < Cms::Portlet

  description "[TEST] Verify that portlets can read parameters."

  # Mark this as 'true' to allow the portlet's template to be editable via the CMS admin UI.
  enable_template_editor false
     
  def render
    @expected_parameter = params[:category_id]
    if @expected_parameter
      @category = Cms::Category.where(id: @expected_parameter).first # Explicitly want to return nil rather than NotFound
    end
  end
    
end