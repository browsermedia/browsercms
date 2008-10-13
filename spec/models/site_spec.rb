require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Site do
  it "should not allow duplicate domains" do
    create_site(:domain => "example.com")
    @site = new_site(:domain => "example.com")
    @site.should_not be_valid
  end
  
  it "should remove www. from the front when saving" do
    @site = create_site(:domain => "www.example.com")
    @site.domain.should == "example.com"
  end

  it "should remove www. from the front when saving, preserving sub-domains" do
    @site = create_site(:domain => "www.foo.example.com")
    @site.domain.should == "foo.example.com"
  end

  it "should not remove sub-domain from the domain when saving" do
    @site = create_site(:domain => "foo.example.com")
    @site.domain.should == "foo.example.com"
  end
  
  it "should make the first the default" do
    @first = create_site
    @second = create_site
    @first.should be_the_default
    @second.should_not be_the_default    
  end
  
  it "should be able to update which site is the default" do
    @first = create_site
    @second = create_site(:the_default => true)
    reset(:first, :second)
    @first.should_not be_the_default
    @second.should be_the_default    
  end
  
  describe ".find_by_domain" do
    before do
      @default = create_site(:domain => "mysite.com")
      @example = create_site(:domain => "example.com")
    end
    it "should be able to find by the site without the www" do
      Site.find_by_domain("example.com").should == @example
    end
    it "should be able to find by the site with the www" do
      Site.find_by_domain("www.example.com").should == @example
    end
    it "should fall back to the default site if no match" do
      Site.find_by_domain("whatever.com").should == @default
    end
  end  
  
end
