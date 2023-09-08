module DiscoApp::ApplicationHelper

  # Generates a link pointing to an object (such as an order or customer) inside
  # the given shop's Shopify admin. This helper makes it easy to  create links
  # to objects within the admin that support both right-clicking and opening in
  # a new tab as well as capturing a left click and redirecting to the relevant
  # object using `ShopifyApp.redirect()`.
  def link_to_shopify_admin(shop, name, admin_path, options = {})
    options[:onclick] = "ShopifyApp.redirect('#{admin_path}'); return false;"
    options[:'data-no-turbolink'] = true
    link_to(name, "https://#{shop.shopify_domain}/admin/#{admin_path}", options)
  end

  # Generate a link that will open its href in an embedded Shopify modal.
  def link_to_modal(name, path, options = {})
    modal_options = {
      src: path,
      title: options.delete(:modal_title),
      width: options.delete(:modal_width),
      height: options.delete(:modal_height),
      buttons: options.delete(:modal_buttons),
    }
    options[:onclick] = "ShopifyApp.Modal.open(#{modal_options.to_json}); return false;"
    options[:onclick].gsub!(/"function(.*?)"/, 'function\1')
    link_to(name, path, options)
  end

  # Render a React component with inner HTML content.
  # Thanks to https://github.com/reactjs/react-rails/pull/166#issuecomment-86178980
  def react_component_with_content(name, args = {}, options = {}, &block)
    args[:__html] = capture(&block) if block.present?
    react_component(name, args, options)
  end

  # Provide link to dynamically add a new nested fields association 
  def link_to_add_fields(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to(name, '#', class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})
  end

  # Return the props required to instantiate a React ModelForm component for the
  # given model instance.
  def model_form_props(model)
    {
      model: model,
      modelTitle: model.persisted? ? model.to_s : "New #{model.model_name.human.downcase}",
      modelName: model.model_name.singular,
      modelUrl: model.persisted? ? send("#{model.model_name.singular}_path", model) : nil,
      modelsUrl: send("#{model.model_name.plural}_path"),
      authenticityToken: form_authenticity_token,
      errors: errors_to_react(model)
    }.as_json
  end

  # Helper method that provides detailed error information from an active record as JSON
  def errors_to_react(model)
    {
      type: model.model_name.human.downcase,
      errors: model.errors.try(:keys) || [],
      messages: model.errors.full_messages
    }.as_json
  end

end
