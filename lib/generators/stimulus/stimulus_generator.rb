class StimulusGenerator < Rails::Generators::Base
  source_root File.expand_path('templates', __dir__)
  argument :controller_name, type: :string, default: false
  argument :action_name, type: :string, default: false
  attr_accessor :stimulus_path, :controller_pattern

  def set_up
    @stimulus_path = "app/javascript/controllers/#{controller_name}/#{action_name}_controller.js"
    @controller_pattern = "#{controller_name.split('/').join('--')}--#{action_name}"
  end

  def generate_stimulus
    template 'controller.js.erb', stimulus_path
  end

end
