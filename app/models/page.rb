class Page < ActiveRecord::Base
  
  acts_as_content_page
  
  belongs_to :section
  belongs_to :template, :class_name => "PageTemplate"
  has_many :connectors, :conditions => 'page_version = #{version}', :order => "position"
  
  after_update :copy_connectors!
  before_validation :append_leading_slash_to_path
  before_destroy :delete_connectors
  
  validates_presence_of :section_id
  validates_uniqueness_of :path
  
  #Valid options:
  #  except = An array of connector ids not to copy
  #  from_version = Which page version to copy from, default to version-1
  #    also you can set an instance variable @_copy_connectors_from_version,
  #    which will be used if there is no from_version option
  def copy_connectors!(options={})
    page_version = options[:from_version] || @_copy_connectors_from_version || (version-1)
    conditions = ['page_id = ? and page_version = ?', id, page_version]
    
    if options[:except]
      conditions.first << ' and id not in(?)'
      conditions << options[:except]
    end
    
    Connector.all(:conditions => conditions, :order => "page_id, page_version, container, position").each do |c|
      attrs = c.attributes.without("id", "created_at", "updated_at")
      con = Connector.new(attrs)
      con.page_version = version
      con.save!
    end
  end
  
  def add_content_block!(content_block, container)
    transaction do
      create_new_version!
      copy_connectors!
      Connector.create!(:page_id => id, 
        :page_version => version, 
        :content_block => content_block, 
        :content_block_version => content_block.version,
        :container => container)
    end
  end
  
  def destroy_connector(connector)
    transaction do
      create_new_version!
      copy_connectors!(:except => [connector.id])
      reload
      connector.freeze
    end
  end

  #This is done to let copy_connectors! know which version to pull from
  #copy_connectors! will get called later as an after_update callback
  alias_method :original_revert_to, :revert_to
  def revert_to(version, user)
    @_copy_connectors_from_version = version
    original_revert_to(version, user)
  end
    
  def delete_connectors
    Connector.delete_all "page_id = #{id}"
  end
  
  def append_leading_slash_to_path
    if path.blank?
      self.path = "/"
    elsif path[0,1] != "/"
      self.path = "/#{path}"
    end
  end
  
  def move_to(section, user)
    self.section = section
    self.updated_by_user = user
    save
  end
  
  def layout
    template ? template.file_name : nil
  end

  def template_name
    template ? template.name : nil
  end
  
end