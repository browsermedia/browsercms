require "minitest_helper"

describe 'Publishing' do
  let(:block) { create(:html_block, name: "Published Version") }
  let(:new_block) { build(:html_block) }
  let(:draft_block) { create(:html_block, as: :draft) }
  let(:invalid_params) { {} }
  let(:valid_params) { {name: "Any Name"} }
  describe '.publish_on_save' do
    it "should be true for new objects" do
      n = Cms::HtmlBlock.new
      n.publish_on_save.must_equal true
    end
  end

  describe '#create' do
    it "should publish the content" do
      block = Cms::HtmlBlock.create(valid_params)
      block.must_be_published
    end

    it "should not save with invalid attributes" do
      block = Cms::HtmlBlock.create(invalid_params)
      block.persisted?.must_equal false
    end
  end

  describe '#create!' do
    it "should publish the content" do
      b = Cms::HtmlBlock.create!(valid_params)
      b.must_be_published
    end

    it "should throw an exception for invalid attributes" do
      proc { Cms::HtmlBlock.create!(invalid_params) }.must_raise(ActiveRecord::RecordNotSaved)
    end
  end

  describe '.as=' do
    it "can specify to save as draft" do
      new_block.as = :draft
      new_block.save!

      new_block.published?.wont_equal true
    end

    it "can be called during mass assignment" do
      block = Cms::HtmlBlock.create(name: "Mass", as: :draft)
      block.published?.wont_equal true
    end
  end
  describe '.publish' do
    it "should not publish a new block" do
      block = Cms::HtmlBlock.new(valid_params)
      ActiveSupport::Deprecation.silence do
        block.publish.must_equal false
      end
      block.persisted?.must_equal false
    end

    it "should publish a draft block, without creating a version" do
      draft_block.publish.must_equal true
      draft_block.must_be_published
      draft_block.versions.size.must_equal 1
    end

    it "should return false if there was no draft copy to publish" do
      block.publish.must_equal false
      block.must_be_published
    end

    it "should not persist changes as a side effect" do
      draft_block.name = "Another Name"
      draft_block.publish
      draft_block.changed?.must_equal true
      draft_block.live_version.name.wont_equal "Another Name"
    end
  end

  describe '.publish!' do
    it "should not save new blocks." do
      block = Cms::HtmlBlock.new(valid_params)
      ActiveSupport::Deprecation.silence do
        block.publish!.must_equal false
      end
      block.persisted?.must_equal false
    end

    describe "with an existing draft" do
      it "should mark that draft as published" do
        block = block_with_draft
        block.publish!.must_equal true
        block.versions.size.must_equal 2
        block.must_be_published
      end
    end
  end

  describe '.save' do
    it 'should save and publish the content' do
      block.name = "Version 2"
      block.save.must_equal true
      find_latest_block.name.must_equal "Version 2"
      find_latest_block.version.must_equal 2
    end
  end

  describe '.save_draft' do
    it "should save a draft of the content" do
      block.name = "Draft Version"
      block.save_draft
      find_latest_block.name.must_equal "Published Version"
    end
  end

  describe '.published' do
    before do
      block
      draft_block
    end

    it "should find published blocks" do
      Cms::HtmlBlock.published.to_a.must_equal [block]
    end
  end

  describe '.unpublished' do
    before do
      block
      draft_block.publish!
      draft_block.update_attributes(name: 'Make draft', as: :draft)
    end

    it "should find unpublished blocks" do
      Cms::HtmlBlock.unpublished.to_a.must_equal [draft_block]
    end

  end
  # Creates and returns a block with a single draft version.
  def block_with_draft
    block_with_draft = create(:html_block)
    block_with_draft.update_attributes(name: "Draft Copy", as: :draft)
    block_with_draft.versions.size.must_equal 2
    block_with_draft
  end

  def find_latest_block
    Cms::HtmlBlock.find(block.id)
  end
end
