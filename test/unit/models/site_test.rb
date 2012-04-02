require 'test_helper'

class SiteTest < ActiveSupport::TestCase

  def test_does_not_allow_duplicate_names
    create(:site, :domain => "test.com")
    @site = build(:site, :domain => "test.com")
    assert !@site.valid?
    assert_has_error_on @site, :domain, "has already been taken"
  end

  def test_remove_www_from_front_when_saving
    @site = create(:site, :domain => "www.test.com")
    assert_equal "test.com", @site.domain
  end
  
  def test_should_remove_www_from_front_when_saving_preserving_sub_domains
    @site = create(:site, :domain => "www.foo.test.com")
    assert_equal "foo.test.com", @site.domain
  end
  
  def test_should_not_remove_sub_domain_from_domain_when_saving
    @site = create(:site, :domain => "foo.test.com")
    assert_equal "foo.test.com", @site.domain
  end
  
  def test_should_make_the_first_the_default
    @first = create(:site)
    @second = create(:site)
    assert @first.the_default?
    assert !@second.the_default?
  end
  
  def test_change_the_default
    @first = create(:site, :the_default=>false)
    @second = create(:site, :the_default => true)
    reset(:first, :second)
    assert !@first.the_default?
    assert @second.the_default?
  end
  
  def test_find_by_domain
    @default =     @first = create(:site, :the_default=>true)
    @example = create(:site, :domain => "test.com")
    assert_equal @example, Cms::Site.find_by_domain("test.com")
    assert_equal @example, Cms::Site.find_by_domain("www.test.com")
    assert_equal @default, Cms::Site.find_by_domain("whatever.com")
  end
  
end
