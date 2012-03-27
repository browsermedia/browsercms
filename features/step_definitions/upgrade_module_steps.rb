# We can't just call `rails _2.3.14_ new` because Aruba locks to a specific version of the gem (I think).
# So we always get a Rails 3.1 project.
# Instead, we are 'faking' it.
Given /^I am working on a BrowserCMS v3.1.x module named "([^"]*)"$/ do |project_name|
  write_file "#{project_name}/script/console", "# Rails 2 File"
  cd project_name
  write_file "lib/#{project_name}.rb", "# Marks this as a Module."
  create_git_project
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
  write_file "lib/#{project_name}.rb", "# Marks this as a Module"
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

When /^the installation script should be created$/ do
  steps %Q{
  And the following directories should exist:
      | lib/generators/bcms_widgets/install/templates |
    And the following files should exist:
      | lib/generators/bcms_widgets/install/USAGE                |
  }
  generator = 'lib/generators/bcms_widgets/install/install_generator.rb'
  check_file_presence([generator], true)
  check_file_content(generator, "BcmsWidgets::InstallGenerator", true)
  check_file_content(generator, "rake 'bcms_widgets:install:migrations'", true)
  check_file_content(generator, "mount_engine(BcmsWidgets)", true)

end
When /^the engine should be created$/ do
  check_file_presence(['lib/bcms_widgets.rb'], true)
  check_file_content('lib/bcms_widgets/engine.rb', "include Cms::Module", true)

end
Given /^I am working on a BrowserCMS v3.3.x project named "([^"]*)"$/ do |project_name|
  create_historical_cms_project(project_name, "3.0.9", "3.3.3")
end

Given /^I am working on a BrowserCMS v3.4.x project named "([^"]*)"$/ do |project_name|
  create_historical_cms_project(project_name, "3.1.0", "3.3.3")
  write_file 'config/environments/production.rb', "#Before\nconfig.action_controller.page_cache_directory = File.join(Rails.root,'public','cache')\nAfter"
end

Then /^a Gemfile should be created$/ do
  steps %Q{
  Then a file named "Gemfile" should exist
        }
end

When /^it should no longer generate a README in the public directory$/ do
  check_file_presence [' public/bcms/bcms_widgets/README '], false
end

When /^the project should be LGPL licensed$/ do
  check_file_presence ['GPL.txt', 'LICENSE.txt'], true
  check_file_presence ['MIT-LICENSE'], false
end

When /^it should remove the default cache directory$/ do
  check_file_content('config/environments/production.rb', "config.action_controller.page_cache_directory", false)
end