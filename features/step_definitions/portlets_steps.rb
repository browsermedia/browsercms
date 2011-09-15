# Steps for portlet.features
When /^I delete that portlet$/ do
  # cms_portlet_path(@subject) seemed to create a wrong path: /cms/portlets.1 rather than the below statement
  page.driver.delete "/cms/portlets/#{@subject.id}"
end
When /^I view that portlet$/ do
  visit cms_portlet_path(@subject)
end
When /^I edit that portlet$/ do
  visit edit_cms_portlet_path(@subject)
end