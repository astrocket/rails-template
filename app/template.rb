apply 'app/controllers/application_controller.rb'
copy_file 'app/controllers/errors_controller.rb'
apply 'app/models/application_record.rb'
apply 'app/helpers/application_helper.rb'

copy_file 'app/views/errors/404.html.erb'
copy_file 'app/views/errors/422.html.erb'
copy_file 'app/views/errors/500.html.erb'

copy_file 'app/assets/stylesheets/application.scss'
copy_file 'app/assets/stylesheets/designs/_constants.scss'
copy_file 'app/assets/stylesheets/designs/_base.scss'

copy_file 'app/controllers/api/api_controller.rb'

copy_file 'app/controllers/home_controller.rb'
template 'app/views/home/index.html.erb.tt'

copy_file 'app/javascript/utils/api.js'
copy_file 'app/javascript/utils/helpers.js'

if use_react
  copy_file 'app/javascript/packs/application.js', force: true
  copy_file 'app/javascript/packs/routes.js'
  copy_file 'app/javascript/packs/App.jsx'
  copy_file 'app/javascript/packs/pages/home/Index.jsx'

  copy_file 'app/controllers/react_controller.rb'
  template 'app/views/layouts/react.html.erb.tt'
else
  copy_file 'app/javascript/controllers/index.js', force: true
end

copy_file 'app/jobs/http_post_job.rb'
template 'app/lib/exceptions/default_error.rb.tt'
copy_file 'app/lib/bot_helper.rb'

copy_file 'app/jobs/slack_message_job.rb' if use_slack_notification
copy_file 'app/services/slack_service.rb' if use_slack_notification