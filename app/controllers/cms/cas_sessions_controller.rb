module Cms
  class CasSessionsController < Devise::CasSessionsController

    # remove "You need to be signed in" error flash after you're logged in.
    before_filter :clear_flash, only: [:service]

    private
    def clear_flash
      flash.delete :alert
      true
    end
  end
end