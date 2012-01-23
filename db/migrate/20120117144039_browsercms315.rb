class Browsercms315 < ActiveRecord::Migration

  # These indexes help make the sitemap more efficient when loading
  INDEXES = [
    [:pages, :deleted],
    [:groups, :code],
    [:groups, :group_type_id],
    [:group_types, :cms_access],
    [:group_sections, :section_id],
		[:group_sections, :group_id],
    [:section_nodes, :node_type],
    [:user_group_memberships, :group_id],
    [:user_group_memberships, :user_id],
    [:group_permissions, :group_id],
    [:group_permissions, :permission_id],
    [:group_permissions, [:group_id, :permission_id]],
    [:section_nodes, :ancestry]
  ]

  def self.up
    add_column :section_nodes, :ancestry, :string

    generate_ancestry_keys_from_section_id
    update_latest_version_cache

    INDEXES.each do |index|
      add_index *index
    end
  end

  def self.down
    INDEXES.each do |index|
      remove_index *index
    end
    remove_column :links, :latest_version
    remove_column :pages, :latest_version
    remove_column :section_nodes, :ancestry
  end


  private

  # todo
  # Remove old columns
  # Should rename table too.
  def self.generate_ancestry_keys_from_section_id
    add_column :section_nodes, :temp_parent_id, :integer

    SectionNode.reset_column_information
    root_section = Section.root.first
    SectionNode.create!(:node => root_section)

    all_nodes_but_root = SectionNode.find(:all, :conditions=>["section_id IS NOT NULL"])
    all_nodes_but_root.each do |sn|
      parent_node = SectionNode.find(:first, :conditions => ["node_id = ? and node_type = 'Section'", sn.section_id])
      sn.temp_parent_id = parent_node.id
      sn.save!
    end
    rename_column :section_nodes, :temp_parent_id, :parent_id

    SectionNode.build_ancestry_from_parent_ids!
    SectionNode.reset_column_information
  end

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
