module DiscoApp::Concerns::AuthenticatedController
  extend ActiveSupport::Concern
  include ShopifyApp::LoginProtection

  included do
    before_action :auto_login
    before_action :login_again_if_different_shop
    before_action :shopify_shop
    before_action :check_installed
    before_action :check_current_subscription
    before_action :check_active_charge
    around_filter :shopify_session
    layout 'embedded_app'
  end

  private

    def auto_login
      if shop_session.nil? and hmac_valid?(request.query_string, ShopifyApp.configuration.secret)
        session[:shopify] = DiscoApp::Shop.find_by!(shopify_domain: request.params[:shop]).id
      end
    end

    def shopify_shop
      if shop_session
        @shop = DiscoApp::Shop.find_by!(shopify_domain: @shop_session.url)
      else
        redirect_to_login
      end
    end

    def check_installed
      if @shop.awaiting_install? or @shop.installing?
        redirect_if_not_current_path disco_app.installing_path
        return
      end
      if @shop.awaiting_uninstall? or @shop.uninstalling?
        redirect_if_not_current_path disco_app.uninstalling_path
        return
      end
      unless @shop.installed?
        redirect_if_not_current_path disco_app.install_path
      end
    end

    def check_current_subscription
      unless @shop.current_subscription?
        redirect_if_not_current_path disco_app.new_subscription_path
      end
    end

    def check_active_charge
      if @shop.current_subscription? and @shop.current_subscription.requires_active_charge? and not @shop.development? and not @shop.current_subscription.active_charge?
        redirect_if_not_current_path disco_app.new_subscription_charge_path(@shop.current_subscription)
      end
    end

    def redirect_if_not_current_path(target)
      if request.path != target
        redirect_to target
      end
    end

    def hmac_valid?(params, secret)
      DiscoApp::RequestValidationService.hmac_valid?(params, secret)
    end
end
