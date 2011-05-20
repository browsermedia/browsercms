namespace :cms do
  task :clone_fixtures do
    cms_fixture_dir = FileUtils.mkdir_p(File.join(RAILS_ROOT, 'test', 'fixtures', 'cms'))
    Dir.glob(File.join(RAILS_ROOT, 'test', 'fixtures', '*.{yml,csv}')).each do |fixture_file|
      puts "Moving #{File.basename(fixture_file)} to cms/cms_#{File.basename(fixture_file)}"
      FileUtils.cp(fixture_file, File.join(cms_fixture_dir, "cms_#{File.basename(fixture_file)}"))
    end
  end
end