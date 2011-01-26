require 'find'

namespace :db do

  desc 'Load the demo site seed data from db/seeds.rb'
  task :seed_demo_site => 'db:abort_if_pending_migrations' do
    demo_seed_file = File.join(Rails.root, 'db', 'demo_site_seeds.rb')
    load(demo_seed_file) if File.exist?(demo_seed_file)
  end
  
end