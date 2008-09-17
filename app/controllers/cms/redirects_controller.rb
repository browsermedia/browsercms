class Cms::RedirectsController < Cms::ResourceController 
  layout 'cms/administration'
  protected
    def show_url
      index_url
    end
    
    def order_by_column
      "from_path, to_path"
    end
end