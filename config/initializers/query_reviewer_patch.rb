# This doesn't do anything in this directory anymore since test/dummy is the app now.

# If we are using QueryReviewer, we need to patch it to avoid the sitemap blowing up.
if defined?(QueryReviewer)

  QueryReviewer::SqlQuery.class_eval do
    # Hack to prevent nil pointer errors from occuring on pages when queryanalyzer is on.
    def table
      return @subqueries.first.table unless @subqueries.empty?
      "fake_table"
    end

  end
end