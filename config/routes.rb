DiscoApp::Engine.routes.draw do

  controller :webhooks do
    post 'webhooks' => :process_webhook, as: :webhooks
  end

  namespace :charges do
    controller :charges do
      get 'new' => :new, as: :new_charge
      post 'create' => :create, as: :create_charge
      get 'accept' => :accept, as: :accept_charge
      get 'activate' => :activate, as: :activate_charge
    end
  end

  namespace :install do
    controller :install do
      get 'install' => :install, as: :install
      get 'installing' => :installing, as: :installing
      get 'uninstalling' => :uninstalling, as: :uninstalling
    end
  end

end