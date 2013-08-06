require "minitest_helper"

describe Product do
  describe 'Factory' do
    it 'should ' do
      p = FactoryGirl.create(:product)
      p.wont_be_nil
    end
  end
end
