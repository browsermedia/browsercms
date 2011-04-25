require 'find'

namespace :db do

  desc 'Override db:install to include demo seed data.'
  task :install => ["db:create", "db:migrate", "db:seed", 'db:seed_demo_site']

  desc 'Load the demo site seed data from db/seeds.rb'
  task :seed_demo_site => 'db:abort_if_pending_migrations' do
    demo_seed_file = File.join(Rails.root, 'db', 'demo_site_seeds.rb')
    load(demo_seed_file) if File.exist?(demo_seed_file)
  end
  
end