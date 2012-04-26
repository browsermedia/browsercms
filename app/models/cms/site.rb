module Cms
  class Site < ActiveRecord::Base

    attr_accessible :name, :domain

    validates_uniqueness_of :domain

    before_validation :remove_www

    before_save :unset_default
    after_save :set_default

    scope :default, :conditions => {:the_default => true}

    def self.find_by_domain(domain)
      d = domain.clone
      strip_www!(d)
      if site = first(:conditions => {:domain => d})
        site
      else
        default.first
      end
    end

    def self.strip_www!(d)
      return unless d
      d.sub!(/\Awww./, '')
    end

    def remove_www
      self.class.strip_www!(domain)
    end

    def unset_default
      self.class.update_all(["the_default = ?", false]) if the_default
    end

    def set_default
      if self.class.default.count < 1
        update_attribute(:the_default, true)
      end
    end

  end
end