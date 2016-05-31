class WidgetConfiguration < ActiveRecord::Base
  include DiscoApp::Concerns::RendersAssets

  belongs_to :shop, class_name: 'DiscoApp::Shop'

  renders_assets :widget_assets, assets: ['widget.scss', 'widget.js'], triggered_by: ['locale', 'background_color']
  renders_assets :liquid_assets, assets: 'widget.liquid', triggered_by: ['locale']
  renders_assets :script_tag_assets, assets: 'script_tag.js', script_tags: 'script_tag.js'

end