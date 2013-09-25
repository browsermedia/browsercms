require "minitest_helper"

describe CmsTextFieldInput do

  def text_input(attribute_name, object)
    form_builder = mock()
    form_builder.expects(:object).returns(object).at_least_once
    CmsTextFieldInput.new(form_builder, attribute_name, attribute_name, :string)
  end

  describe 'should_autogenerate_slug?' do
    it 'should generate slug when object is new' do
      input = text_input(:name, Cms::Form.new)
      input.send(:should_autogenerate_slug?, :name).must_equal true
    end

    it 'should not generate slug for saved object with a name/slug' do
      input = text_input(:name, Cms::Form.create!(name: "Name", slug: "/name"))
      input.send(:should_autogenerate_slug?, :name).must_equal false
    end

    it 'should generate slug when object has blank name and slug' do
      input = text_input(:name, Cms::Form.create!(name: "", slug: ""))
      input.send(:should_autogenerate_slug?, :name).must_equal true
    end
  end
end
