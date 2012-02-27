# Match a relative path (this can be improved greatly)
# i.e.
# /some-path
# /some/path
PATH = Transform /^\/\S*$/ do |path|
  path
end