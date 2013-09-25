module Cms
  class EmailMessage < ActiveRecord::Base

    extend DefaultAccessible
    extend Cms::DomainSupport

    scope :undelivered, -> { where("delivered_at is null") }
    validates_presence_of :recipients
    after_create :deliver_now

    def delivered?
      !!delivered_at
    end

    def self.deliver!
      # Send all messages, 100 at a time
      undelivered.all(:limit => 100).each do |m|
        m.deliver!
      end
    end

    # Returns a clean (non-www prefixed) domain name
    def self.normalize_domain(domain)
      normalized = domain =~ /^www/ ? domain.sub(/^www\./, "") : domain
      # Strip the port
      URI.parse("http://#{normalized}").host
    end

    # Converts a relative path to a path in the CMS. Used for creating a links to internal pages in the body of emails.
    #
    # @param [String] path A relative path (i.e. /cms/your-page)
    # @return [String] (i.e http://cms.example.com/cms/your-page)
    def self.absolute_cms_url(path)
      host = normalize_domain(Rails.configuration.cms.site_domain)
      "http://#{cms_domain_prefix}.#{host}#{path}"
    end

    # Returns a default address that mail will be sent from. (i.e. mailbot@example.com)
    def self.mailbot_address
      address = Rails.configuration.cms.mailbot
      if address == :default
        host = normalize_domain(Rails.configuration.cms.site_domain)
        "mailbot@#{host}"
      else
        address
      end

    end

    #TODO: Take this out when we have an email queue processor
    def deliver_now
      deliver!
    end

    def deliver!
      return false if delivered?
      self.sender = self.class.mailbot_address if self.sender.blank?
      Cms::EmailMessageMailer.email_message(self).deliver
      update_attributes(:delivered_at => Time.now)
    end

  end
end