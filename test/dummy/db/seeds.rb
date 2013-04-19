load File.expand_path('../../../../db/browsercms.seeds.rb', __FILE__)

Cms::ContentType.create!(:name => "Catalog", :group_name => "Testing")
Cms::ContentType.create!(:name => "Product", :group_name => "Testing")

# Each content type that needs to be addressable needs a parent section where new items will be placed.
create_section(:products, :name => "Products", :parent => sections(:root),
               :path => "/products", :hidden => true, allow_groups: :all)

