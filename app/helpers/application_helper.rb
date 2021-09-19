insert_into_file 'app/helpers/application_helper.rb', before: /^end/ do
  <<-'RUBY'
  def stc
    "#{ruby_to_stimulus(controller_path)}--#{ruby_to_stimulus(action_name)}"
  end
  
  def human_time(datetime)
    datetime.strftime("%m/%d %H:%M")
  end

  private

  def ruby_to_stimulus(string)
    string.underscore
      .tr("_", "-")
      .split("/")
      .join("--")
  end
  RUBY
end