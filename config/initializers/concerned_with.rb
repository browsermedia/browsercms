#See http://paulbarry.com/

class << ActiveRecord::Base

  # Macro to aid in refactoring large Models into concerns
  def concerned_with(*concerns)
    concerns.each do |concern|
      require_dependency "#{name.underscore}/#{concern}"
    end
  end

end