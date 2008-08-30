#See http://paulbarry.com/articles/2008/08/30/concerned-with-skinny-controller-skinny-model
class << ActiveRecord::Base
  def concerned_with(*concerns)
    concerns.each do |concern|
      require_dependency "#{name.underscore}/#{concern}"
    end
  end
end