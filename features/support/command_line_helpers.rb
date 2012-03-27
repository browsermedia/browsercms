module CommandLineHelpers
  attr_writer :project_name

  def project_name
    unless @project_name
      raise "This Cucumber step relies on self.project_name= to be set prior to being called."
    end
    @project_name
  end

  def expect_project_directories(directories)
    check_directory_presence prefix_project_name_to(directories), true
  end

  def expect_project_files(files)
    check_file_presence prefix_project_name_to(files), true
  end

  # @param [String|Array] files File(s)) or Directory(ies) that should have the project name prefixed.
  def prefix_project_name_to(files)
    if files.instance_of?(Array)
      files.map { |file| "#{project_name}/#{file}" }
    else
      "#{project_name}/#{files}"
    end
  end

  def create_bcms_project(name)
    self.project_name = name
    cmd = "bcms new #{project_name} --skip-bundle"
    run_simple(unescape(cmd), false)
  end

  # Create a baseline rails project that looks like BrowserCMS as of a particular version
  #   This will not be particularly 'robust' since its not really possible to run a command to get a historical version of the cms.
  def create_historical_cms_project(project_name, rails_version, cms_version)
    run_simple "rails _#{rails_version}_ new #{project_name} --skip-bundle"
    cd project_name
    append_to_file "Gemfile", "gem \"browsercms\", \"#{cms_version}\""
    self.project_name = project_name
  end

  # Given the name of the migration (i.e. create_something.rb) find the EXACT migration file (which will include a timestamp)
  #   Example:
  #   find_migration_with_name("create_something.rb")
  #
  # @param [String] partial_file_name - Must include the .rb at the end
  # @parem [String] The absolute path to the migration file
  def find_migration_with_name(partial_file_name)
    files, file_pattern = migrations_named(partial_file_name)
    fail "Couldn't find a migration file matching this pattern (#{file_pattern})'" if files.empty?
    File.absolute_path(files.first)
  end

  def migration_exists?(partial_file_name)
    files, fp = migrations_named(partial_file_name)
    files.size > 0
  end

  def migrations_named(name)
    file_pattern = "#{@aruba_dir}/#{project_name}/db/migrate/*#{name}"
    files = Dir.glob(file_pattern)
    return files, file_pattern
  end


  def verify_seed_data_requires_browsercms_seeds
    check_file_content('db/seeds.rb', "\nrequire File.expand_path('../browsercms.seeds.rb', __FILE__)\n", true)
  end
end
World(CommandLineHelpers)

