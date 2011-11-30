require "test_helper"
require "generators/browser_cms/cms/cms_generator"

class CmsGeneratorTest < Rails::Generators::TestCase

  tests BrowserCms::Generators::CmsGenerator
  destination File.expand_path("../../../../tmp", __FILE__)
  setup :prepare_destination


  def setup
    generate_rails_app()
  end

  test "Assert new files are correctly generated" do
    run_generator
    assert_file "db/browsercms.seeds.rb"
    assert_file "db/seeds.rb" do |file|
      assert_match "require File.expand_path('../browsercms.seeds.rb', __FILE__)", file
    end

  end

  private
  def create_file(file_name)
    File.new(File.join(destination_root, file_name), 'w')
  end

  def create_directory(create_directory)
    Dir.mkdir(File.join(destination_root, create_directory))
  end

  def generate_rails_app
    create_directory("config")
    create_file("config/application.rb")

    create_directory("db")
    create_file("db/seeds.rb")



 end

end