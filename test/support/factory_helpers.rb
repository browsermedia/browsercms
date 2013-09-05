module FactoryHelpers

  def new_attachment(name="spreadsheet", path=nil)
    {"0" => {
        :data => mock_file,
        :section_id => root_section,
        :data_file_path => path,
        :attachment_name => name}}
  end

  # Nested Attributes are pretty messy to build directly in code, and FactoryGirl isn't really appropriate since we need to
  #  test mass assignment.
  # Create a single Attachment with some default values.
  #
  # @param options
  # @options :path [String]
  # @options :name [String]
  def attachments_hash(options={})
    defaults = {
        :attachment_name => "file",
        :path => ""
    }
    defaults.merge!(options)
    {:attachments_attributes =>
         {"0" => {
             :data => mock_file,
             :section_id => root_section,
             :data_file_path => defaults[:path],
             :attachment_name => defaults[:name]}}
    }
  end


  def find_or_create_root_section
    root = Cms::Section.root.first
    unless root
      # This constructor matches how seed data is set up.
      root = FactoryGirl.create(:root_section)
    end
    root
  end

  def root_section
    find_or_create_root_section
  end

  def given_there_is_a_sitemap
    root = find_or_create_root_section
    root.allow_groups = :all
  end

  def given_there_is_a_guest_group
    group_type = Cms::GroupType.guest.first
    unless group_type
      group_type = Cms::GroupType.create!(:name => "Guest", :guest => true)
    end

    guest_group = Cms::Group.guest
    unless guest_group
      guest_group = Cms::Group.create!(:name => 'Guest', :code => Cms::Group::GUEST_CODE, :group_type => group_type)
    end
    guest_group
  end

  alias :given_a_guest_group_exists :given_there_is_a_guest_group

  # Creates a sample uploaded JPG file with binary data.
  def mock_file(options = {})
    file_upload_object({:original_filename => "foo.jpg", :content_type => "image/jpeg"}.merge(options))
  end

  def mock_text_file(options = {})
    file_upload_object({:original_filename => "sample_upload.txt", :content_type => "text/plain"}.merge(options))
  end

  def create_or_find_permission_named(name)
    Cms::Permission.named(name).first || FactoryGirl.create(:permission, :name => name)
  end

  # Creates a TempFile attached to an uploaded file. Used to test attachments
  def file_upload_object(options)
    Cms::MockFile.new_file(options[:original_filename], options[:content_type])
  end

  def create_admin_user(attrs={})
    FactoryGirl.create(:cms_admin, {:login => "cmsadmin"}.merge(attrs))
  end

  def given_there_is_a_cmsadmin
    create_admin_user
  end
end