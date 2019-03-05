copy_file 'app/assets/stylesheets/application.scss'
copy_file 'app/assets/stylesheets/_constants.scss'

copy_file 'app/controllers/api/api_controller.rb'

copy_file 'app/javascript/utils/api.js'
copy_file 'app/javascript/utils/helpers.js'
copy_file 'app/javascript/controllers/index.js'

copy_file 'app/lib/exceptions/default_error.rb'
copy_file 'app/lib/bot_helper.rb'
copy_file 'app/lib/telegram.rb'

copy_file 'app/jobs/http_post_job.rb'

insert_into_file 'app/controllers/application_controller.rb', beflre: /^end/ do
  <<-RUBY
  rescue_from Exceptions::DefaultError do |e|
    puts e.message if Rails.env.development?
    flash[:error] = e.message
    redirect_back(fallback_location: root_path)
  end
  RUBY
end

insert_into_file 'app/models/application_record.rb', before: /^end/ do
  <<-RUBY
  
  def self.has?(record)
    raise Exception, "You passed #{record.class.name} to #{self.name} collection in has? method." and return if self.name != record.class.name
    all.where(id: record.id).exists?
  end

  RUBY
end

insert_into_file 'app/helpers/application_helper.rb', before: /^end/ do
  <<-RUBY
  
  def stc
    "#{controller_path.gsub('_', '-').gsub('/', '--')}--#{action_name}"
  end

  def human_time(datetime)
    datetime.strftime("%m/%d %H:%M")
  end

  RUBY
end