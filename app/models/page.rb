class Page < ActiveRecord::Base
  
  acts_as_content_page
  
  belongs_to :section
  belongs_to :template, :class_name => "PageTemplate"
  has_many :connectors, :conditions => 'page_version = #{version}', :order => "position"
  
  after_update :copy_connectors
  before_validation :append_leading_slash_to_path
  before_destroy :delete_connectors
  
  validates_presence_of :section_id
  validates_uniqueness_of :path
  
  def copy_connectors
    logger.info "\n\n > Copying Connectors..."
    Connector.all(:conditions => {:page_id => id, :page_version => version-1}, :order => "container, position").each do |c|
      attrs = c.attributes.without("id", "created_at", "updated_at")
      logger.info "attrs => #{attrs.inspect}"
      con = Connector.new(attrs)
      con.page_version = version
      con.save!
    end
    logger.info "< Copying Connectors..."    
  end
  
  def add_content_block!(content_block, container)
    transaction do
      increment_version!
      Connector.create!(:page => self, 
        :page_version => version, 
        :content_block => content_block, 
        :content_block_version => content_block.version,
        :container => container)
    end
  end
  
  def destroy_connector(connector)
    #increment_version will copy all the connectors
    #then we will remove the one you want we get rid of
    transaction do
      increment_version!
      logger.info "\n\nFinding new Content Block..."
      logger.info Connector.all.to_table(:id, :page_id, :page_version, :container, :content_block_id, :content_block_type, :position)
      new_connector = connectors.first(:conditions => {
        :page_id => id, 
        :page_version => version, 
        :container => connector.container,
        :content_block_id => connector.content_block_id,
        :content_block_type => connector.content_block_type,
        :position => connector.position
      })
      if new_connector
        new_connector.destroy
      else
        raise "Could not find connector"
      end
      reload
      connector.freeze
    end
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