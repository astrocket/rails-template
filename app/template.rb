apply 'app/controllers/application_controller.rb'
apply 'app/models/application_record.rb'
apply 'app/helpers/application_helper.rb'

copy_file 'app/assets/stylesheets/application.scss'
copy_file 'app/assets/stylesheets/_constants.scss'

copy_file 'app/controllers/api/api_controller.rb'

copy_file 'app/javascript/utils/api.js'
copy_file 'app/javascript/utils/helpers.js'
copy_file 'app/javascript/controllers/index.js', force: true

copy_file 'app/lib/exceptions/default_error.rb'
copy_file 'app/lib/bot_helper.rb'
copy_file 'app/lib/telegram.rb'

copy_file 'app/jobs/http_post_job.rb'