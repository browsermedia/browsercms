# Just a spot check that a rails project was generated successfully.
# The exact files being check could be tuned better.
Then /^a rails application named "([^"]*)" should exist$/ do |app_name|
  self.project_name = app_name
  check_directory_presence [project_name], true
  expect_project_directories %w{ app config db }
  expect_project_files %w{script/rails Gemfile }
end

When /^BrowserCMS should be added the Gemfile$/ do
  check_file_content("#{project_name}/Gemfile", 'gem "browsercms"', true)
end
When /^I create a new BrowserCMS project named "([^"]*)"$/ do |name|
  self.project_name = name
  cmd = "bcms new #{project_name} --skip-bundle"
  run_simple(unescape(cmd), false)
end
When /^I create a module named "([^"]*)"$/ do |name|
  self.project_name = name
  cmd = "bcms module #{project_name} --skip-bundle"
  run_simple(unescape(cmd), false)
end
Then /^a rails engine named "([^"]*)" should exist$/ do |engine_name|
  check_directory_presence [engine_name], true
  expect_project_directories %w{ app config lib }
  expect_project_files ["script/rails", "Gemfile", "#{engine_name}.gemspec"]
end
When /^BrowserCMS should be added the \.gemspec file$/ do
  check_file_content("#{project_name}/#{project_name}.gemspec", "s.add_dependency \"browsercms\", \"~> #{Cms::VERSION}\"", true)

end

Given /^a BrowserCMS project named "([^"]*)" exists$/ do |project_name|

  unless File.exists?("#{@scratch_dir}/#{project_name}")
    old_dirs = @dirs
    @dirs = [@scratch_dir]
    create_bcms_project("petstore")
    @dirs = old_dirs
  end
  from = File.absolute_path("#{@scratch_dir}/#{project_name}")
  to = File.absolute_path("#{@aruba_dir}/#{project_name}")
  FileUtils.mkdir_p(@aruba_dir)
  FileUtils.cp_r(from, to)

  self.project_name = project_name
end

Given /^I am working on a BrowserCMS v3.3.x module named "([^"]*)"/ do |project_name|
  run_simple "rails _3.0.9_ new #{project_name} --skip-bundle"
  cd project_name
  append_to_file "config/database.yml", "# @original-yml"
  append_to_file "config/routes.rb", "# @original-routes"
  append_to_file "#{project_name}.gemspec", "# @original-gemspec"

  # Mimics a 3.3.x style public/bms/module_name where public files lived
  write_file "public/bcms/#{project_name.gsub("bcms_", "")}/test.html", "@original-html"
  write_file "public/bcms/#{project_name.gsub("bcms_", "")}/js/test.js", "@original-js"

  # 3.3.x engines will probably have some code in them
  write_file "lib/#{project_name}/engine.rb", "# @original-engine"
  write_file "lib/#{project_name}/version.rb", "# @original-version"

  # The DB folder might have some sqlite databases, BrowserCMS migrations and seeds data
  write_file "db/seeds.rb", "# Should get deleted"
  write_file "db/migrate/20080815014337_browsercms_3_0_0.rb", "# Should get deleted"
  write_file "db/migrate/20091109175123_browsercms_3_0_5.rb", "# Should get deleted"
  write_file "db/migrate/my_module_migration.rb", "# This should be kept'"
  write_file "db/development.sqlite3", "# Should get deleted"
  write_file "db/schema.rb", "# Should get deleted"
  create_git_project
end

When /^I run `([^`]*)` in the project$/ do |cmd|
  cd(project_name)
  run_simple(unescape(cmd), false)
  cd("..")
end

Then /^a project file named "([^"]*)" should contain "([^"]*)"$/ do |file, partial_content|
  check_file_content(prefix_project_name_to(file), partial_content, true)
end

Then /^a project file named "([^"]*)" should not contain "([^"]*)"$/ do |file, partial_content|
  check_file_content(prefix_project_name_to(file), partial_content, false)
end

When /^a migration named "([^"]*)" should contain "([^"]*)"$/ do |partial_file_name, partial_content|
  abs_path_migration = find_migration_with_name(partial_file_name)
  check_file_content(abs_path_migration, partial_content, true)
end
When /^a migration named "([^"]*)" should be created$/ do |name|
  migration = find_migration_with_name(name)
  expected = [
      "create_content_table",
      'Cms::ContentType.create!(:name => "Product", :group_name => "Product"',
      ', :prefix=>false'
  ]
  expected.each do |expect|
    check_file_content(migration, expect, true)
  end
end
When /^I generate a block using a namespace$/ do
  pending "Need to test that rails g cms:content_block Cms::Product will namespace correctly."
end
