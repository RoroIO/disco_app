class DiscoApp::SubscriptionsController < ApplicationController
  include DiscoApp::Concerns::AuthenticatedController

  skip_before_action :check_current_subscription

  def new
    @subscription = DiscoApp::Subscription.new
  end

  def create
    # Get the selected plan. If it's not available or couldn't be found,
    # redirect back to the plan selection page.
    if(plan = DiscoApp::Plan.available.find_by_id(subscription_params[:plan])).nil?
      redirect_to action: :new and return
    end

    # Subscribe the current shop to the selected plan. Pass along any cookied
    # plan code and source code.
    if(subscription = DiscoApp::SubscriptionService.subscribe(@shop, plan, cookies[DiscoApp::CODE_COOKIE_KEY], cookies[DiscoApp::SOURCE_COOKIE_KEY])).nil?
      redirect_to action: :new
    else
      redirect_to main_app.root_path
    end
  end

  private

    def subscription_params
      params.require(:subscription).permit(:plan, :plan_code)
    end

end
