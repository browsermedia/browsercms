require "minitest_helper"

describe Cms::FormField do

  describe '.permitted_params' do
    it 'should return an array of fields' do
      [:form_id, :label, :field_type, :required, :position, :instructions, :default_value].each do |field|
        Cms::FormField.permitted_params.must_include field
      end
    end
  end

  describe '#form' do
    it "should be belongs_to" do
      form = Cms::Form.create!(name: "Testing")
      field = Cms::FormField.new(label: "Name")
      field.form = form
      field.save!
      field.form.wont_be_nil

      field.form_id.must_equal field.form.id
    end

    it "should trigger validation with duplicate names" do
      form = Cms::Form.create!(name: "Testing")
      field = Cms::FormField.new(label: "Name", form_id: form.id)
      field.save.must_equal true

      duplicate_field = Cms::FormField.new(label: "Name", form_id: form.id)
      duplicate_field.save.must_equal false
    end
  end

  describe '#name' do
    it "should return a symbol that can be used as the name for inputs" do
      field = Cms::FormField.create!(label: 'Name')
      field.name.must_equal :name
    end

    it "should underscore names" do
      field = Cms::FormField.create!(label: 'Full Name')
      field.name.must_equal :full_name
    end

    it "should not change after being saved even when the label is changed" do
      field = Cms::FormField.create!(label: 'Name')
      field.update(label: 'Full Name')
      field.name.must_equal :name
    end


  end

  describe "#options" do
    let(:field) { Cms::FormField.new(label: 'Title', field_type: 'text_field') }

    it "can disable the input" do
      field.options(disabled: true)[:disabled].must_equal(true)
      field.options(disabled: true)[:readonly].must_equal('readonly')
    end
    it "should provide as: for default cases" do
      field.options[:label].must_equal('Title')
    end

    it "includes as: for text_areas" do
      field.field_type = 'text_area'
      field.options[:as].must_equal(:text)
    end

    it "should include collection for :select" do
      field.choices = "A\nB\nC"
      field.options[:collection].must_equal ["A", "B", "C"]
      field.options[:prompt].must_equal true
    end

    it "set prompt to false for required selects" do
      field.choices = "A\nB\nC"
      field.required = true
      field.options[:collection].must_equal ["A", "B", "C"]
      field.options[:prompt].must_equal false
    end

    it "should return required false by default" do
      field.options[:required].must_equal false
    end
    it "should handle required fields" do
      field.required = true
      field.options[:required].must_equal true
    end

    it "should return hints" do
      field.instructions = "Fill this in"
      field.options[:hint].must_equal "Fill this in"
    end

    it "should return default value" do
      field.default_value = "My Default"
      field.options[:input_html][:value].must_equal "My Default"
    end


    it "should not return default value if the model has a value for the field" do
      field.valid? # Ensure name is set
      field.default_value = "My Default"
      entry = mock()
      entry.expects(:title).returns("some-value").at_least(0)
      field.options({entry: entry}).wont_include(:input_html)
    end


  end

  describe "#as" do
    it "should handle text_fields" do
      field = Cms::FormField.new(field_type: 'text_field')
      field.as.must_equal :string
    end

    it "should handle text_areas" do
      field = Cms::FormField.new(field_type: 'text_area')
      field.as.must_equal :text
    end

    it "should handle other random types" do
      field = Cms::FormField.new(field_type: 'random')
      field.as.must_equal :random
    end

    it "should handle select" do
      field = Cms::FormField.new(field_type: 'select')
      field.as.must_equal :select
    end
  end

  describe "#as_json" do
    let(:field) { Cms::FormField.new(label: 'Name') }
    it "should include #edit_path when being serialized" do
      field.edit_path = "/cms/form_fields/1/edit"
      json = JSON.parse(field.to_json)
      json["edit_path"].must_equal "/cms/form_fields/1/edit"
    end
  end
end
