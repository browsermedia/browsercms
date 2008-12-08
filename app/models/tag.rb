class Tag < ActiveRecord::Base
  has_many :taggings
  
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
    sizes = options.delete(:sizes) || 5
    sizes = sizes - 1
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
      t.size = ("%1.0f" % (t.count * 1.0 / divisor)).to_i + 1
    end
    
    tags
  end
  
end
