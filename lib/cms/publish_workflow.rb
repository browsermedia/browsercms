module Cms
  # Can be added to controllers that allow for SaveDraft/Publish
  module PublishWorkflow

    def self.included(klass)
      klass.send(:include, AllowPublishing)
    end

    module AllowPublishing
      def self.included(klass)
        klass.before_action :only => [:create, :update] do
          params[resource_param][:publish_on_save] = false if save_draft?
          params[resource_param][:publish_on_save] = true if publish?
        end
      end

      def save_draft?
        params[:commit] == "Save Draft"
      end

      def publish?
        params[:commit] == "Publish"
      end
    end
  end
end