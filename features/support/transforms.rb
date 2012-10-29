# Match a relative path (this can be improved greatly)
# i.e.
# /some-path
# /some/path
# Use like so: Given /^some (#{PATH}) step$/ do |path|
PATH = Transform /^\/\S*$/ do |path|
  path
end

# Allows 'should' and 'should not' to be converted to true/false.
#
# Usage: given two step definitions that look like this:
#   /I should see this/
#   /I should not see this/
# Can be combined into:
#  /I (#{SHOULD_OR_NOT}) see this/ do |should_or_not|
#    assert_equals should_or_not, value_i_expect_to_see
#  end
SHOULD_OR_NOT = Transform /^(should|should not)$/ do |should_or_should_not|
  if should_or_should_not == 'should'
    true
  else
    false
  end
end

ENABLED_OR_DISABLED = Transform /^(enabled|disabled)$/ do |enabled_or_not|
  if enabled_or_not == 'enabled'
    true
  else
    false
  end
end

module StepConversions
  def from_first_row(table)
    table.hashes.first
  end

end
World(StepConversions)