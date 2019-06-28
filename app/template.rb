apply 'app/controllers/application_controller.rb'
apply 'app/models/application_record.rb'
apply 'app/helpers/application_helper.rb'

copy_file 'app/assets/stylesheets/application.scss'
copy_file 'app/assets/stylesheets/designs/_constants.scss'
copy_file 'app/assets/stylesheets/designs/_base.scss'

copy_file 'app/assets/stylesheets/active_admin.scss' if use_active_admin == 'yes'

copy_file 'app/controllers/api/api_controller.rb'

copy_file 'app/javascript/utils/api.js'
copy_file 'app/javascript/utils/helpers.js'
copy_file 'app/javascript/controllers/index.js', force: true

copy_file 'app/jobs/http_post_job.rb'
template 'app/lib/exceptions/default_error.rb.tt'
copy_file 'app/lib/bot_helper.rb'

copy_file 'app/jobs/slack_message_job.rb' if slack_notification == 'yes'
copy_file 'app/services/slack_service.rb' if slack_notification == 'yes'