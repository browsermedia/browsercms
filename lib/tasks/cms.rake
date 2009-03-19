namespace :test do
  Rake::TestTask.new(:all => "db:test:prepare") do |t|
    t.libs << "test"
    t.pattern = 'test/**/*_test.rb'
    t.verbose = true
  end
  Rake::Task['test:all'].comment = "Run all tests at once"
end

namespace :cms do
  desc "Wipes database, installs a demo site, including several templates and sample pages."
  task :install_demo_site => ["db:migrate:reset", "db:load_demo_data"]
  
  
  desc "Installs the cms gems"
  task :install do
    reinstall_gem = lambda do |gem_file|
      if gem_file =~ /(.*)-(\d\.\d\.\d)\.gem/
        gem = $1
        version = $2
        args = RUBY_PLATFORM.match(/mswin/) ? [] : ["sudo"]
        system(*(args + ["gem", "uninstall", gem, "-v", version]))
        system(*(args + ["gem", "install", gem_file]))
      end      
    end
    
    system("gem", "build", "gemspec.rb")
    reinstall_gem[Dir["browser_cms-*.gem"].first]
    Dir["#{Dir.pwd}/modules/*"].each do |m|
      FileUtils.cd(m) do
        system("gem", "build", "gemspec.rb")
        reinstall_gem[Dir["browser_cms_*-*.gem"].first]
      end
    end
  end
  
  desc "Bumps the CMS build number"
  task :build do
    file_name = File.expand_path(File.join(File.dirname(__FILE__), "..", "browser_cms.rb"))
    file_contents = open(file_name) {|f| f.read }
    match = file_contents.match(/BUILD = "(\d+)"/)
    build_number = match[1].to_i + 1
    file_contents.sub!(/BUILD = "(\d+)"/, "BUILD = \"#{build_number}\"")
    open(file_name,'w') {|f| f << file_contents }
    puts "BUILD NUMBER = #{build_number}"
  end
    
  desc "Generate guides for the CMS"
  task :guides do
    require 'mizuho/generator'

    source = "doc/guides/source/"
    html   = "doc/guides/html/"
    FileUtils.rm_r(html) if File.directory?(html)
    FileUtils.mkdir(html)

    template = File.expand_path("doc/guides/source/templates/guides.html.erb")

    ignore = ['..', 'icons', 'images', 'templates', 'stylesheets', '.svn']
    ignore << 'active_record_basics.txt'

    indexless = ['index.txt', 'authors.txt']

    # Traverse all entries in doc/guides/source/
    Dir.entries(source).each do |entry|
      next if ignore.include?(entry)

      if File.directory?(File.join(source, entry))
        # If the current entry is a directory, then we will want to compile
        # the 'index.txt' file inside this directory.
        if entry == '.'
          input  = File.join(source, 'index.txt')
          output = File.join(html, "index.html")
        else
          input  = File.join(source, entry, 'index.txt')
          output = File.join(html, "#{entry}.html")
        end
      else
        # If the current entry is a file, then we will want to compile this file.
        input  = File.join(source, entry)
        output = File.join(html, entry).sub(/\.txt$/, '.html')
      end

      begin
        puts "GENERATING => #{output}"
        ENV['MANUALSONRAILS_TOC'] = 'no' if indexless.include?(entry)
        Mizuho::Generator.new(input, :output => output, :template => template).start
      rescue Mizuho::GenerationError
        STDERR.puts "*** ERROR"
        exit 2
      ensure
        ENV.delete('MANUALSONRAILS_TOC')
      end
    end

    # Copy images and css files to html directory. These dirs are in .gitigore and shouldn't be source controlled.
    FileUtils.cp_r File.join(source, 'images'), File.join(html, 'images')
    FileUtils.cp_r File.join(source, 'stylesheets'), File.join(html, 'stylesheets')
  end    
    
end
