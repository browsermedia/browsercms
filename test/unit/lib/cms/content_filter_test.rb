require "minitest_helper"

describe Cms::ContentFilter do

  let(:filter) { Cms::ContentFilter.new }
  describe '.filter' do
    it 'should strip html from titles' do
      result = filter.filter({title: "<p>Test</p>"})
      result.must_equal({title: "Test"})
    end

    it 'should not strip html from "content"' do
      unaltered_content = {"content" => "<p>Test</p>"}
      result = filter.filter(unaltered_content)
      result.must_equal(unaltered_content)
    end

    it 'should not strip html from :content' do
      unaltered_content = {content: "<p>Test</p>"}
      result = filter.filter(unaltered_content)
      result.must_equal(unaltered_content)
    end
    it 'should strip whitespace' do
      result = filter.filter({title: "Title\n"})
      result.must_equal({title: "Title"})
    end
  end
end
