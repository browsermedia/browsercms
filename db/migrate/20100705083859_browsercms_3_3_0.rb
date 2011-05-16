class Browsercms330 < ActiveRecord::Migration
  def self.up

    # patch required for LH345
    cant_fix = []
    to_fix = []
    # find all pages whose path ends in slash and is not root
    Cms::Page.find(:all, :conditions => "path LIKE '/%/'").each do |pt_page|
      # make sure no extant page has this path
      if Page.count(:conditions => ["path = ?", pt_page.path.sub(/(.+)\/+$/, '\1')]) > 0
          cant_fix << pt_page
        else
          to_fix << pt_page
        end
    end
    version_cant_fix = []
    version_to_fix = []
    # find all page versions whose path ends in slash and is not root
    Cms::Page::Version.find(:all, :conditions => "path LIKE '/%/'").each do |pt_page|
      # make sure no extant page has this path
      if Cms::Page.count(:conditions => ["path = ?", pt_page.path.sub(/(.+)\/+$/, '\1')]) > 0
          version_cant_fix << pt_page
        else
          version_to_fix << pt_page
        end
    end

    # raise an error if there are pages (*not* page versions) that will duplicate an extant path if the ending slash is dropped
    if cant_fix.length > 0
      raise "Cannot remove trailing slashes from pages with ID(s) (#{cant_fix.map(&:id).join(', ')}). Other pages already exist with their correct path. The offending path may be in an unpublished page version, newer than the current public version. These needed to be corrected manually in your DBMS before running this migration"
    end

    to_fix.each do |fix_page|
      # change the path of all pages with a trailing slash to not have one
      # using sql updates to prevent unwanted callbacks
      new_path = fix_page.path.to_s.sub(/(.+)\/+$/, '\1')
      execute "UPDATE #{prefix('pages')} SET path = '#{new_path}' WHERE id = #{fix_page.id};"
    end
    version_to_fix.each do |fix_page|
      # change the path of all fixable page versions with a trailing slash to not have one
      # using sql updates to prevent unwanted callbacks
      new_path = fix_page.path.to_s.sub(/(.+)\/+$/, '\1')
      execute "UPDATE #{prefix('page_versions')} SET path = '#{new_path}' WHERE id = #{fix_page.id};"
    end
    # end patch for LH345
  end

  def self.down

    # Cannot restore paths with trailing slash - raise error or show message
    #
    # raise IrreversibleMigration, "Cannot reverse migration which removes trailing slash from page paths"
    puts "Page paths which had trailing slashes removed cannot be restored to their original state."

  end
end
