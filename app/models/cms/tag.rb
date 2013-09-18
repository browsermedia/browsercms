module Cms
  class Tag < ActiveRecord::Base

    has_many :taggings, :class_name => 'Cms::Tagging'
    extend DefaultAccessible
    include Concerns::IgnoresPublishing

    validates_uniqueness_of :name

    attr_accessor :size
    is_searchable
    has_content_type :module => :categorization

    def self.named(tag)
      where(name: tag)
    end

    # Returns an array of tags with a #count attribute
    #
    # @return [Array] Each element of the area contains [Id (Integer), Name (String), count (Integer)] (with Sqlite3 anyway)
    def self.counts()
      select("#{table_name}.id, #{table_name}.name, count(#{table_name}.id) as count")
        .joins(:taggings)
        .group("#{table_name}.id, #{table_name}.name")
        .order("count desc, #{table_name}.name")
    end

    # Returns an array of tags with a size attribute
    # This takes the same arguments as find, plus the additional `:sizes` option,
    # which contols the number of sizes the tag cloud will have.
    # The default number of sizes is 5.
    def self.cloud(options={})
      sizes = (options.delete(:sizes) || 5) - 1
      sizes = 1 if sizes < 1
      tags = counts.limit(sizes)
      return [] if tags.blank?

      min = nil
      max = nil
      tags.each do |t|
        t.count = t.count.to_i
        min = t.count if (min.nil? || t.count < min)
        max = t.count if (max.nil? || t.count > min)
      end

      divisor = ((max - min) / sizes) + 1
      tags.each do |t|
        t.size = ("%1.0f" % (t.count * 1.0 / divisor)).to_i
      end

      tags
    end

    def tagging_count
      taggings.count
    end

    def self.columns_for_index
      [{:label => "Name", :method => :name, :order => "name"},
       {:label => "Usages", :method => :tagging_count},
       {:label => "Updated On", :method => :updated_on_string, :order => "updated_at"}]
    end

    def render
      @taggings = @content_block.taggings.paginate(:page => params[:page])
    end

  end
end