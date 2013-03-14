load File.expand_path('../../../../db/browsercms.seeds.rb', __FILE__)

Cms::ContentType.create!(:name => "Catalog", :group_name => "Testing")
Cms::ContentType.create!(:name => "Product", :group_name => "Testing")

