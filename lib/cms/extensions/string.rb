module Cms
  module Extensions
    module String
      def indent(n=0)
        (" "*n.to_i) + self 
      end
      def markdown
        Cms.markdown? ? Markdown.new(self).to_html : "<strong>ERROR</strong>: Markdown Support Not Installed"   
      end 
      def to_slug
        gsub(/\W+/, ' ').strip.downcase.gsub(/\ +/, '-')
      end  
      def pluralize(count=nil)
        count == 1 ? self : ActiveSupport::Inflector.pluralize(self)
      end
    end
  end
end
String.send(:include, Cms::Extensions::String)