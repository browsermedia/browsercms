require "minitest_helper"

describe 'Cms::AddressablePath' do
  describe 'pages' do
    it 'have section node' do
      p = create(:page)
      p.section_node.wont_be_nil
    end
  end
end
