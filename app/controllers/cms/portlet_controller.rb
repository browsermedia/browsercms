class Cms::PortletController < Cms::BaseController
  
  before_filter :load_portlet
  
  def self.redirect_action(name, &block)
    define_method(name) do
      begin
        instance_eval &block
        redirect_to_success_url
      rescue Exception => e
        logger.warn "#{e.class}: #{e.message}\n#{e.backtrace.join("\n")}"
        store_params_in_flash
        redirect_to_failure_url
      end
    end
  end
  
  protected
    def load_portlet
      @portlet = Portlet.find(params[:id])
    end
    
    # This will copy all the params from this request into the flash.
    # The key in the flash with be the portlet instance_name and
    # the value will be the hash of all the params, except the params
    # that have values that are a StringIO or a Tempfile will be left out.
    def store_params_in_flash
      flash[@portlet.instance_name] = params.inject(HashWithIndifferentAccess.new) do |p,(k,v)|
        unless StringIO === v || Tempfile === v
          p[k.to_sym] = v
        end
        p
      end
    end
  
    # This will redirect to the first non-blank url
    # If all are blank, then it will redirect to the referer
    def redirect_to_url_or_referer(*urls)
      urls.each do |url|
        unless url.blank?
          return redirect_to(url)
        end
      end
      redirect_to request.referer
    end

    def redirect_to_success_url
      redirect_to_url_or_referer params[:success_url], @portlet.success_url
    end
    
    def redirect_to_failure_url
      redirect_to_url_or_referer params[:failure_url], @portlet.failure_url
    end
    
end