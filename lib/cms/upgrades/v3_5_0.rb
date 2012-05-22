require 'fileutils'

module Cms
  module Upgrades

    module V3_5_0
      def upgrade_to_3_5_0
        gsub_file "config/environments/production.rb", /config.action_controller.page_cache_directory.+$/, ""
      end

      # Technically these updates are for v3_4_0, but I want to avoid having to change existing migrations
      #
      # These migrations are designed to make it easy for modules to write migrations for their content blocks with minimal code.
      module Retroactive_v3_4_0Updates
        # Applys table namespacing and other fixes to blocks that need upgrading from < 3.4.0 to 3.5.
        #
        # @param [String] module_name I.e. module table_prefix (i.e. BcmsWhatever)
        # @param [String] model_class_name I.e. 'Slide' or 'NewsArticle'
        def v3_5_0_apply_namespace_to_block(module_name, model_class_name)
          puts "Applying namespace '#{module_name}' to model '#{model_class_name}'"
          table_prefix = module_name.underscore
          model_name = model_class_name.underscore

          rename_table model_name.pluralize, "#{table_prefix}_#{model_name.pluralize}"
          rename_table "#{model_name}_versions", "#{table_prefix}_#{model_name}_versions"
          v3_5_0_standardize_version_id_column(table_prefix, model_name)
          v3_5_0_namespace_model_data(module_name, model_class_name)
          v3_5_0_update_connector_namespaces(module_name, model_class_name)
        end

        def v3_5_0_standardize_version_id_column(table_prefix, model_name)
          if column_exists?("#{table_prefix}_#{model_name}_versions", "#{model_name}_id")
            rename_column("#{table_prefix}_#{model_name}_versions", "#{model_name}_id", :original_record_id)
          end
        end

        def v3_5_0_namespace_model_data(module_name, model_class_name)
          found = Cms::ContentType.named(model_class_name).first
          if found
            found.name = v3_5_0_namespace_model(module_name, model_class_name)
            found.save!
          end
        end

        def v3_5_0_update_connector_namespaces(module_name, model_class_name)
          namespaced_class = v3_5_0_namespace_model(module_name, model_class_name)
          Cms::Connector.where(:connectable_type => model_class_name).each do |connector|
            connector.connectable_type = namespaced_class
            connector.save!
          end
        end

        def v3_5_0_namespace_model(module_name, model_class_name)
          "#{module_name}::#{model_class_name}"
        end
      end

      # Add additional methods to ActiveRecord::Migration when this file is required.
      module FileStorageUpdates


        # Old paths are:
        #       uploads/:year/:month/:day/:fingerprint
        # i.e.  uploads/2012/04/27/fb598......
        #
        # New paths use paperclip's :id_partition which creates paths like:
        #       uploads/000/000/001/:fingerprint
        # where it splits the id into multiple directories
        #
        # @param [Cms::Attachment] attachment
        # @return [String] path to location where an attachment should be (based on id)
        def path_for_attachment(attachment)
          new_id_dir = "#{Paperclip::Interpolations.id_partition(AttachmentWrapper.new(attachment), nil)}/original"
          "#{new_id_dir}/#{attachment.data_fingerprint}"
        end

        # @return [String] Path to where an attachment should be
        def path_to_attachment(attachment)
          loc = path_for_attachment(attachment)
          file_in_attachments_dir(loc)
        end

        # For a given class with an Attachment association (pre-3.5.0), migrate its attachment data to match the new
        # table structure.
        def migrate_attachment_for(klass)
          klass.unscoped.find_each do |block|
            Cms::Attachment.unscoped.update_all({:attachable_id => block.id,
                                                 :attachable_version => block.version,
                                                 :attachable_type => klass.name,
                                                 :attachment_name => "file",
                                                 :cardinality => 'single'},
                                                {:id => block.attachment_id})
          end

          attachable_type = klass.name
          # Special handling for File/Image blocks
          if klass == Cms::FileBlock
            attachable_type = "Cms::AbstractFileBlock"
          elsif klass == Cms::ImageBlock
            # Only need to do this once for both Image and File blocks since they share a table.
            return
          end

          migrated_attachment_for_versioned_table(klass, attachable_type)

        end

        def migrated_attachment_for_versioned_table(model_class, attachable_type)
          version_model = model_class.version_class

          found = version_model.find_by_sql("SELECT original_record_id, attachment_id, attachment_version, version from #{version_model.table_name}")
          found.each do |version_record|
            Cms::Attachment::Version.unscoped.update_all({:attachable_id => version_record.original_record_id,
                                                          :attachable_version => version_record.version,
                                                          :attachable_type => attachable_type,
                                                          :attachment_name => "file",
                                                          :cardinality => 'single'},
                                                         {:original_record_id => version_record.attachment_id, :version => version_record.attachment_version})
          end
        end

        # Move the attachment files from the old file path path to new one. Updates the Attachment record to match.
        def migrate_attachment_files_to_new_location
          migrate_attachments_file_location(Cms::Attachment)
          migrate_attachments_file_location(Cms::Attachment::Version)
        end

        # Remove the attachment_version and attachment_id columns for all core CMS blocks.
        def cleanup_attachment_columns_for_core_cms
          cleanup_attachment_columns(Cms::FileBlock)
        end

        # The 'attachment_id and attachment_version are no longer stored in the model, but in the attachments table'
        # @param [Class] model_class The model to have its columns cleaned up.
        def cleanup_attachment_columns(model_class)
          remove_content_column model_class.table_name, :attachment_id if column_exists?(model_class.table_name, :attachment_id)
          remove_content_column model_class.table_name, :attachment_version if column_exists?(model_class.table_name, :attachment_id)
        end

        # Removes the cms_attachments.file_location column
        #
        # data_fingerprint is used to store the file name instead now.
        def cleanup_attachments_file_location
          remove_content_column :cms_attachments, :file_location if column_exists?(:cms_attachments, :file_location)
        end

        # Deletes the old file storage folders from the uploads directory.
        #
        def cleanup_attachment_file_storage
          ["2009", "2010", "2011", "2012"].each do |year|
            folder_to_remove = File.join(attachments_dir, year)
            FileUtils.rm_rf(folder_to_remove, :verbose => true)
          end
        end

        private

        # Multiple version of attachments may point to the same file, so we need to test
        # a file exists before moving. Failure to move isn't necessary an error, since it may have been moved in
        # an earlier version
        def migrate_attachments_file_location(model_class)
          model_class.unscoped.each do |attachment|
            from = File.join(attachments_dir, attachment.file_location)
            to = path_to_attachment(attachment)
            move_attachment_file(from, to)

            new_fingerprint = attachment.file_location.split("/").last
            model_class.unscoped.update_all({:data_fingerprint => new_fingerprint}, :id => attachment.id)
          end
        end

        def file_in_attachments_dir(file_name)
          File.join(Cms::Attachment.configuration.attachments_root, file_name)
        end

        def move_attachment_file(old_location, new_location)
          if File.exists?(old_location)
            FileUtils.mkdir_p(File.dirname(new_location), :verbose => false)
            FileUtils.mv(old_location, new_location, :verbose => true)
          else
            puts "'#{old_location}' does not exist, and may have been moved already. Skipping move."
          end
        end

        def attachments_dir
          Cms::Attachment.configuration.attachments_root
        end

        # Allows us to use the Paperclip interpolations logic directly
        class AttachmentWrapper
          def initialize(attachment)
            @attachment = attachment
          end

          def instance
            @attachment
          end
        end
      end
    end
  end
end
if defined?(ActiveRecord::Migration)
  ActiveRecord::Migration.send(:include, Cms::Upgrades::V3_5_0::FileStorageUpdates)
  ActiveRecord::Migration.send(:include, Cms::Upgrades::V3_5_0::Retroactive_v3_4_0Updates)
end
