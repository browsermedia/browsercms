def create_pages(root)
  (1..20).each do |i|
    Cms::Page.create!(:name=>"Page #{i}", :path=>"#{root.path}/page-#{i}", :section=>root, :template_file_name=>"default.html.erb", :publish_on_save=>true)
  end
end

def reset_root_user_password
  u = User.find(1)
  u.password= "cmsadmin"
  u.password_confirmation = "cmsadmin"
  u.save!

  puts "Reset #{u.login}'s password to '#{u.password}'."
end

namespace :cms do

  task "load"  do
    sh "mysql -u root browsercms_development --password= < db/backups/backup.sql"
  end

  task "correct" => :environment do
    ActiveRecord::Base.connection.execute("UPDATE portlets SET type = 'DynamicPortlet' where type != 'DynamicPortlet'")
    ct = ["'CategoryType'", "'Category'", "'HtmlBlock'", "'Portlet'", "'FileBlock'", "'ImageBlock'", "'Tag'"].join(",")
    ActiveRecord::Base.connection.execute("DELETE FROM content_types where name not in (#{ct})")
    reset_root_user_password
  end

  desc "Load a CMS site backup (a .sql file must be called db/backups/backup.sql) for testing."
  task "load:backup" => ['db:drop','db:create', 'cms:load', 'cms:correct', 'db:migrate']

  desc "Load some sample pages for performance tuning"
  task "load:pages" => :environment do
    root = Cms::Section.root.first
    create_pages(root)
    (21..40).each do |i|
      sec = Cms::Section.create! :name=>"Section #{i}", :path=>"/section-#{i}/", :parent=>root
      create_pages(sec)
    end

  end

end