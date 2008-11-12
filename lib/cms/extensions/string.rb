class String
  def indent(n=0)
    (" "*n.to_i) + self 
  end 
  def to_slug
    gsub(/\W+/, ' ').strip.downcase.gsub(/\ +/, '_')
  end  
end
