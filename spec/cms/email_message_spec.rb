require "minitest_helper"

describe Cms::EmailMessage do

  describe ".deliver!" do
    it "should assign mailbot if no sender was specified" do
      m = Cms::EmailMessage.create!(recipients: "test@example.com", subject: 'Test', body: 'Test') #Deliver! is side effect
      m.sender.must_equal Cms::EmailMessage.mailbot_address
    end
  end

  describe "#absolute_cms_url" do
    it "should return a url which points to the cms admin version of a page" do
      Rails.configuration.cms.expects(:site_domain).returns('www.example.com')
      url = Cms::EmailMessage.absolute_cms_url("/some-path")
      url.must_equal "http://cms.example.com/some-path"
    end

    it "should handle domains without www. subdomain" do
      Rails.configuration.cms.expects(:site_domain).returns('example.com')
      url = Cms::EmailMessage.absolute_cms_url("/some-path")
      url.must_equal "http://cms.example.com/some-path"
    end
  end

  describe "#normalize_domain" do
    it "should remove ports" do
      Cms::EmailMessage.normalize_domain("www.example.com:80").must_equal "example.com"
    end

    it "should strip the www. off domains" do
      Cms::EmailMessage.normalize_domain("www.example.com").must_equal "example.com"
    end

    it "should not alter other subdomains" do
      Cms::EmailMessage.normalize_domain("assets.example.com").must_equal "assets.example.com"
    end

    it "should not alter with no subdomain" do
      Cms::EmailMessage.normalize_domain("example.com").must_equal "example.com"
    end
  end
  describe "#mailbot_address" do
    it "should return a default address based on the site domain" do
      Rails.configuration.cms.expects(:mailbot).returns(:default)
      Rails.configuration.cms.expects(:site_domain).returns('www.example.com')
      Cms::EmailMessage.mailbot_address.must_equal 'mailbot@example.com'
    end

    it "should use mailbot in configuration if specified by project" do
      Rails.configuration.cms.expects(:mailbot).returns('staff@example.com')
      Cms::EmailMessage.mailbot_address.must_equal 'staff@example.com'
    end
  end
end