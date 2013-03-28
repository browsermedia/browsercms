require "minitest_helper"

describe 'Cms::AddressablePath' do
  describe 'pages' do
    it 'have section nodes' do
      p = create(:page)
      p.node.wont_be_nil
    end

  end
  
  describe 'html_blocks' do
    it "should be addressable" do
      b = create(:html_block)
      b.parent = find_or_create_root_section
      b.node.wont_be_nil
    end
  end
end
