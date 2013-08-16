require "test_helper"


describe Cms::DefaultAccessible do
  describe '#permitted_params' do
    it 'should return most attributes' do
      permitted.must_include :name
      permitted.wont_include :id
    end
  end

  def permitted
    @permitted ||= Cms::HtmlBlock.permitted_params
  end

end
