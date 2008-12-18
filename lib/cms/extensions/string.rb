class String
  def indent(n=0)
    (" "*n.to_i) + self 
  end 
  def to_slug
    gsub(/\W+/, ' ').strip.downcase.gsub(/\ +/, '-')
  end  
  def pluralize(count=nil)
    count == 1 ? self : ActiveSupport::Inflector.pluralize(self)
  end
end
