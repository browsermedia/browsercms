module Cms
  class EmailMessage < ActiveRecord::Base

    include DefaultAccessible

    scope :undelivered, :conditions => "delivered_at is null"
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

    #TODO: Take this out when we have an email queue processor
    def deliver_now
      deliver!
    end

    def deliver!
      return false if delivered?
      Cms::EmailMessageMailer.email_message(self).deliver
      update_attributes(:delivered_at => Time.now)
    end

  end
end