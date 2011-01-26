require 'generators/browser_cms'
module BrowserCms
  module Generators
    class CmsGenerator < Base

      Cms.add_generator_paths(Cms.root,
                              "config/initializers/cms.rb",
                              "public/javascripts/jquery*",
                              "public/javascripts/cms/**/*",
                              "public/bcms/ckeditor/**/*",
                              "public/site/**/*",
                              "public/stylesheets/cms/**/*",
                              "public/images/cms/**/*",
                              "db/migrate/[0-9]*_*.rb",
                              "db/seeds.rb")


      def create_cms
        #Cms.generator_paths is an Array of Arrays
        #Each Array has the root as the first element
        #and the array of "files" as the second element
        #Each element in files is actually a Dir.glob pattern string

        puts "Here are the files to be generated: #{Cms.generator_paths}"
        Cms.generator_paths.each do |src_root, files|
          copy_files src_root, files
        end
      end

      private
      def copy_files(src_root, files)
        dirs = []
        files.each do |d|
          Dir[File.join(src_root, d)].each do |f|
            if File.file?(f)
              dir = File.dirname(f.gsub("#{src_root}/", ''))
              unless dirs.include?(dir)
                directory dir
                dirs << dir
              end
              relative_dest_file_name = f.gsub("#{src_root}/", "")
              copy_file Cms.scrub_path(f), relative_dest_file_name
            end
          end
        end
      end
    end
  end
end

# class BrowserCmsGenerator < Rails::Generator::Base
#   #We need to be able to define a different source root for each gem
#   #So we'll just set the baseline source root to "/",
#   #and append the appropriate path when we call file
#   def source_root
#     "/"
#   end
#   def manifest
#     record do |m|
#       #Cms.generator_paths is an Array of Arrays
#       #Each Array has the root as the first element
#       #and the array of "files" as the second element
#       #Each element in files is actually a Dir.glob pattern string
#       Cms.generator_paths.each do |src_root, files|
#          copy_files  m, src_root, files
#       end
#     end
#   end
#   def copy_files(m, src_root, files)
#     dirs = []
#     files.each do |d|
#       Dir[File.join(src_root, d)].each do |f|
#         if File.file?(f)
#           dir = File.dirname(f.gsub("#{src_root}/",''))
#           unless dirs.include?(dir)
#             m.directory dir
#             dirs << dir
#           end
#           relative_dest_file_name = f.gsub("#{src_root}/", "")
#           m.file Cms.scrub_path(f), relative_dest_file_name
#         end
#       end
#     end
#   end
# end