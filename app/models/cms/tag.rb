module Cms
  class Tag < ActiveRecord::Base

    has_many :taggings, :class_name => 'Cms::Tagging'
    include DefaultAccessible

    validates_uniqueness_of :name

    attr_accessor :size
    is_searchable
    scope :named, lambda { |tag| {:conditions => ["#{table_name}.name = ? ", tag]} }

    # Returns an array of tags with a count attribute
    #
    # @return [Array] Each element of the area contains [Id (Integer), Name (String), count (Integer)] (with Sqlite3 anyway)
    def self.counts(options={})
      with_scope(:find => {
          :select => "#{Tag.table_name}.id, #{Tag.table_name}.name, count(*) as count",
          :joins => :taggings,
          :group => "#{Tag.table_name}.id, #{Tag.table_name}.name",
          :order => "count desc, #{Tag.table_name}.name"}) do
        all(options)
      end
    end

    # Returns an array of tags with a size attribute
    # This takes the same arguments as find, plus the additional `:sizes` option,
    # which contols the number of sizes the tag cloud will have.
    # The default number of sizes is 5.
    def self.cloud(options={})
      sizes = (options.delete(:sizes) || 5) - 1
      sizes = 1 if sizes < 1
      tags = counts(options)
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