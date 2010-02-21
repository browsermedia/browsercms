# Behaviors are used in CMS to add features to a model. 
# They are very similar to the various "acts_as_*" or "*_fu" plugins/gems 
# that have been created for Rails.  
#
# Generally, each behavior has three modules in it.  They are:
# * MacroMethods
# * ClassMethods
# * InstanceMethods
#
# When the CMS starts up, all of the Behaviors are included into ActiveRecord::Base.
# The MacroMethods module of each Behavior is also included into ActiveRecord::Base.
# The MacroMethods module contains Class methods that you can call within your model
# in order to enable that Behavior for that Class.  For example, if you want to have
# an Article module that is taggable, you would do this:
#
#     class Article < ActiveRecord::Base
#       is_taggable
#     end
#
# So in this case, you are calling the `is_taggable` macro method, which enables the 
# taggable behavior for the Article model.  It enables the behavior by extending the
# ClassMethods module and including the InstanceMethods module into the Article class.
# Each Behavior typically has one macro method which takes an options Hash, which of course
# varies from Behavior to Behavior.  The macro method will also sometimes call other
# macro methods, like before_fitler, scope, etc. to modify the model.
# Consult the documentation for each module for specific details as to what
# the Behavior does.
module Cms::Behaviors; end

Dir["#{File.dirname(__FILE__)}/behaviors/*.rb"].each do |b| 
  require File.join("cms", "behaviors", File.basename(b, ".rb"))
  ActiveRecord::Base.send(:include, "Cms::Behaviors::#{File.basename(b, ".rb").camelize}".constantize)
end
