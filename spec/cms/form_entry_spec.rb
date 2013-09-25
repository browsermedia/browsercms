require "minitest_helper"

def expect_nonrequired_fields(form)
  mock_field = mock()
  mock_field.expects(:required?).returns(false).at_least_once
  form.expects(:field).returns(mock_field).at_least_once
end

describe Cms::FormEntry do
  let(:entry) { Cms::FormEntry.new }

  def contact_form
    return @form if @form
    @form = Cms::Form.new
    @form.expects(:field_names).returns([:name, :email]).at_least_once
    @form
  end

  let(:contact_form_entry) { Cms::FormEntry.for(contact_form) }

  describe '.ish' do
    it "should create object with class_eval'd methods'" do
      entry = Cms::FormEntry.ish {
        def hello
        end
      }
      entry.respond_to?(:hello).must_equal true
    end
  end

  describe '.new' do
    it "should create a entry with no accessors" do
      entry.wont_be_nil
    end
  end

  def form_with_fields(fields)
    form = Cms::Form.new
    fields.each do |f|
      form.fields << Cms::FormField.create!(f)
    end
    form.save!
    form
  end

  describe '#valid?' do
    it "should return false if required fields are not filled in" do
      form = form_with_fields([{label: "Name", required: true}])

      form_entry = Cms::FormEntry.for(form)
      form_entry.valid?.must_equal false
    end
  end

  describe '#data_columns' do
    it 'should return nil for unset attributes' do
      entry.data_columns['name'].must_be_nil
    end

    it 'should allow arbitrary access' do
      entry.data_columns['name'] = 'Stan'
      entry.save!
      entry.reload.data_columns['name'].must_equal 'Stan'
    end

    it "should not share accessors across forms" do
      [:name, :email].each do |field|
        contact_form_entry.respond_to?(field).must_equal true
      end
      registration_form = Cms::Form.new
      registration_form.expects(:field_names).returns([:first_name, :last_name]).at_least_once
      expect_nonrequired_fields(registration_form)
      registration_entry = Cms::FormEntry.for(registration_form)

      [:first_name, :last_name].each do |field|
        registration_entry.respond_to?(field).must_equal true
      end
      [:name, :email].each do |field|
        registration_entry.respond_to?(field).must_equal false
      end
    end

    it "should coerce fields to their proper type" do
      entry.data_columns[:age] = 1
      entry.save!

      entry.reload.data_columns[:age].must_be_instance_of Fixnum
    end
  end

  describe '#prepare' do
    it "should return a copy of a FormEntry with the same data and accessors" do
      form = Cms::Form.create!(name: "Contact")
      form.fields << Cms::FormField.create!(label: 'Name', required: true)
      form.save!

      entry = Cms::FormEntry.for(form)
      entry.name = "Filled in"
      entry.save!

      e = entry.enable_validations
      e.id.must_equal entry.id
      e.new_record?.must_equal false
      e.name.must_equal "Filled in"
      e.name = ""
      e.valid?.must_equal false
    end
  end

  describe '.for' do
    it "should create FormEntry with accessors for backing form" do
      form = Cms::Form.new
      form.expects(:field_names).returns([:name, :email]).at_least_once
      entry = Cms::FormEntry.for(form)

      entry.name = "Hello"
      entry.name.must_equal 'Hello'
      entry.data_columns[:name].must_equal 'Hello'
      entry.respond_to? :name
      entry.respond_to? :email
    end

    it "should connect form to entry" do
      form = Cms::Form.new
      entry = Cms::FormEntry.for(form)

      entry.form.must_equal form
    end
  end

  describe '#form' do

    it "should be a belongs_to association" do
      form = Cms::Form.create!(name: "Contact")
      contact_form_entry = Cms::FormEntry.new(form: form)
      contact_form_entry.save!

      contact_form_entry = Cms::FormEntry.find(contact_form_entry.id)
      contact_form_entry.form.must_equal form
    end

  end

  describe '#permitted_params' do
    it "should respond" do
      contact_form_entry.respond_to?(:name).must_equal true
    end

    it "should return all the fields for the specific form" do
      contact_form_entry.permitted_params.must_equal [:name, :email]
    end
  end
end
