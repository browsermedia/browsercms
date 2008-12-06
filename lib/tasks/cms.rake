namespace :cms do
  
  desc "Builds and installs the cms gems"
  task :install do
    FileUtils.rm(Dir["*.gem"])
    system("gem", "build", "gemspec.rb")
    Dir["#{Dir.pwd}/modules/*"].each do |m|
      system("gem", "build", "#{m}/gemspec.rb")
    end
    Dir["*.gem"].each do |g|
      if g =~ /(.*)-(\d\.\d\.\d)\.gem/
        gem = $1
        version = $2
        args = RUBY_PLATFORM.match(/mswin/) ? [] : ["sudo"]
        system(*(args + ["gem", "uninstall", gem, "-v", version]))
        system(*(args + ["gem", "install", g]))
      end
    end
  end
  
end
