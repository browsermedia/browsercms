class CommandLine

  # Sets the correct Rails application to use.
  # -m demo -> Becomes the /path/to/browsercms/gem/templates/demo.rb
  # -m module -> Becomes the /path/to/browsercms/gem/templates/modeule.rb
  # If blank, becomes the /path/to/browsercms/gem/templates/blank.rb
  def self.set_template(args)
    if args.include?("-m")
      index = args.index("-m")
      if args[index + 1] == "demo"
        args[index + 1] = template("demo.rb")
      elsif args[index+1] == "module"
        args[index + 1] = template("module.rb")
      end
    elsif args.include?("--template")
      index = args.index("--template")
      if args[index + 1] == "demo"
        args[index + 1] = template("demo.rb")
      elsif args[index+1] == "module"
        args[index + 1] = template("module.rb")
      end
    else
      args << "-m" << template("blank.rb")
    end

  end

  # Return the directory where the BrowserCMS templates reside.
  def self.template_dir
    current_file = File.expand_path(File.dirname(__FILE__))
    gem_dir = File.join(current_file, "..")
    template_dir = File.join(gem_dir, "templates")
  end

  # Return the file for the given template.
  def self.template(file_name)
    File.join(template_dir, file_name)
  end
end
