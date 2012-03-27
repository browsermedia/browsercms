# Match a relative path (this can be improved greatly)
# i.e.
# /some-path
# /some/path
# Use like so: Given /^some (#{PATH}) step$/ do |path|
PATH = Transform /^\/\S*$/ do |path|
  path
end