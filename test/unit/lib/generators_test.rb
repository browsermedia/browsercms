require File.join(File.dirname(__FILE__), '/../../test_helper')

class GeneratorsTest < Test::Unit::TestCase

  def test_patterns_substition_for_windows
    pattern = /\b[A-Za-z]:\//

    # Default
    full_windows_path = "C:/Ruby/lib/ruby/gems/1.8/gems/browsercms-3.0.0/public/javascripts/jquery-ui.js"
    assert_equal "/Ruby/lib/ruby/gems/1.8/gems/browsercms-3.0.0/public/javascripts/jquery-ui.js", full_windows_path.gsub(pattern, "/")
    assert_equal "/Ruby/lib/ruby/gems/1.8/gems/browsercms-3.0.0/public/javascripts/jquery-ui.js", Cms.scrub_path(full_windows_path)

    # D: drive
    full_windows_path = "D:/Ruby/lib/ruby/gems/1.8/gems/browsercms-3.0.0/public/javascripts/jquery-ui.js"
    assert_equal "/Ruby/lib/ruby/gems/1.8/gems/browsercms-3.0.0/public/javascripts/jquery-ui.js", full_windows_path.gsub(pattern, "/")
    assert_equal "/Ruby/lib/ruby/gems/1.8/gems/browsercms-3.0.0/public/javascripts/jquery-ui.js", Cms.scrub_path(full_windows_path)

    # F: Drive
    full_windows_path = "F:/Ruby/lib/ruby/gems/1.8/gems/browsercms-3.0.0/public/javascripts/jquery-ui.js"
    assert_equal "/Ruby/lib/ruby/gems/1.8/gems/browsercms-3.0.0/public/javascripts/jquery-ui.js", full_windows_path.gsub(pattern, "/")
    assert_equal "/Ruby/lib/ruby/gems/1.8/gems/browsercms-3.0.0/public/javascripts/jquery-ui.js", Cms.scrub_path(full_windows_path)

    # lower-case
    full_windows_path = "c:/Ruby/lib/ruby/gems/1.8/gems/browsercms-3.0.0/public/javascripts/jquery-ui.js"
    assert_equal "/Ruby/lib/ruby/gems/1.8/gems/browsercms-3.0.0/public/javascripts/jquery-ui.js", full_windows_path.gsub(pattern, "/")
    assert_equal "/Ruby/lib/ruby/gems/1.8/gems/browsercms-3.0.0/public/javascripts/jquery-ui.js", Cms.scrub_path(full_windows_path)

    # multiple
    full_windows_path = "c:/Ruby/lib/ruby/gems/1.8/gems/browsercms-3.0.0/public/javascripts/jquery-ui.js c:/Ruby/lib/ruby/gems/1.8/gems/browsercms-3.0.0/public/javascripts/custom.js"
    assert_equal "/Ruby/lib/ruby/gems/1.8/gems/browsercms-3.0.0/public/javascripts/jquery-ui.js /Ruby/lib/ruby/gems/1.8/gems/browsercms-3.0.0/public/javascripts/custom.js", full_windows_path.gsub(pattern, "/")
    assert_equal "/Ruby/lib/ruby/gems/1.8/gems/browsercms-3.0.0/public/javascripts/jquery-ui.js /Ruby/lib/ruby/gems/1.8/gems/browsercms-3.0.0/public/javascripts/custom.js", Cms.scrub_path(full_windows_path)

    # not scrub if in middle of string
    full_windows_path = "c:/Ruby/lib/ruby/gems/1.8/gems:local/browsercms-3.0.0/public/javascripts/jquery-ui.js"
    assert_equal "/Ruby/lib/ruby/gems/1.8/gems:local/browsercms-3.0.0/public/javascripts/jquery-ui.js", full_windows_path.gsub(pattern, "/")
    assert_equal "/Ruby/lib/ruby/gems/1.8/gems:local/browsercms-3.0.0/public/javascripts/jquery-ui.js", Cms.scrub_path(full_windows_path)

  end
 
end
