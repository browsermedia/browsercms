class Browsercms315 < ActiveRecord::Migration
  def self.up
    add_column :section_nodes, :ancestry, :string
    add_index :section_nodes, :ancestry

    generate_ancestry_keys_from_section_id()
    # Remove old columns
    # Should rename table too.

    add_column :pages, :latest_version, :integer
    add_column :links, :latest_version, :integer
    Page.all.each do |p|
      p.update_latest_version
    end
    Link.all.each do |link|
      link.update_latest_version
    end
    # Will need to update all existing pages to have a valid value for this.
  end

  def self.down
    remove_column :links, :latest_version
    remove_column :pages, :latest_version
    remove_column :section_nodes, :ancestry
    remove_index :section_nodes, :ancestry
  end


  private
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
end
