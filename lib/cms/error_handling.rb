module Cms
  module ErrorHandling
    def self.included(controller)
      controller.class_eval do
        rescue_from Exception, :with => :handle_server_error unless Rails.env == "test"
        rescue_from Cms::Errors::AccessDenied, :with => :handle_internal_access_denied
      end
    end

    # Ensures the entire render stack applies a specific format
    # For example, this allows missing jpg's to throw the proper error as opposed to 500
    def with_format(format, &block)
      old_formats = self.formats
      self.formats = [format]
      result = block.call
      self.formats = old_formats
      result
    end

    def handle_server_error(exception, status=:internal_server_error)
      log_complete_stacktrace(exception)
      with_format('html') do
        render :layout => 'cms/application',
               :template => 'cms/shared/error',
               :status => status,
               :locals => {:exception => exception}
      end
    end

    def handle_internal_access_denied(exception)
      render :layout => 'cms/application',
             :template => 'cms/shared/access_denied',
             :status => 403
    end

    # Print the underlying stack trace to the logs for debugging.
    # Should be human readable (i.e. line breaks)
    # See http://stackoverflow.com/questions/228441/how-do-i-log-the-entire-trace-back-of-a-ruby-exception-using-the-default-rails-l for discussion of implementation
    def log_complete_stacktrace(exception)
      logger.error "#{exception.message}\n#{exception.backtrace.join("\n")}"
      NotifierService.notify exception
    end

    class NotifierService
      class << self
        delegate :notify, :register_notifier_call,
                 to: :service
      end

      def self.service
        @service ||= new
      end

      attr_reader :notifiers

      def initialize
        @notifiers = []

        autoload_notifiers
      end

      def notify(exception)
        notifiers.each { |notifier| notifier.call exception }
      end

      def register_notifier_call(callable_object = nil, &block)
        raise ArgumentError unless callable_object.respond_to?(:call) || block_given?
        @notifiers << callable_object || block
      end

      private

      def autoload_notifiers
        autoload_airbrake_if_present
      end

      def autoload_airbrake_if_present
        if defined?(::Airbrake)
          register_notifier_call { |exception| ::Airbrake.notify exception }
        end
      end
    end
  end
end
