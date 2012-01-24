class Browsercms315 < ActiveRecord::Migration
  def self.up
    generate_ancestry_from_section_id
    update_latest_version_cache

    INDEXES.each do |index|
      add_index *index
    end
  end

  def self.down
    # This migration is not reversible since it removes the original section_id column.
  end

  # Add some very commonly used indexes to improve the site performance as the # of pages/content grows (i.e. several thousand pages)
  INDEXES = [
      [:pages, :deleted],
      [:pages, :path],
      [:pages, :version],
      [:page_versions, :page_id],
      [:groups, :code],
      [:groups, :group_type_id],
      [:group_types, :cms_access],
      [:group_sections, :section_id],
      [:group_sections, :group_id],
      [:users, :expires_at],
      [:user_group_memberships, :group_id],
      [:user_group_memberships, :user_id],
      [:group_permissions, :group_id],
      [:group_permissions, :permission_id],
      [:group_permissions, [:group_id, :permission_id]],
      [:section_nodes, :node_type],
      [:section_nodes, :ancestry],
      [:connectors, :page_id],
      [:connectors, :page_version],
      [:html_blocks, :deleted],
      [:html_block_versions, :html_block_id],
      [:html_block_versions, :version],
      [:portlet_attributes, :portlet_id],
      [:portlets, :name],
      [:sections, :path],
      [:redirects, :from_path],
      [:connectors, :connectable_version],
      [:connectors, :connectable_type],
      [:content_types, :content_type_group_id],
      [:content_types, :name],
      [:file_block_versions, :file_block_id],
      [:file_block_versions, :version],
      [:file_blocks, :deleted],
      [:file_blocks, :type],
      [:attachment_versions, :attachment_id],
      [:tasks, :page_id],
      [:tasks, :completed_at],
      [:tasks, :assigned_to_id],
  ]

  private

  # v3.1.5 uses Ancestry to manage the parent child relationship between sections and their children.
  # This converts the data from the old section_id to use the ancestry column.
  def self.generate_ancestry_from_section_id
    add_column :section_nodes, :ancestry, :string
    add_column :section_nodes, :temp_parent_id, :integer

    SectionNode.reset_column_information
    root_section = Section.root.first
    SectionNode.create!(:node => root_section) if root_section

    all_nodes_but_root = SectionNode.find(:all, :conditions=>["section_id IS NOT NULL"])
    all_nodes_but_root.each do |sn|
      parent_node = SectionNode.find(:first, :conditions => ["node_id = ? and node_type = 'Section'", sn.section_id])
      sn.temp_parent_id = parent_node.id
      sn.save!
    end
    rename_column :section_nodes, :temp_parent_id, :parent_id # Ancestry works off the 'parent_id' column.

    SectionNode.build_ancestry_from_parent_ids!
    remove_column :section_nodes, :section_id
    remove_column :section_nodes, :parent_id
    SectionNode.reset_column_information
  end

  # Adds a 'latest_version' pointer to pages and links. Greatly reduces the number of queries the sitemap requires to determine if pages are in draft/published mode
  def self.update_latest_version_cache
    add_column :pages, :latest_version, :integer
    add_column :links, :latest_version, :integer
    Page.all.each do |p|
      p.update_latest_version
    end
    Link.all.each do |link|
      link.update_latest_version
    end
  end
end
