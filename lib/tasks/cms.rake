namespace :cms do
  
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
    
end
