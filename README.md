# DiscoApp Rails Engine
A Rails Engine encapsulating common functionality for Disco's Shopify
applications.

Aims to make it a cinch to get a new Shopify application up and running, as
well as providing common functionality in a single codebase.

- [Getting Started](#getting-started)
- [Engine Overview](#engine-overview)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)


## Getting Started
Spinning up a new Shopify app with this engine is a simple four-step process,
detailed below.


### 1. Setting up
First make sure you've got all of the tools you need for Shopify and Rails
development. You should read through the [General Development][] and
[Rails Development][] sections on the Disco documentation site. The key things
to note are:

- You should have set up a Shopify Partner account to allow you to create
  development stores and applications;
- [rbenv][] is recommended for Ruby version management;
- You should have the latest version of Ruby 2.3.3 installed locally, along with
  the `rails` and `bundler` gems;
- You should have some form of HTTP tunnelling software like [ngrok][] or
  [localtunnel][] installed.

[General Development]: https://github.com/discolabs/docs/blob/master/sections/development.md#general-development
[Rails Development]: https://github.com/discolabs/docs/blob/master/sections/development.md#rails-development
[rbenv]: https://github.com/sstephenson/rbenv
[ngrok]: https://ngrok.com
[localtunnel]: http://localtunnel.me

### 2. Creating the Rails app
Running the following commands from your terminal to create a new Rails app,
add the DiscoApp Rails Engine to your Gemfile, and set up the Engine:

```
$ export DISCO_GEM_CREDENTIALS=disco-gems:0dfbd458c126baa2744cef477b24c7cf7227fae5
$ mkdir example_app
$ cd example_app
$ echo "source 'https://rubygems.org'" > Gemfile
$ echo "gem 'rails', '~> 4.2'" >> Gemfile
$ echo "2.3.3" > .ruby-version
$ bundle install
$ bundle exec rails new . --force --skip-bundle
$ echo "gem 'disco_app', git: 'https://$DISCO_GEM_CREDENTIALS@github.com/discolabs/disco_app.git', tag: '0.13.6'" >> Gemfile
$ bundle update
$ bundle exec rails generate disco_app --force
$ bundle install
```

Note the `tag` option being added to the Gemfile - this pins the version of
DiscoApp you'll be using and avoid accidentally pulling incompatible changes
into your project when you run a `bundle update`. Double check that the tag
number you're using is the latest version available.

Once this is complete, you'll have a new Rails app created in `/example_app`,
with the DiscoApp Engine configured and mounted.

### 3. Setting up the Shopify app
In order to work on our app, we need to create a development application from
the Shopify Partners dashboard. Once that's done, we can copy across the
generated API credentials to our development app and perform a test install.

DiscoApp provides a command line utility to quickly generate a new Shopify
app via the partner dashboard. Before you can do this, you need to configure
a couple of things.

#### Create a DiscoApp configuration file in your home directory
First, you'll need to add your partner dashboard credentials to a DiscoApp
configuration file in your home directory, `~/.disco_app.yml`:

```
params:
  PARTNER_EMAIL: "hello@discolabs.com"
  PARTNER_PASSWORD: "***********"
  PARTNER_ORGANISATION: "Disco"
```

You'll only need to set this up the one time on your local machine.

#### Configure initial values in local ENV file
Next, you'll need to set a few of the basic configuration parameters for your
app in `.env.local` in the application directory. The command line utility
will use these to configure your app.

You'll need to set values for `DEFAULT_HOST` (the base URL for your application,
for example `https://example-app.ngrok.io`) and for `SHOPIFY_APP_NAME` (the name
of the application).

#### Creating and configuring your app
With the above set up, you can now run the following from the command line to
create a new app:

```
bundle exec rake generate:partner_app
```

The `.env.local` will be automatically populated with values for
`SHOPIFY_APP_API_KEY` and `SHOPIFY_APP_SECRET`.

While the `.env.local` file is open, add in values for`SHOPIFY_APP_PROXY_PREFIX`
and `SHOPIFY_APP_SCOPE` (view a [list of scopes][]).

The `SHOPIFY_CHARGES_REAL`, `SECRET_KEY_BASE` and `REDIS_PROVIDER` values can be
left blank in development.

When you're done, your `.env.local` file should look something like this:

```
DEFAULT_HOST=https://example.ngrok.io

SHOPIFY_APP_NAME=Example App
SHOPIFY_APP_API_KEY=ebef81bcfe2174ff2c6e65f5c0a0ba50
SHOPIFY_APP_SECRET=d5e1347de6352cb778413654e1296dde
SHOPIFY_APP_REDIRECT_URI=https://example.ngrok.io/auth/shopify/callback
SHOPIFY_APP_SCOPE=read_products,write_script_tags
SHOPIFY_APP_PROXY_PREFIX=/a/example

SHOPIFY_CHARGES_REAL=

SECRET_KEY_BASE=

REDIS_PROVIDER=
```

Notice that `.env.local` should not be added to Git, and is therefore
added to `.gitignore`. On the other side, `.env` is added to Git and should keep
all the environment variables that are kept equal across the different environments.

[list of scopes]: https://docs.shopify.com/api/authentication/oauth#scopes

### 4. Putting it all together
Finally, we're ready to test the installation of the development app. First,
fire up your tunneling software to proxy requests to port 3000 on your local
machine. For example, if using ngrok:

```
$ ngrok http -subdomain=example 3000
```

In another terminal window, start up the Rails webserver. The DiscoApp
generator provides a Rake task to easily start the server:

```
$ rake start
```

Now you should be able to visit the root URL of your app in the browser (eg
`https://example.ngrok.io`) and be presented with the login screen. Enter the
name of a development Shopify store, and you should be taken through the
process of authorising and installing the application to the store.

If you don't have a development store to test with, you can create one from the
Shopify Partner dashboard in a similar manner to creating a development app.

***Note:*** It's important to access your local development app via SSL (ie,
`https://example.ngrok.io` rather than `http://example.ngrok.io`. Otherwise,
the URLs generated during the OAuth flow won't match your application settings
and you won't be able to install the app.


## Engine Overview
The DiscoApp Rails Engine incorporates and extends the functionality provided
by the ShopifyApp Rails Engine, which is an official gem developed by Shopify.

### Environment and Configuration
The following gems are added during setup:

- [shopify_app][] for basic Shopify application functionality;
- [puma][] for serving the app in development and production;
- [sidekiq][] for background job processing in production;
- [pg][] for Postgres use in all environments: development, test and production;
- [dotenv-rails][] for reading environment variables from `.env` files in
  development;
- [rails_12factor][] for use with Heroku/Dokku in production.
- [activeresource][] , the threadsafe branch, which is used by the Shopify API gem.
- [mailgun_rails][] for sending email programatically via the Mailgun service.
- [premailer_rails][] support for styling HTML emails with CSS
- [rollbar][] Exception tracking and logging
- [newrelic_rpm][] New Relic RPM Ruby Agent

The following configuration changes are made:

- Force SSL in production;
- Use Sidekiq as the `ActiveJob` queue adapter in production;
- Set the default host in the router to allow absolute URL reversal;
- Turn off prepared statements for Postgres databases.

Finally, the following environment changes are made:

- Add `.ruby-version` file and update Gemfile to lock down Ruby version being
  used;
- Add default `.env` and `.env.local` files for development environment
  management;
- Add a `Procfile` for deployment to Heroku;
- Add a `CHECKS` file for use with Dokku deployments
- Update the `.gitignore` with some additional useful defaults.

[shopify_app]: https://github.com/Shopify/shopify_app
[puma]: http://puma.io/
[sidekiq]: http://sidekiq.org/
[pg]: https://bitbucket.org/ged/ruby-pg
[dotenv-rails]: https://github.com/bkeepers/dotenv
[rails_12factor]: https://github.com/heroku/rails_12factor
[activeresource]: https://github.com/Shopify/activeresource/tree/4.2-threadsafe
[mailgun_rails]: https://github.com/jorgemanrubia/mailgun_rails
[premailer_rails]: https://github.com/fphilipe/premailer-rails
[rollbar]: https://github.com/rollbar/rollbar-gem
[newrelic_rpm]: https://github.com/newrelic/rpm

### Authentication, Sessions and the Shop Model
The functionality provided by the ShopifyApp engine includes support for OAuth
authentication and storing session information in a `Shop` model. The gem also
provides a `SessionsController` which is used to log in and authenticate with
Shopify.

During installation and setup, a `DiscoApp::Shop` model is created, which stores
the domain name and API token for a shop that installs the app, along with a
number of other attributes such as email address, country, Shopify plan type,
et cetera.

### User Authentication
In addition to providing built-in OAuth authentication at the Shop level by
default, the gem allows you to enforce authentication at the user level.

To use this functionality, you will need to include the
`DiscoApp::Concerns::UserAuthenticatedController` concern on any controller
that requires an authenticated user. Once authenticated, this concern will
ensure a `@user` instance variable is present on the controller.

You will also need to replace the contents of `config/initializer/omniauth.rb`
with the below code:

```
module OmniAuth::Strategies
  class ShopifyUser < Shopify
    def name
      :shopify_user
    end
  end
end

SETUP_PROC = lambda do |env|
  env['omniauth.strategy'].options[:per_user_permissions] = true
  params = Rack::Utils.parse_query(env['QUERY_STRING'])
  env['omniauth.strategy'].options[:client_options][:site] = "https://#{params['shop']}"
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :shopify,
    ShopifyApp.configuration.api_key,
    ShopifyApp.configuration.secret,
    scope: ShopifyApp.configuration.scope
  provider :shopify_user,
  	ShopifyApp.configuration.api_key,
    ShopifyApp.configuration.secret,
    scope: ShopifyApp.configuration.scope,
    setup: SETUP_PROC
end
```

### Plans, Subscriptions, and Charges
The gem provides a framework for billing merchants for the use of applications.
This framework consists of plans, subscriptions, plan codes, and charges.

**Plans** represent the different pricing levels you can offer your merchants.
They are configurable from the application admin pages (if enabled for the app
in question), allowing application owners to set different prices, trial
periods, and charging patterns.

**Subscriptions** are the mapping between a particular shop and their current
plan. A shop can only have a single active subscription at a time.

**Plan Codes** belong to a particular plan, and allow for a particular store to
have their subscription to a plan adjusted or discounted. For example, if you
have a "Premium" plan, you might add a Plan Code to it with a code `PODCAST` for
your podcast listeners that reduces the monthly price by 10% and extends the
trial period to 60 days.

**Charges** are a local representation of the Shopify charge objects that are
created and approved by merchants. The appropriate charge object is generated
based on a current store's subscription.

The `DiscoApp::Concerns::AuthenticatedController` concern (which should be
included by all embedded application controllers in an app) performs a series of
checks to make sure that the current user is able to access the insides of the
page. It:

- Checks the shop has an authenticated session. If not, redirects to the OAuth
  authentication flow provided by the `ShopifyApp` gem;
- Checks the shop has completed the installation steps. If not, redirects to
  begin the installation process.
- Checks the shop has a currently active subscription. If not, redirects to the
  new subscription selection controller.
- Checks the currently active subscription has a valid, active charge (or that
  the currently active subscription doesn't require a charge, as may happen when
  the amount to be charged is zero). If not, redirects to begin the charge
  approval process for the current subscription.

If you're building an app that doesn't need to worry about charging store
owners, you should ensure it creates a Plan with an `amount` value of zero, and
that all stores are subscribed to that plan during `DiscoApp::AppInstalledJob`.

The default set of plans for your app should be placed into the `db/seeds.rb`
file. Make sure you run `bundle exec rake db:seed` after resetting your database
to ensure the plans are correctly set up.

Whenever a store's subscription level is changed,
`DiscoApp::SubscriptionChangedJob` is queued.

### Rake Tasks
There's a number of useful Rake tasks that are baked into the app. They are:

- `rake start`: Spin up a local Puma development server, bound correctly to the
  local IP.
- `rake webhooks:sync`: Trigger a re-synchronisation of webhooks for all
  shops on active Shopify plans and with the application currently installed.
- `rake database:update_sequences`: Update postgres sequence numbers in case
  the database has been imported or migrated.
- `rake shops:sync`: Synchronises shop data across all installed shops.
- `rake users:sync`: Synchronises user data across all installed shops.

### Background Tasks
The `DiscoApp::ShopJob` class inherits from `ActiveJob::Base`, and can be used
to queue jobs that need to take place in the API context of a particular shop.
This means that inside the `perform` method of a `ShopJob`, all API calls will
automatically be made on behalf of the shop, like so:

```
class FindAllProductsJob < DiscoApp::ShopJob
  def perform(_shop)
    ShopifyAPI::Product.find(:all)
  end
end
```

Note that the first argument of the `perform` method on any job inheriting from
`DiscoApp::ShopJob` **must always** provide the shop context the job is
executing in (the `shop` argument above). This can be done *either* by providing
a `DiscoApp::Shop` instance directly (preferable) *or* by providing the Shopify
domain of the shop as a string (eg `example.myshopify.com`).

The gem includes some default jobs that are queued during installation or after
specific webhooks are received. They are:

- `DiscoApp::AppInstalledJob`, triggered when the application is installed. By
  default, this job uses the Shopify API to set up webhooks and to perform
  initial data synchronisation.
- `DiscoApp::AppUninstalledJob`, triggered when the `app/uninstalled` webhook is
  received. By default, this job simply updates the `status` flag on the
  `DiscoApp::Shop` model, but you may wish to add tasks like sending a
  cancellation email or the like.
- `DiscoApp::ShopUpdateJob`, triggered when the `shop/update` webhook is
  received. By default, this task keeps the metadata attributes on the relevant
  `DiscoApp::Shop` model up to date.
- `DiscoApp::SubscriptionChangedJob`, called whenever a shop changes the plan
  that they are subscribed to.  
- `DiscoApp::SynchroniseWebhooksJob`, called by the installation job but also
  enqueued by the `webhooks:sync` rake task to allow for re-synchronisation of
  webhooks after installation.
- `DiscoApp::SynchroniseCarrierServiceJob`, called by the installation job but
  also enqueued by the `carrier_service:sync` rake task to allow for
  re-synchronisation of the carrier service after installation.  

The default jobs that come with the engine can be extended through the use of
Concerns in a similar way to the models that come with the engine. See
[Extending Models][] below.

[Extending Models]: #extending-models

Additionally, the gem includes `DiscoApp::SynchroniseResourcesJob`. It takes a
synchronisable class name (like Product) and a params hash, which it then uses
to fetch a list of resources via the API. So if we wanted to synchronise
products with the ids 123, 456 and 789, we could do:

```
DiscoApp::SynchroniseResourcesJob.perform_later(shop, 'Product', ids: '123,456,789')
```

### Webhooks
As you may have noticed from the preceding section, webhooks and background
tasks are closely linked. The DiscoApp Engine routes requests to `/webhooks`
to the `process_webhook` method on `DiscoApp::WebhooksController`.

When the controller receives an inbound webhook, it is automatically verified
using the application's secret key. The controller then attempt to queue a job
matching the topic name of the incoming webhook (eg `app/uninstalled` will try
to queue a job named `DiscoApp::AppUninstalledJob`). Two arguments will be
passed to the job's `perform` method: the domain of the shop the webhook was
related to, and the JSON payload of the webhook as a hash.

There shouldn't be any need to extend or override `DiscoApp::WebhooksController`
inside an application - all application logic should simply be placed inside the
relevant `*Job` class.

Webhooks should generally be created inside the `perform` method of the
`DiscoApp::AppInstalledJob` background task. By default, webhooks are set up to
listen for the `app/uninstalled` and `shop/update` webhook topics.

### Asset Rendering
It's a pretty common pattern for apps to want to render and update Shopify
assets (Javascript, stylesheets, Liquid snippets etc) whenever a store owner
makes particular changes to a configuration object. To make this pattern easy
to implement, the gem provides a `renders_assets` macro, which you can use to
define one or more "asset groups" to render when particular attributes on a
model change. Here's an example:

```
# app/models/widget_configuration.rb
class WidgetConfiguration < ActiveRecord::Base
  include DiscoApp::Concerns::RendersAssets  
  renders_assets :js_asset, assets: 'assets/widgets.js', triggered_by: 'locale'  
end   
```

With this simple declaration, any time the `locale` attribute on a particular
`WidgetConfiguration` model changes, an asset template (in this case, located at
`app/views/assets/widgets.js.erb`) will be freshly rendered and and uploaded to
the current Shopify theme as `assets/widgets.js`. The template itself might look
like this:

```
// app/views/assets/widgets.js.erb
(function() {
  var locale = '<%= @widget_configuration.locale %>';
})();
```

Both the `assets:` and `triggered_by:` options handle lists, so you can specify
more than one asset to render and more than one triggering attribute. What's
more, if you specify a list of `assets:`, then the public CDN url of assets
earlier in the list will be available in the templates of subsequent assets,
like this:

```
# app/models/widget_configuration.rb
class WidgetConfiguration < ActiveRecord::Base
  include DiscoApp::Concerns::RendersAssets  
  renders_assets :widget_assets, assets: ['assets/widgets.scss', 'assets/widgets.js'], triggered_by: ['locale', 'background_color']  
end
```

```
// app/views/assets.widgets.scss.erb
#widget {
  background-color: <%= @widget_configuration.background_color %>;
}
```

```
// app/views/assets/widgets.js.erb
var locale = '<%= @widget_configuration.locale %>';
var cssUrl = '<%= @public_urls[:'assets/widget.scss'] %>';
```

Finally, you can pass the name of one or more Javascript assets in a
`script_tags:` option. If specified, the asset renderer will ensure that a
Shopify script tag resource is created (or updated) pointing to your newly
rendered asset:

```
# app/models/widget_configuration.rb
class WidgetConfiguration < ActiveRecord::Base
  include DiscoApp::Concerns::RendersAssets  
  renders_assets :widget_assets, assets: ['assets/widgets.scss', 'assets/widgets.js'], script_tags: 'widgets.js', triggered_by: ['locale', 'background_color']  
end
```

### Application Proxies
The gem provides support for Shopify's [Application Proxy][] functionality
through a controller concern named `DiscoApp::Concerns::AppProxyController`. Including
this concern on any controller will automatically verify each incoming request
to make sure it's coming from Shopify (see the [security section][]) in the
Shopify documentation. Note that by default this check is only performed in
production environments.

The `DiscoApp::Concerns::AppProxyController` also alters the response headers to return
an `application/liquid` MIME type by default, to allow the processing of Liquid
by Shopify before returning the response to the user. If you'd like to return
plain HTML and avoid Liquid processing, you can add a `skip_after_action`
directive on your controller targeting the `:add_liquid_header` method.

Here's an example controller using the concern, that will return plain HTML
from its `index` action and Liquid from its `show` action:

```ruby
class MarblesController < ApplicationController
  include DiscoApp::Concerns::AppProxyController

  skip_after_action :add_liquid_header, only: [:index]

  def index
    @marbles = Marble.all
  end

  def show
    @marble = Marble.find(params[:id])
  end
end
```

Note that in this instance it's important that `ApplicationController` doesn't
perform any login authentication, as no session information is made available
in proxied requests.

[Application Proxy]: https://docs.shopify.com/api/uiintegrations/application-proxies
[security section]: https://docs.shopify.com/api/uiintegrations/application-proxies#security

### Models in Liquid
If you're making use of an application proxy, you'll often want to provide data
from one or more of your application's models to a Liquid template. In fact,
we've generally found that the best pattern for app serving app proxy pages is
for the app to return a Liquid template with no HTML at all - only relevant data
and an `{% include 'some-snippet' %}` call.

This pattern allows the complete customisation of front end pages via the shop's
theme, placing control of the appearance of your app's pages squarely under the
control of the merchant. Your application can (in fact, it should) render some
default snippets into the theme on installation to give merchants something that
works out of the box.

To make the process of providing model data to Liquid templates, the DiscoApp
Engine provides the `DiscoApp::Concerns::CanBeLiquified` concern. It will use
the model's `as_json` method to get a list of serialised attributes for your
model and returns the necessary Liquid `{% assigns %}` tags to provide that data
inside a template.

As an example, if you had a model `MyModel` that you wanted to render via an
application proxy, you would have the following in your application's
`app/models/my_model.rb`:

```
class MyModel < ActiveRecord::Base
  include DiscoApp::Concerns::CanBeLiquified

  ... rest of model definition ...  
end
```

with this in your application's `app/views/my_model/show.html.erb`:

```
<%= raw @my_model.to_liquid %>
{% include 'my_model-show' %}
```

and finally something like this in your theme's `snippets/my_model-show.liquid`:

```
{% layout 'theme' %}
<h1>{{ my_model_name }}</h1>
<p>
  {{ my_model_description }}
</p>
```

### Administration
There is a standard administration site for the app, located at `/admin`. It
provides a filtered list of shops that have installed the app, a way to manage
plans and plan codes for the application, and a page to manage application-wide
settings.

This admin section is secured via HTTP basic authentication. In order to define
the username and password to access this section of the app, fill in the
following variables to the generated app `.env.local` file:

```
ADMIN_APP_USERNAME=
ADMIN_APP_PASSWORD=
```

Application-wide settings should be added to the `DiscoApp::AppSettings` model.
At the controller level you can can permit the new params by overriding the
admin controller at: `app/controllers/disco_app/admin/app_settings_controller.rb`.

```
class DiscoApp::Admin::AppSettingsController < DiscoApp::Admin::ApplicationController
  include DiscoApp::Admin::Concerns::AppSettingsController

  private

    def app_settings_params
      params.require(:app_settings).permit(:default_recurring_price, :trial_days, :test_charges, :mailchimp_api_key, :mailchimp_list_id, :sidebar_message_enabled, :sidebar_message)
    end

end
```

At the view level, you should override `app/views/disco_app/admin/app_settings/edit.html.erb`
in order to add fields for the new settings you've created.


### Helpers
A number of view helpers designed to encapsulate common Shopify app
functionality are included with the gem and are automatically imported and made
available from within the main application helper.

#### link_to_shopify_admin
Generates a link pointing to an object (such as an order or customer) inside the
given shop's Shopify admin. This helper makes it easy to  create links to
objects within the admin that support both right-clicking and opening in a new
tab as well as capturing a left click and redirecting to the relevant object
using `ShopifyApp.redirect()`.

```erb
<%= link_to_shopify_admin(@shop, 'Order 1234', "orders/1234") %>
```

#### link_to_modal
Generates a link that will open its given `href` inside an embedded Shopify
model.

#### react_component_with_content
Renders a react component with inner HTML content.

#### errors_to_react
Provides detailed information from an ActiveRecord to JSON object. Useful for
passing the information into React components.

```erb
  <%= react_component('ExampleResourceForm', @example_resource.as_json.merge({
    errors: errors_to_react(@example_resource)
  })) %>
```

### Extending Models
The models that come with the `DiscoApp` engine (such as `DiscoApp::Shop`) can
be extended through the use of Rails Concerns (see [Overriding Models][] in the
official Rails Guides for an idea how this works).

Here's the example used inside the "dummy" app used for testing the engine:

```ruby
require 'active_utils'

class DiscoApp::Shop < ActiveRecord::Base
  include DiscoApp::Concerns::Shop

  # Extend the Shop model to return the Shop's country as an ActiveUtils country.
  def country
    begin
      ActiveUtils::Country.find(data[:country_name])
    rescue ActiveUtils::InvalidCountryCodeError
      nil
    end
  end

end
```

[Overriding Models]: http://edgeguides.rubyonrails.org/engines.html#overriding-models-and-controllers

### Synchronising Models
In many situations, it's useful to store a version of a Shopify resource in our
application's local database. Disco App provides a way to simplify the process
of keeping this local version in sync with the version on Shopify with a concern
(`DiscoApp::Concerns::Synchronises`).

The steps below walk you through what you need to do for the implementation of
synchronisation of product resources as an example. You can also refer to the
implementation of this inside the dummy app used for testing Disco App in
`test/dummy/app/models/product.rb` and `test/dummy/app/jobs/products_*.rb`.

1. Create a local model to represent the resource, for example a `Product`
   model. Make sure it includes a `shop_id` foreign key referencing its owning
   `DiscoApp::Shop` and a `data` attribute with a JSONB datatype.
2. Include the `Synchronises` concern to the model class, along with the
   `belongs_to` association:

   ```ruby
   class Product < ActiveRecord::Base
     include DiscoApp::Concerns::Synchronises  
     belongs_to :shop, class_name: 'DiscoApp::Shop'  
   end
   ```
3. Add background jobs to handle possible webhook calls we could receive to keep
   the information updated (eg `products/create`, `products/update`,
   `products/delete`) and ensure these webhooks are registered on application
   installation. Implement these jobs to simply call the `synchronise` or
   `synchronise_deletion` method as appropriate, eg:

   ```ruby
   class ProductsCreateJob < DiscoApp::ShopJob   
     def perform(_shop, product_data)
       Product.synchronise(@shop, product_data)
     end
   end
   ```
4. You may want to perform an initial synchronisation of resources. To do this,
   the `Synchronises` concern provides a `synchronise_all` method. For this to
   work, you must define a `SHOPIFY_API_CLASS` constant on your model class, for
   example:

   ```
   class Product < ActiveRecord::Base
      include DiscoApp::Concerns::Synchronises  
      belongs_to :shop, class_name: 'DiscoApp::Shop'
      SHOPIFY_API_CLASS = ShopifyAPI::Product
   end
   ```

   You can then call the synchronisation with `Product.synchronise_all(shop)`.

This should be all you need to do to have your local models stay up to date with
any changes made by the store owner on Shopify. If needed, you can override the
individual `should_synchronise?`, `synchronise`, `should_synchronise_deletion?`
and `synchronise_deletion` class methods on your model. For example, if you only
wanted to synchronise products of a particular type, you could implement:

```ruby
class Product < ActiveRecord::Base
  include DiscoApp::Concerns::Synchronises  
  belongs_to :shop, class_name: 'DiscoApp::Shop'

  def should_synchronise?(shop, data)
    data[:product_type] == 'Shoes'
  end
end
```

### Model Primary Keys
We use the `rails-bigint-pk` gem in order to default to 64-bit integer IDs in
our models (the Rails default is 32-bit). This allows us to have a 1:1 mapping
on the `id` column between our application and Shopify, which uses 64-bit
integers for their IDs.

On installation, the `rails-bigint-pk` gem migrates all existing models to use
the `bigint` type for the `id` field, and adds a `bigint_pk.rb` initializer
which ensures `bigint` is used in all future migrations automatically. To make
sure that this all works okay, make sure you use the `references` keyword in
your migrations, rather than `integer`. If you do for some reason need to
manually create columns storing references to other models, make sure you use
`limit: 8` in the column definition.

### Model Metafields
If you're writing resource metafields for your models via the Shopify API, you
can include `DiscoApp::Concerns::HasMetafields` to gain access to a convenient
`write_metafields` method. Just make sure that `SHOPIFY_API_CLASS` is defined
on your class and away you go:

```
class Product < ActiveRecord::Base  
  include DiscoApp::Concerns::HasMetafields

  SHOPIFY_API_CLASS = ShopifyAPI::Product

end

@product = Product.find(12345678)
@product.write_metafields(
  namespace1: {
    key1: 'value1',
    key2: 'value2
  },
  namespace2: {
    key3: 'value3'
  }
)
```

### Rubocop
DiscoApp adds support for Rubocop and Codeclimate. the .rubocop.yml contains the
configuration you can tweak to suits your coding style, by enabling/disabling
"Cops" accordingly.

### Email Support
DiscoApp has support for the Mailgun and configures Active Mailer to use the
Mailgun API in production for sending email. Adds the `MAILGUN_API_KEY` and
`MAILGUN_API_DOMAIN` environment variables.

### Monitoring
DiscoApp has support for both exception reporting and application performance
monitoring to the application.

[Rollbar][] is used for exception tracking, and will be activated when a
`ROLLBAR_ACCESS_TOKEN` environment variable is present. Rollbar access tokens
are unique to each app - if you're deploying a new app and don't have a token,
ask Gavin for one.

[New Relic][] is used for application performance monitoring, and will be
activated when a `NEW_RELIC_LICENSE_KEY` environment variable is present. There
is a single New Relic license key across all Disco apps - contact Gavin if you
need it to deploy a new application.

[Rollbar]: https://www.rollbar.com
[New Relic]: https://www.newrelic.com


## Upgrading
To upgrade your application from a previous version of the gem, these are the
steps you should take:

- Update the `disco_app` entry in your `Gemfile` to point to the latest tagged
  release of the gem (check the [release list][] to find the latest available
  version).
- Run `bundle update`. You may have to resolve some gem dependencies.
- Run `bundle exec rake disco_app:install:migrations` to copy over any new
  migrations from the gem into your application, ready to be run with a
  `bundle exec rake db:migrate`.
- Carefully read through `CHANGELOG.md`, `UPGRADING.md`, and the commit history
  for `disco_app` between the previous version of the gem you were using and the
  new one. You may have to make some changes to your application code to adapt
  to change.

[release list]: https://github.com/discolabs/disco_app/releases

## Troubleshooting
A list of common problems folks encounter when setting up or building apps with
DiscoApp.

### During install: Nokogiri / libxml2 reported missing
Try the following:

```
$ xcode-select --install
$ gem install nokogiri -- --use-system-libraries --with-xml2-include=/usr/include/libxml2 --with-xml2-lib=/usr/lib/
```

### During install: General
Try the following to restart Spring:

```
$ spring stop
$ bin/spring
```

### During Oauth: Redirect URI is missing or not listed
Check that:

- You're accessing the application via HTTPS, not HTTP;
- You've correctly set `DEFAULT_HOST` in your local `ENV`;
- You've correctly listed the redirect URI in the app on the partner dashboard.

## Contributing
While developing Shopify applications using the DiscoApp Engine, you may see
something that could be improved, or perhaps notice a pattern that's becoming
common across a number of applications.

In those cases, please consider taking the time to raise an issue or pull
request against the DiscoApp repository. If contributing code, please make sure
to update the relevant section of this README as well.


## Releasing
To create a new release of the application:

1. Ensure the CHANGELOG is up to date by reviewing all commits since the last
   release;
2. Ensure the UPGRADING file contains all necessary instructions for upgrading
   an application to the latest version of the gem.
3. Ensure the README is accurate and up to date by reviewing all commits since
   the last release;
4. Update `lib/disco_app/version.rb` with the new version number;
5. Update references to the latest version number in the README;
6. Create a new commit with a commit message `vX.Y.Z`, where `X.Y.Z` is the
   version number;
7. Tag the new commit with a tag `X.Y.Z` (`git tag -a "X.Y.Z"`);
8. `git push && git push --tags` to push the new release.

See [an example release commit][].

[an example release commit]: https://github.com/discolabs/disco_app/commit/0cb60a1c212f480af85ebb7c42188befb932a818
