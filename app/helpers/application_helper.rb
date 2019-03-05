insert_into_file 'app/helpers/application_helper.rb', before: /^end/ do
  <<-'RUBY'
  def stc
    "#{controller_path.gsub('_', '-').gsub('/', '--')}--#{action_name}"
  end
  
  def human_time(datetime)
    datetime.strftime("%m/%d %H:%M")
  end
  RUBY
end