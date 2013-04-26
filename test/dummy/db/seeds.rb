load File.expand_path('../../../../db/browsercms.seeds.rb', __FILE__)

create_content_type(:catalog, name: "Catalog", group_name: "Testing")
create_content_type(:product, name: "Product", group_name: "Testing")

