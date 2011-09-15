Given /^the cms database is populated$/ do
  Cms::DataLoader.silent_mode = true
  load File.join(File.dirname(__FILE__), '../../db/seeds.rb')
end
