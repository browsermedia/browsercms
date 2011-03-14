require 'generators/browser_cms'
module BrowserCms
  module Generators
    class CmsGenerator < Base


      def enable_static_asset_serving
        application do
          code = "# BrowserCMS must serve static CMS assets (js, css, images) from the Gem\n"
          code = code + "config.serve_static_assets = true"
        end
      end

      def create_cms
        #Cms.generator_paths is an Array of Arrays
        #Each Array has the root as the first element
        #and the array of "files" as the second element
        #Each element in files is actually a Dir.glob pattern string

        Cms.generator_paths.each do |src_root, files|
          copy_files src_root, files
        end
      end

      private
      def copy_files(src_root, files)
#        puts "Copying from src_root '#{src_root}'"
        dirs = []
        files.each do |d|
#          puts "reviewing '#{d}'"
          Dir[File.join(src_root, d)].each do |f|
#            puts "Looking at file '#{f}'"
            if File.file?(f)
              dir = File.dirname(f.gsub("#{src_root}/", ''))
#              puts "Directory '#{dir}"
              unless dirs.include?(dir)
                directory dir
                dirs << dir
              end
              relative_dest_file_name = f.gsub("#{src_root}/", "")
#              puts "Finally: '#{relative_dest_file_name}'"
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