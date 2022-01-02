class StimulusGenerator < Rails::Generators::Base
  source_root File.expand_path("templates", __dir__)
  argument :controller_name, type: :string, required: true
  argument :action_name, type: :string, default: false
  attr_accessor :stimulus_path, :controller_pattern

  def set_up
    if action_name.present?
      @stimulus_path = "app/javascript/controllers/#{controller_name.underscore}/#{action_name.underscore}_controller.js"
      @controller_pattern = "#{ruby_to_stimulus(controller_name)}--#{ruby_to_stimulus(action_name)}"
    else
      @stimulus_path = "app/javascript/controllers/#{controller_name.underscore}_controller.js"
      @controller_pattern = ruby_to_stimulus(controller_name)
    end
  end

  def generate_stimulus
    template "controller.js.erb", stimulus_path
  end

  private

  def ruby_to_stimulus(string)
    string.underscore
      .tr("_", "-")
      .split("/")
      .join("--")
  end
end
