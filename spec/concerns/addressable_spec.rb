require "minitest_helper"

class WannabeAddressable
  extend Cms::Concerns::CanBeAddressable
end

class CouldBeAddressable < ActiveRecord::Base;
end

# Mimics Attachments
class ManuallySetPath < ActiveRecord::Base
  is_addressable
end

class HasSelfDefinedPath < ActiveRecord::Base
  is_addressable(no_dynamic_path: true)
end

class IsAddressable < ActiveRecord::Base;
  is_addressable path: "/widgets"
end

class AnotherAddressable < ActiveRecord::Base;
  is_addressable path: "/another-addressables"
end

describe Cms::Concerns::Addressable do
  TESTING_TABLES = []

  def create_testing_table(name, &block)

    ActiveRecord::Base.connection.instance_eval do
      unless table_exists?(name)
        TESTING_TABLES << name
        create_table(name, &block)
        change_table name do |t|
          t.timestamps
        end
      end
    end
  end


  before do
    create_testing_table :is_addressables do |t|
      t.string :name
    end
    create_testing_table :another_addressables
    create_testing_table :manually_set_paths do |t|
      t.string :name
      t.string :path
    end
    create_testing_table :has_self_defined_paths do |t|
      t.string :path
    end
  end

  # Delete any testing tables we created, so next run can create them.
  MiniTest::Unit.after_tests() {
    ActiveRecord::Base.connection.instance_eval do
      TESTING_TABLES.each do |name|
        drop_table(name)
      end
    end
  }


  let(:addressable) { IsAddressable.new }
  describe '#is_addressable' do
    it "should have parent relationship" do
      WannabeAddressable.expects(:has_one)
      WannabeAddressable.expects(:after_save)
      WannabeAddressable.expects(:after_validation)
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

    it "should not require a slug unless a path was specified" do
      HasSelfDefinedPath.requires_slug?.must_equal false
    end

    it "should require a slug if a path was specified" do
      IsAddressable.requires_slug?.must_equal true
    end
  end

  describe "#layout" do
    it "should pull template from class" do
      class SpecifyingTemplate < ActiveRecord::Base
        is_addressable path: "/templates", template: 'subpage'
      end
      SpecifyingTemplate.layout.must_equal 'templates/subpage'
    end

    it "should use the default template if none is specified" do
      class UsingDefaultTemplate < ActiveRecord::Base
        is_addressable path: "/templates"
      end
      UsingDefaultTemplate.layout.must_equal 'templates/default'
    end

    it "should use config to override specified template" do
      class Dummy::OverrideSpecifiedTemplate < ActiveRecord::Base
        is_addressable template: 'subpage'
      end
      Rails.configuration.cms.expects(:templates).returns('dummy/override_specified_template' => "special")
      Dummy::OverrideSpecifiedTemplate.layout.must_equal 'templates/special'
    end
  end
  describe "#can_have_parent?" do
    it "should be false for non-addressable blocks" do
      WannabeAddressable.addressable?.must_equal false
    end

    it "should be true for addressable block" do
      IsAddressable.addressable?.must_equal true
    end
  end

  describe ".destroy" do
    it "should also delete the section node" do
      add = IsAddressable.create(slug: "coke", parent_id: root_section)
      before = Cms::SectionNode.count
      add.destroy
      (Cms::SectionNode.count - before).must_equal -1
    end
  end

  describe ".path" do
    it "should join #path and .slug" do
      addressable.expects(:slug).returns("one")
      addressable.path.must_equal "/widgets/one"
    end
  end

  describe ".slug" do
    it "should be nil for new objects" do
      addressable.slug.must_be_nil
    end

    it "setting it should mark the record as changed, so it will persist" do
      addressable.slug = 'new'
      addressable.changed?.must_equal true
    end

    it "should be unique for each class" do
      first = IsAddressable.create(slug: "first", parent_id: root_section)
      duplicate = IsAddressable.create(slug: "first", parent_id: root_section)

      duplicate.wont_be :valid?
      duplicate.section_node.errors[:slug].must_equal ["has already been taken"]
      duplicate.errors[:slug].must_equal duplicate.section_node.errors[:slug]
    end
  end

  describe "#descendants" do
    it "should return a list of all classes that are Addressable" do
      Cms::Concerns::Addressable.descendants.include?(IsAddressable).must_equal true
    end
  end

  describe "#classes_that_require_custom_routes" do
    it "should include addressable blocks but not pages/links/etc (i.e. already have controllers to display them)" do
      classes = Cms::Concerns::Addressable.classes_that_require_custom_routes
      classes.include?(IsAddressable).must_equal true
      classes.include?(Cms::Page).must_equal false
      classes.include?(Cms::Link).must_equal false
    end
  end

  describe "#with_slug" do

    it "return nil if no matching content exists" do
      IsAddressable.with_slug("non-existant").must_be_nil
    end

    it "should find content" do
      content = IsAddressable.create(slug: "coke", parent_id: root_section)
      found = IsAddressable.with_slug("coke")

      found.wont_be_nil
      found.must_equal content
    end

    it "should find correct type" do
      AnotherAddressable.create!(slug: "coke", parent_id: root_section)
      content = IsAddressable.create(slug: "coke", parent_id: root_section)
      found = IsAddressable.with_slug("coke")
      found.must_equal content

    end
  end

  describe "#update" do
    let(:saved_content) { IsAddressable.create! name: "Test" }
    it "should autosave changes to section_node" do
      saved_content.update(slug: "/change")
      saved_content.reload.section_node.slug.must_equal "/change"
    end
  end
  describe "#create" do
    it "should allow for both parent and slug to be saved" do
      f = IsAddressable.create!(parent_id: root_section.id, slug: "slug")
      f.section_node.slug.must_equal "slug"
    end

    # @bug These fail due to section_nodes getting persisted (create_section_node)
    it "#slug should be persisted" do
      IsAddressable.create!(parent_id: root_section.id, slug: "coke")
      Cms::SectionNode.where(node_type: 'IsAddressable').first.slug.wont_be_nil
    end

    it "should allow for both parent and slug to be saved in any order" do
      f = IsAddressable.create(slug: "slug", parent_id: root_section.id)
      f.section_node.slug.must_equal "slug"
    end

    describe "without assigning parent" do

      it "should create parent section if it doesn't exist'" do
        find_or_create_root_section
        content = IsAddressable.create! name: 'Hello'
        content.section_node.wont_be_nil
      end

      it "should create new section (with no parent) if root doesn't existing'" do
        content = IsAddressable.create! name: 'Hello'
        content.section_node.wont_be_nil
        content.parent.parent.must_be_nil
        content.parent.root?.must_equal false
      end
    end

    describe "with a manully set path" do
      it "should assign a parent if the class doesn't define a default path" do
        content = ManuallySetPath.create! path: "/must-be-set", parent: root_section
        content.parent.must_equal root_section
      end

      it "should not create a parent if the class doesn't define a default path" do
        content = ManuallySetPath.create! path: "/must-be-set"
        content.parent.must_be_nil
      end
    end
  end

  describe "#parent_id" do
    it "should return parent id" do
      addressable.parent = root_section
      addressable.parent_id.must_equal root_section.id
    end
  end

  describe "#calculate_path" do
    it "should generate the correct path given a slug" do
      IsAddressable.calculate_path("slug").must_equal "/widgets/slug"
    end
  end

  describe "#base_path" do
    it "should return base path where new records will be placed" do
      IsAddressable.base_path.must_equal "/widgets/"
    end
  end

  describe "#page_title" do
    it "should default to the name" do
      addressable.name = "Some Name"
      addressable.page_title.must_equal "Some Name"
    end

  end

  describe "#landing_page?" do
    it "a resource won't ever be the landing page for the section'" do
      addressable.landing_page?.must_equal false
    end
  end

end
