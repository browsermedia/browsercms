Update bcms-upgrade so it can detect the differences between:

3.1
3.3 (Already does this pretty well)
* If there are no errors, say 'its ready to go' rather than just warning in RED that its does now.
* Need to update the dependency on browsercms before running rails generators
	(Insert s.add_dependency(%q<browsercms>, ["~> 3.3.0"]) into .gemspec
* I can generate a basic gemspec that will probably work for 95% of cms modules.
* Doesn't use mysql2 '0.2.18'
* Make sure cms:install works
3.4 (Needs to do this)
* Might still want to have a custom installer for each module for generating files in the project (i.e. Fckeditor would need this)


Steps:


- Generate a migration based on each model in the project: (app/models/product.rb)

For each custom content type, you will need to generate a migration that looks like this:

# i.e. ['product']
['my_custom_block_singluar_table_name'].each do |table|
  rename_column(prefix("#{table}_versions"), "#{table}_id", :original_record_id) if column_exists?(prefix("#{table}_versions"), "#{table}_id")
end






