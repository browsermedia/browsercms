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
    assert_file "public/site/customconfig.js"
    assert_file "db/migrate/20080815014337_browsercms_3_0_0.rb"
    assert_file "db/migrate/20091109175123_browsercms_3_0_5.rb"
    assert_file "db/migrate/20100705083859_browsercms_3_3_0.rb"
    assert_file "db/seeds.rb"

  end

  private
  def generate_rails_app
    Dir.mkdir(File.join(destination_root, "config"))

    file_name = File.join(destination_root, "config/application.rb")
    f = File.new(file_name, 'w')
 end

end