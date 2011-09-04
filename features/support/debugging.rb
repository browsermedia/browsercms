require 'cms/data_loader'

After do |scenario|
  #save_and_open_page if scenario.failed?
end

require "#{Rails.root}/test/mock_file"

