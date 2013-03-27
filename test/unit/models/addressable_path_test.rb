require "minitest_helper"

describe 'Cms::AddressablePath' do
  describe 'pages' do
    it 'have section nodes' do
      p = create(:page)
      p.section_node.wont_be_nil
    end
  end
  
  describe 'html_blocks' do
    #it "should be addressable"
  end
end
