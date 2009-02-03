class Tag < ActiveRecord::Base
  has_many :taggings
  
  validates_uniqueness_of :name
  
  attr_accessor :size
  
  # Returns an array of tags with a count attribute
  def self.counts(options={})
    with_scope(:find => { 
        :select => "tags.id, tags.name, count(*) as count", 
        :joins => :taggings, 
        :group => "id, name", 
        :order => "count desc" }) do
      all(options)
    end
  end
  
  # Returns an array of tags with a size attribute
  # This takes the same arguments as find, plus the additional `:sizes` option,
  # which contols the number of sizes the tag cloud will have.
  # The default number of sizes is 5.
  def self.cloud(options={})
    sizes = (options.delete(:sizes) || 5) - 1
    sizes = 1 if sizes < 1
    tags = counts(options)
    return [] if tags.blank?
    
    min = nil
    max = nil
    tags.each do |t|
      t.count = t.count.to_i
      min = t.count if (min.nil? || t.count < min)
      max = t.count if (max.nil? || t.count > min)
    end

    divisor = ((max - min) / sizes) + 1
    tags.each do |t|
      t.size = ("%1.0f" % (t.count * 1.0 / divisor)).to_i
    end
    
    tags
  end
  
  def tagging_count
    taggings.count
  end
  
  def self.columns_for_index
    [ {:label => "Name", :method => :name, :order => "name" },
      {:label => "Usages", :method => :tagging_count },
      {:label => "Updated On", :method => :updated_on_string, :order => "updated_at"}  ]
  end  
  
  def renderer(tag)
    lambda do
      render :partial => 'cms/tags/tag', :locals => {:tag => tag}
    end

  end  
  
end
