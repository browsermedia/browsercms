require_relative '../../test_helper'

class LinkTest < ActiveSupport::TestCase
  def test_create
    assert Factory.build(:link).valid?
    assert !Factory.build(:link, :name => "").valid?
  end
end