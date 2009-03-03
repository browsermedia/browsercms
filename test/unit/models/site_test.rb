require File.join(File.dirname(__FILE__), '/../../test_helper')

class SiteTest < ActiveSupport::TestCase

  def test_does_not_allow_duplicate_names
    Factory(:site, :domain => "test.com")
    @site = Factory.build(:site, :domain => "test.com")
    assert !@site.valid?
    assert_has_error_on @site, :domain, "has already been taken"
  end

  def test_remove_www_from_front_when_saving
    @site = Factory(:site, :domain => "www.test.com")
    assert_equal "test.com", @site.domain
  end
  
  def test_should_remove_www_from_front_when_saving_preserving_sub_domains
    @site = Factory(:site, :domain => "www.foo.test.com")
    assert_equal "foo.test.com", @site.domain
  end
  
  def test_should_not_remove_sub_domain_from_domain_when_saving
    @site = Factory(:site, :domain => "foo.test.com")
    assert_equal "foo.test.com", @site.domain
  end
  
  def test_should_make_the_first_the_default
    @first = Site.default.first
    @second = Factory(:site)
    assert @first.the_default?
    assert !@second.the_default?
  end
  
  def test_change_the_default
    @first = Factory(:site)
    @second = Factory(:site, :the_default => true)
    reset(:first, :second)
    assert !@first.the_default?
    assert @second.the_default?
  end
  
  def test_find_by_domain
    @default = Site.default.first
    @example = Factory(:site, :domain => "test.com")
    assert_equal @example, Site.find_by_domain("test.com")
    assert_equal @example, Site.find_by_domain("www.test.com")
    assert_equal @default, Site.find_by_domain("whatever.com")
  end
  
end