require File.join(File.dirname(__FILE__), '/../../test_helper')

class GeneratorsTest < Test::Unit::TestCase

  def test_patterns_substition_for_windows
    pattern = /[A-Z\\A]:\//
    full_windows_path = "C:/Ruby/lib/ruby/gems/1.8/gems/browsercms-3.0.0/public/javascripts/jquery-ui.js"
    assert_equal "/Ruby/lib/ruby/gems/1.8/gems/browsercms-3.0.0/public/javascripts/jquery-ui.js", full_windows_path.gsub(pattern, "/")
    assert_equal "/Ruby/lib/ruby/gems/1.8/gems/browsercms-3.0.0/public/javascripts/jquery-ui.js", Cms.scrub_path(full_windows_path)


    full_windows_path = "D:/Ruby/lib/ruby/gems/1.8/gems/browsercms-3.0.0/public/javascripts/jquery-ui.js"
    assert_equal "/Ruby/lib/ruby/gems/1.8/gems/browsercms-3.0.0/public/javascripts/jquery-ui.js", full_windows_path.gsub(pattern, "/")
    assert_equal "/Ruby/lib/ruby/gems/1.8/gems/browsercms-3.0.0/public/javascripts/jquery-ui.js", Cms.scrub_path(full_windows_path)

    full_windows_path = "F:/Ruby/lib/ruby/gems/1.8/gems/browsercms-3.0.0/public/javascripts/jquery-ui.js"
    assert_equal "/Ruby/lib/ruby/gems/1.8/gems/browsercms-3.0.0/public/javascripts/jquery-ui.js", full_windows_path.gsub(pattern, "/")
    assert_equal "/Ruby/lib/ruby/gems/1.8/gems/browsercms-3.0.0/public/javascripts/jquery-ui.js", Cms.scrub_path(full_windows_path)

  end
 
end