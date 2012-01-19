QueryReviewer::SqlQuery.class_eval do

  # Hack to prevent nil pointer errors from occuring on pages when queryanalyzer is on.
  def table
    return @subqueries.first.table unless @subqueries.empty?
    "fake_table"
  end

end