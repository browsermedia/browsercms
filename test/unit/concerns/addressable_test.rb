require "minitest_helper"

class WannabeAddressable
  extend Cms::Concerns::CanBeAddressable
end

class CouldBeAddressable < ActiveRecord::Base; end

class HasSelfDefinedPath < ActiveRecord::Base
  is_addressable(no_dynamic_path: true)
  attr_accessible :path
end

class IsAddressable < ActiveRecord::Base;
  is_addressable path: "/widgets"
end

describe Cms::Concerns::Addressable do

  def create_testing_table(name, &block)
    ActiveRecord::Base.connection.instance_eval do
      drop_table(name) if table_exists?(name)
      create_table(name, &block)
    end
  end

  before :all do
    create_testing_table :is_addressables do |t|
      t.string :slug
    end
    create_testing_table :has_self_defined_paths do |t|
      t.string :path
    end
  end

  describe '#is_addressable' do
    it "should have parent relationship" do
      WannabeAddressable.expects(:attr_accessible).with(:parent)
      WannabeAddressable.expects(:has_one)
      WannabeAddressable.is_addressable
      WannabeAddressable.new.must_respond_to :parent
    end

    it "should be added to all ActiveRecord classes" do
      CouldBeAddressable.must_respond_to :is_addressable
    end

    it "provide default path where instances will be placed" do
      IsAddressable.path.must_equal "/widgets"
    end

    it "should allow :path to be ActiveRecord::Base attribute" do
      p = HasSelfDefinedPath.new(path: "/custom")
      p.path.must_equal "/custom"
    end
  end

  describe "#path" do

    it "should " do
      content = IsAddressable.new
      content.slug = "one"
      content.path.must_equal "/widgets/one"
    end
  end

end
