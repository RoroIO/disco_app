require 'test_helper'

class DiscoApp::ChargesControllerTest < ActionController::TestCase
  include ActiveJob::TestHelper

  def setup
    @shop = disco_app_shops(:widget_store)
    @current_subscription = disco_app_subscriptions(:current_widget_store_subscription)
    @routes = DiscoApp::Engine.routes
    log_in_as(@shop)
    @shop.installed!
  end

  def teardown
    @shop = nil
    @current_subscription = nil
  end

  test 'non-logged in user is redirected to the login page' do
    log_out
    get(:new, subscription_id: @current_subscription)
    assert_redirected_to ShopifyApp::Engine.routes.url_helpers.login_path
  end

  test 'logged-in, never installed user is redirected to the install page' do
    @shop.never_installed!
    get(:new, subscription_id: @current_subscription)
    assert_redirected_to DiscoApp::Engine.routes.url_helpers.install_path
  end

  test 'logged-in, installed user with paid-for current subscription can not access page' do
    get(:new, subscription_id: @current_subscription)
    assert_redirected_to Rails.application.routes.url_helpers.root_path
  end

  test 'logged-in, installed user with unpaid current subscription can access page' do
    @current_subscription.accepted_charge.destroy
    get(:new, subscription_id: @current_subscription)
    assert_response :ok
  end

end
