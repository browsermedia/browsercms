class Browsercms320 < ActiveRecord::Migration
  def self.up

    # patch required for LH345
    cant_fix = []
    to_fix = []
    Page.find(:all, :order => 'id asc').each do |pt_page|
      if pt_page.path.to_s.match(/.+\/+$/)
        if Page.find(:first, :conditions => ["path = ?", pt_page.path.sub(/(.+)\/+$/, '\1')])
          cant_fix << pt_page
        else
          to_fix << pt_page
        end
        next
      end
      
      vs_no = pt_page.draft.version
      while vs_no > pt_page.version
        version = pt_page.find_version(vs_no)
        if version && version.path.to_s.match(/.+\/+$/)
          to_fix << pt_page
          break
        end
        vs_no -= 1
      end
    end

    if cant_fix.length > 0
      raise ActiveRecordError, "Cannot remove trailing slashes from pages with IDs (#{cant_fix.map(&:id).join(', ')}). Other pages already exist with their correct path. The offending path may be in an unpublished page version, newer than the current public version. These needed to be corrected manually in your DBMS before running this migration"
    end

    to_fix.each do |fix_page|
      # using sql updates to prevent unwanted callbacks
      new_path = fix_page.path.to_s.sub(/(.+)\/+$/, '\1')
      execute "UPDATE pages SET path = '#{new_path}' WHERE id = #{fix_page.id};"
      # update the current version record to
      execute "UPDATE page_versions SET path = '#{new_path}' WHERE page_id = #{fix_page.id} AND version = #{fix_page.version};"

      # now update any newer versions whose paths are currupted. For each currupt path, set it 
      # to the most recent earlier valid path, or the new stripped path
      max_no = fix_page.draft.version
      current_vs_no = fix_page.version
      while current_vs_no < max_no
        current_vs_no += 1
        version = fix_page.find_version(current_vs_no)
        if version && version.path.match(/.+\/+$/)
          execute "UPDATE page_versions SET path = '#{new_path}' WHERE id = #{version.id}"
        else 
          new_path = version.path.to_s
        end
      end
    end
    # end patch for lh345
  end

  def self.down

    # Cannot restore paths with trailing slash - raise error or show message
    #
    # raise IrreversibleMigration, "Cannot reverse migration which removes trailing slash from page paths"
    puts "Page paths which had trailing slashes removed cannot be restored to their original state."

  end
end
