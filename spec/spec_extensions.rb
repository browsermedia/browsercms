def it_should_validate_presence_of(*one_or_more_fields)
  model_name = described_type.to_s.underscore
  one_or_more_fields.each do |field|
    it "should have errors on #{field.to_s.humanize.downcase} if it is not present" do
      model = send("new_#{model_name}", field => nil)
      model.should_not have(:no).errors_on(field)
    end
  end
end

def it_should_validate_numericality_of(*one_or_more_fields)
  model_name = described_type.to_s.underscore
  one_or_more_fields.each do |field|
    it "should have errors on #{field.to_s.humanize.downcase} if it is not a number" do
      model = send("new_#{model_name}", field => "FAIL")
      model.should have(1).error_on(field)
    end
  end
end

def it_should_validate_uniqueness_of(*one_or_more_fields)
  model_name = described_type.to_s.underscore
  one_or_more_fields.each do |field|
    it "should have errors on #{field.to_s.humanize.downcase} if it is already in use" do
      existing_model = send("create_#{model_name}")
      model = send("new_#{model_name}", field => existing_model.send(field))
      model.should have(1).error_on(field)
    end
  end
end

def it_should_assign(*variables)
  variables.each do |v|
    it "should assign the '#{v}' variable" do
      assigns[v].should_not be_nil
    end
  end
end

def it_should_be_successful
  it "should be successful" do
    response.should be_success
  end
end

def it_should_render(template)
  it "should render the '#{template}' template" do
    response.should render_template(template)
  end
end

class Object
  def should_meet_expectations(expectations)
    expectations.each do |method, expectation|
      send(method).should == expectation
    end
  end
end

class Array
  def to_table(*columns)
    lengths = columns.map{|m| m.to_s.length }
  
    each do |r|
      columns.each_with_index do |m, i|
        v = r.send(m)
        if v.to_s.length > lengths[i]
          lengths[i] = v.to_s.length
        end
      end
    end

    str = "  "
    columns.each_with_index do |m, i|
      str << "%#{lengths[i]}s" % m
      str << "  "
    end
    str << "\n  "

    columns.each_with_index do |m, i|
      str << ("-"*lengths[i])
      str << "  "
    end
    str << "\n  "
  
    each do |r|
      columns.each_with_index do |m, i|
        str << "%#{lengths[i]}s" % r.send(m)
        str << "  "
      end
      str << "\n  "      
    end
  
    str
  end   
end      