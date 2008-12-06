namespace :cms do
  
  desc "Builds and installs the cms gems"
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
    
end
