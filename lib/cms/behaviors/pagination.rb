# This is just a repackaged version of Will Paginate 2.2.2
module Cms
  module Behaviors
    module Pagination

      DEFAULT_PER_PAGE =  15

      def self.included(model_class)
        model_class.extend(ClassMethods)
        class << model_class
          define_method(:default_per_page) { DEFAULT_PER_PAGE }
        end
      end
      class InvalidPage < ArgumentError
        def initialize(page, page_num)
          super "#{page.inspect} given as value, which translates to '#{page_num}' as page number"
        end
      end      
      class Collection < Array
        attr_reader :current_page, :per_page, :total_entries, :total_pages

        # Arguments to the constructor are the current page number, per-page limit
        # and the total number of entries. The last argument is optional because it
        # is best to do lazy counting; in other words, count *conditionally* after
        # populating the collection using the +replace+ method.
        def initialize(page, per_page, total = nil)
          @current_page = page.to_i
          raise InvalidPage.new(page, @current_page) if @current_page < 1
          @per_page = per_page.to_i
          raise ArgumentError, "`per_page` setting cannot be less than 1 (#{@per_page} given)" if @per_page < 1

          self.total_entries = total if total
        end

        # Just like +new+, but yields the object after instantiation and returns it
        # afterwards. This is very useful for manual pagination:
        #
        #   @entries = WillPaginate::Collection.create(1, 10) do |pager|
        #     result = Post.find(:all, :limit => pager.per_page, :offset => pager.offset)
        #     # inject the result array into the paginated collection:
        #     pager.replace(result)
        #
        #     unless pager.total_entries
        #       # the pager didn't manage to guess the total count, do it manually
        #       pager.total_entries = Post.count
        #     end
        #   end
        #
        # The possibilities with this are endless. For another example, here is how
        # WillPaginate used to define pagination for Array instances:
        #
        #   Array.class_eval do
        #     def paginate(page = 1, per_page = 15)
        #       WillPaginate::Collection.create(page, per_page, size) do |pager|
        #         pager.replace self[pager.offset, pager.per_page].to_a
        #       end
        #     end
        #   end
        #
        # The Array#paginate API has since then changed, but this still serves as a
        # fine example of WillPaginate::Collection usage.
        def self.create(page, per_page, total = nil, &block)
          pager = new(page, per_page, total)
          yield pager
          pager
        end

        # Helper method that is true when someone tries to fetch a page with a
        # larger number than the last page. Can be used in combination with flashes
        # and redirecting.
        def out_of_bounds?
          current_page > total_pages
        end

        # Current offset of the paginated collection. If we're on the first page,
        # it is always 0. If we're on the 2nd page and there are 30 entries per page,
        # the offset is 30. This property is useful if you want to render ordinals
        # besides your records: simply start with offset + 1.
        def offset
          (current_page - 1) * per_page
        end

        # current_page - 1 or nil if there is no previous page
        def previous_page
          current_page > 1 ? (current_page - 1) : nil
        end

        # current_page + 1 or nil if there is no next page
        def next_page
          current_page < total_pages ? (current_page + 1) : nil
        end

        def total_entries=(number)
          @total_entries = number.to_i
          @total_pages   = (@total_entries / per_page.to_f).ceil
        end

        # This is a magic wrapper for the original Array#replace method. It serves
        # for populating the paginated collection after initialization.
        #
        # Why magic? Because it tries to guess the total number of entries judging
        # by the size of given array. If it is shorter than +per_page+ limit, then we
        # know we're on the last page. This trick is very useful for avoiding
        # unnecessary hits to the database to do the counting after we fetched the
        # data for the current page.
        #
        # However, after using +replace+ you should always test the value of
        # +total_entries+ and set it to a proper value if it's +nil+. See the example
        # in +create+.
        def replace(array)
          result = super

          # The collection is shorter then page limit? Rejoice, because
          # then we know that we are on the last page!
          if total_entries.nil? and length < per_page and (current_page == 1 or length > 0)
            self.total_entries = offset + length
          end

          result
        end        
      end
      module ClassMethods
        # This is the main paginating finder.
        #
        # == Special parameters for paginating finders
        # * <tt>:page</tt> -- REQUIRED, but defaults to 1 if false or nil
        # * <tt>:per_page</tt> -- defaults to <tt>CurrentModel.per_page</tt> (which is 30 if not overridden)
        # * <tt>:total_entries</tt> -- use only if you manually count total entries
        # * <tt>:count</tt> -- additional options that are passed on to +count+
        # * <tt>:finder</tt> -- name of the ActiveRecord finder used (default: "find")
        #
        # All other options (+conditions+, +order+, ...) are forwarded to +find+
        # and +count+ calls.
        def paginate(*args, &block)
          options = args.pop
          page, per_page, total_entries = parse_pagination_options(options)

          finder = (options[:finder] || 'find').to_s
          if finder == 'find'
            # an array of IDs may have been given:
            total_entries ||= (Array === args.first and args.first.size)
            # :all is implicit
            args.unshift(:all) if args.empty?
          end

          Collection.create(page, per_page, total_entries) do |pager|
            count_options = options.except :page, :per_page, :total_entries, :finder
            find_options = count_options.except(:count).update(:offset => pager.offset, :limit => pager.per_page) 

            args << find_options
            # @options_from_last_find = nil
            pager.replace send(finder, *args, &block)

            # magic counting for user convenience:
            pager.total_entries = count_for_pagination(count_options, args, finder) unless pager.total_entries
          end
        end 
        protected       
          # Does the not-so-trivial job of finding out the total number of entries
          # in the database. It relies on the ActiveRecord +count+ method.
          def count_for_pagination(options, args, finder)
            excludees = [:count, :order, :limit, :offset, :readonly]
            unless options[:select] and options[:select] =~ /^\s*DISTINCT\b/i
              excludees << :select # only exclude the select param if it doesn't begin with DISTINCT
            end
            # count expects (almost) the same options as find
            count_options = options.except *excludees

            # merge the hash found in :count
            # this allows you to specify :select, :order, or anything else just for the count query
            count_options.update options[:count] if options[:count]

            # we may have to scope ...
            counter = Proc.new { count(count_options) }

            # we may be in a model or an association proxy!
            klass = (@owner and @reflection) ? @reflection.klass : self

            count = if finder.index('find_') == 0 and klass.respond_to?(scoper = finder.sub('find', 'with'))
                      # scope_out adds a 'with_finder' method which acts like with_scope, if it's present
                      # then execute the count with the scoping provided by the with_finder
                      send(scoper, &counter)
                    elsif match = /^find_(all_by|by)_([_a-zA-Z]\w*)$/.match(finder)
                      # extract conditions from calls like "paginate_by_foo_and_bar"
                      attribute_names = extract_attribute_names_from_match(match)
                      conditions = construct_attributes_from_arguments(attribute_names, args)
                      with_scope(:find => { :conditions => conditions }, &counter)
                    else
                      counter.call
                    end

            count.respond_to?(:length) ? count.length : count
          end

          def parse_pagination_options(options) #:nodoc:
            raise ArgumentError, 'parameter hash expected' unless options.respond_to? :symbolize_keys
            options = options.symbolize_keys
            raise ArgumentError, ':page parameter required' unless options.key? :page

            if options[:count] and options[:total_entries]
              raise ArgumentError, ':count and :total_entries are mutually exclusive'
            end

            page     = options[:page] || 1
            per_page = options[:per_page] || self.default_per_page
            total    = options[:total_entries]
            [page, per_page, total]
          end        
      end
    end
  end
end
