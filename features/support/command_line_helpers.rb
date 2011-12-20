module CommandLineHelpers
  attr_accessor :project_name

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

  # Given the name of the migration (i.e. create_something.rb) find the EXACT migration file (which will include a timestamp)
  # @param [String] partial_file_name Include the .rb at the end
  # @parem [String] The absolute path to the migration file
  def find_migration_with_name(partial_file_name)
    files = Dir.glob("#{@aruba_dir}/#{project_name}/db/migrate/*#{partial_file_name}")
    File.absolute_path(files.first)
  end
end
World(CommandLineHelpers)

