class Browsercms315 < ActiveRecord::Migration
  def self.up
    generate_ancestry_from_section_id
    update_latest_version_cache

    INDEXES.each do |index|
      table, column = *index
      add_index prefix(table), column
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
      [:page_versions, :original_record_id],
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
      [:html_block_versions, :original_record_id],
      [:html_block_versions, :version],
      [:portlet_attributes, :portlet_id],
      [:portlets, :name],
      [:sections, :path],
      [:redirects, :from_path],
      [:connectors, :connectable_version],
      [:connectors, :connectable_type],
      [:content_types, :content_type_group_id],
      [:content_types, :name],
      [:file_block_versions, :original_record_id],
      [:file_block_versions, :version],
      [:file_blocks, :deleted],
      [:file_blocks, :type],
      [:attachment_versions, :original_record_id],
      [:tasks, :page_id],
      [:tasks, :completed_at],
      [:tasks, :assigned_to_id],
  ]

  private

  # v3.1.5 uses Ancestry to manage the parent child relationship between sections and their children.
  # This converts the data from the old section_id to use the ancestry column.
  def self.generate_ancestry_from_section_id
    add_column prefix(:section_nodes), :ancestry, :string
    add_column prefix(:section_nodes), :temp_parent_id, :integer

    Cms::SectionNode.reset_column_information
    root_section = Cms::Section.root.first
    Cms::SectionNode.create!(:node => root_section) if root_section

    all_nodes_but_root = Cms::SectionNode.find(:all, :conditions=>["section_id IS NOT NULL"])
    all_nodes_but_root.each do |sn|
      parent_node = Cms::SectionNode.find(:first, :conditions => ["node_id = ? and node_type = 'Section'", sn.section_id])
      sn.temp_parent_id = parent_node.id
      sn.save!
    end
    rename_column prefix(:section_nodes), :temp_parent_id, :parent_id # Ancestry works off the 'parent_id' column.

    Cms::SectionNode.build_ancestry_from_parent_ids!
    remove_column prefix(:section_nodes), :section_id
    remove_column prefix(:section_nodes), :parent_id
    Cms::SectionNode.reset_column_information
  end

  # Adds a 'latest_version' pointer to pages and links. Greatly reduces the number of queries the sitemap requires to determine if pages are in draft/published mode
  def self.update_latest_version_cache
    add_column prefix(:pages), :latest_version, :integer
    add_column prefix(:links), :latest_version, :integer
    Cms::Page.all.each do |p|
      p.update_latest_version
    end
    Cms::Link.all.each do |link|
      link.update_latest_version
    end
  end
end
