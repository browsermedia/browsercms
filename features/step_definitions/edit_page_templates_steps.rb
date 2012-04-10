Given /^the following page template exists:$/ do |table|
  @page_templates =[]
  table.hashes.each do |r|
    @page_templates << Factory(:page_template, r)
  end
end

When /^I edit that page template$/ do
  p = @page_templates.first
  visit "/cms/page_templates/#{p.id}/edit"
end