module CustomAssertions
  def assert_file_exists(file_name, message=nil)
    assert File.exists?(file_name), 
      (message || "Expected File '#{file_name}' to exist, but it does not")
  end  

  def assert_valid(object, message=nil)
    assert object.valid?, 
      (message || 
        "#{object.class.name.titleize} is not valid, but it should be")
  end

  def assert_not_valid(object, message=nil)
    assert !object.valid?, 
      (message || 
        "#{object.class.name.titleize} is valid, but it should not be")
  end

  def assert_has_error_on_base(object, error_message=nil, message=nil)
    assert_has_error_on(object, :base, error_message, message)
  end

  def assert_has_error_on(object, field, error_message=nil, message=nil)
    e = object.errors.on(field.to_sym)
    if e.is_a?(String)
      e = [e]
    elsif e.nil?
      e = []
    end
    if error_message
      assert e.include?(error_message), 
        "Expected errors on #{field} to include '#{error_message}', but it is [#{e.map{|err| "'#{err}'"}.join(", ")}]"
    else
      assert !e.empty?, "Expected errors on #{field}, but there are none"
    end
  end

  def assert_properties(object, properties)
    properties.each do |property, expected_value|
      assert_equal expected_value, object.send(property), "Expected '#{property}' to be '#{expected_value}'"
    end
  end

  def assert_incremented(original_value, new_value)
    assert_equal original_value + 1, new_value, "Expected value to be incremented"
  end

  def assert_decremented(original_value, new_value)
    assert_equal original_value - 1, new_value, "Expected value to be decremented"
  end

  # We are overriding the regular assert_raise because we want
  # a string to check the error message, and a class to check the type
  def assert_raise(exception_class_or_message, &block)
    begin
      yield
    rescue Exception => e
      if exception_class_or_message.is_a?(String)
        assert_equal exception_class_or_message, e.message
      else
        assert exception_class_or_message === e, 
          "Expected exception to be #{exception_class_or_message}, but is is #{e.class}"
      end
      return
    end
    flunk "Expected exception #{exception_class_or_message.is_a?(String) ? "'#{exception_class_or_message}'" : exception_class_or_message} to be raised, but nothing was raised"
  end    
end