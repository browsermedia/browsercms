When /^I assign the home page as a task$/ do
  home_page = Cms::Page.with_path("/").first
  visit "/cms/pages/#{home_page.id}/tasks/new"
end