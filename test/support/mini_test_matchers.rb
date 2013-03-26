require 'minitest/autorun'
module MiniTest::Assertions
  def assert_is_published(block)
    assert block.published?, "Expected #{block} to be published."
    klass = block.class
    most_recent_entity = klass.find(block.id)
    assert most_recent_entity.published?, "Expected most recent version '#{most_recent_entity}' to be published."
  end
end
Cms::Behaviors::Publishing.infect_an_assertion :assert_is_published, :must_be_published, :only_one_argument
