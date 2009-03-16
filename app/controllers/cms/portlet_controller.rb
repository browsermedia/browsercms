class Cms::PortletController < Cms::ApplicationController
  
  skip_before_filter :redirect_to_cms_site
  skip_before_filter :login_required
  
  before_filter :load_portlet
  
  protected
    def load_portlet
      @portlet = Portlet.find(params[:id])
    end
    
    # This will copy all the params from this request into the flash.
    # The key in the flash with be the portlet instance_name and
    # the value will be the hash of all the params, except the params
    # that have values that are a StringIO or a Tempfile will be left out.
    def store_params_in_flash
      store_hash_in_flash @portlet.instance_name, params
    end

    # This will convert the errors object into a hash and then store it 
    # in the flash under the key #{portlet.instance_name}_errors
    def store_errors_in_flash(errors)
      store_hash_in_flash("#{@portlet.instance_name}_errors", 
        errors.inject({}){|h, (k, v)| h[k] = v; h})
    end
  
    def store_hash_in_flash(key, hash)
      flash[key] = hash.inject(HashWithIndifferentAccess.new) do |p,(k,v)|
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
    
    def redirect_to_failure_url_with_errors(errors)
      store_errors_in_flash(errors)
      store_params_in_flash
      redirect_to_failure_url      
    end
    
end