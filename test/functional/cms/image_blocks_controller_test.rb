require 'test_helper'

module Cms

  # As these tests break, move them to features/content_blocks/manage_image_blocks.feature
  class ImageBlocksControllerTest < ActionController::TestCase
    include Cms::ControllerTestHelper

    def setup
      given_a_site_exists
      login_as_cms_admin
      given_there_is_a_sitemap
      given_there_is_a_content_type(Cms::ImageBlock)
    end

    # Move this to features/content_blocks/manage_images.feature (once it works)
    def test_revert_to
      @image = create(:image_block,
                       :parent => root_section,
                       :attachment_file => mock_file(:original_filename => "version1.txt"),
                       :attachment_file_path => "test.jpg")
      @image.file.data_file_path = '/version2.txt'
      @image.save!

      #@image.attachment_attributes = update_attributes(:attachment_file => mock_file(:original_filename => "version2.txt"), :publish_on_save => true)
      reset(:image)

      assert @image.live?
      assert_equal 2, @image.version
      assert_equal 2, @image.attachment_version
      assert_equal "v2", File.read(@image.attachment.full_file_location)

      put :revert_to, :id => @image.id, :version => "1"
      reset(:image)

      assert_redirected_to @image
      assert !@image.live?
      @draft_image = @image.as_of_draft_version
      assert_equal 2, @image.version
      assert_equal 2, @image.attachment_version
      assert_equal 3, @draft_image.version
      assert_equal 3, @draft_image.attachment_version
      assert_equal "v2", File.read(@image.attachment.full_file_location)
      assert_equal "v1", File.read(@draft_image.attachment.full_file_location)
    end

  end

end