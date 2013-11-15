module DatabaseHelpers

  # Drops and recreates the tables for a content type
  # @param [Symbol] name The name of the content table to drop/recreate.
  def self.ensure_content_table_exists(name)
    ActiveRecord::Base.connection.instance_eval do
      drop_table(name) rescue nil
      drop_table("#{name.to_s.singularize}_versions".to_sym) rescue nil
      create_content_table(name) do |t|
        t.string :name
        t.timestamps
      end
    end
  end
end

