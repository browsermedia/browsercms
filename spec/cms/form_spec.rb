require "minitest_helper"

describe Cms::Form do

  let(:form) { Cms::Form.new(name: 'Contact Us') }
  describe '.create!' do
    it "should create a new instance" do
      form.save!
      form.name.must_equal "Contact Us"
      form.persisted?.must_equal true
    end

    it "should create a slug when created " do
      form.slug = "/contact-us"
      form.save!
      form.reload.section_node.wont_be_nil
      form.section_node.slug.must_equal "/contact-us"
    end

    it "should assign parent with created" do
      form.save!
      form.parent.wont_be_nil
      form.section_node.slug.must_equal
    end

  end

  describe '#update' do
    let(:saved_form) { Cms::Form.create! }
    it "should update slug" do
      saved_form.update({name: 'New', slug: '/about-us'}).must_equal true
      saved_form.reload.section_node.slug.must_equal '/about-us'
    end
  end

  describe '#show_text?' do
    it "should return true with the :show_text confirmation behavior" do
      form.confirmation_behavior = :show_text
      form.save!
      form.reload.show_text?.must_equal true
    end
  end

  describe "#valid?" do
    it "should not allow improperly formatted notification emails (requires @)" do
      form.notification_email = "valid@example.com"
      form.must_be :valid?

      form.notification_email = "not-valid-example.com"
      form.wont_be :valid?

      form.notification_email = ""
      form.must_be :valid?
    end
  end

  describe '#fields' do
    it "should save a list of fields" do
      field = Cms::FormField.new(label: "Event Name", field_type: :string)
      form.fields << field
      form.save!

      form.reload.fields.size.must_equal 1
      field.persisted?.must_equal true
    end

    it "should set error on :base when there are duplicate fields" do
      form.fields << Cms::FormField.create(label: 'Name')
      form.fields << Cms::FormField.new(label: 'Name')
      form.valid?.must_equal false
      form.errors[:base].size.must_equal 1
      form.errors[:base].must_include "Labels can only be used once per form."
    end

    describe "ordering" do
      def form_with_fields(field_labels=[])
        return @form_with_fields if @form_with_fields
        @form_with_fields = Cms::Form.new
        field_labels.each do |label|
          @form_with_fields.fields << Cms::FormField.create(label: label)
        end
        @form_with_fields.save!
        @form_with_fields
      end

      it "should add fields in position order" do
        f = form_with_fields(['Name', 'Address'])
        f.fields.first.position.must_equal 1
        f.fields.last.position.must_equal 2
      end

      it "are orderable" do
        form = form_with_fields(['Name', 'Address'])
        form.fields.last.move_to_top
        form.reload
        form.fields.first.label.must_equal "Address"
      end
    end

  end

  describe '#field_names' do

    it "should return a list of the field names as symbols" do
      form = Cms::Form.new
      form.fields << Cms::FormField.new(label: 'Name')
      form.fields << Cms::FormField.new(label: 'Email')
      form.save!
      form.field_names.must_equal [:name, :email]
    end
  end

  describe '#required?' do

    def form_with_name_field
      form = Cms::Form.new
      form.fields << Cms::FormField.new(label: 'Name', required: true)
      form.fields << Cms::FormField.new(label: 'Email')
      form.save!
      form
    end

    it "should return true for required fields" do
      form_with_name_field.required?(:name).must_equal(true)
    end
    it "should returns nil for missing fields" do
      form_with_name_field.required?(:email).must_equal(false)
    end
  end
end
