class TagCloudPortlet < Cms::Portlet
  
  def self.default_sizes
    (0..4).map{|n| "size-#{n}" }.join(" ")
  end
  
  def render
    @sizes = self.sizes.blank? ? self.class.default_sizes : self.sizes
    @limit = self.limit.blank? ? 50 : self.limit
    @cloud = Cms::Tag.cloud(:sizes => @sizes.size, :limit => @limit)
  end
    
end
