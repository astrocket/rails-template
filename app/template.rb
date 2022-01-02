copy_file "app/controllers/api/api_controller.rb"
copy_file "app/controllers/api/home_controller.rb"
copy_file "app/controllers/home_controller.rb"
copy_file "app/controllers/errors_controller.rb"

copy_file "app/views/errors/404.html.erb"
copy_file "app/views/errors/422.html.erb"
copy_file "app/views/errors/500.html.erb"
copy_file "app/views/home/index.html.erb"

copy_file "app/javascript/utils/api.js"
copy_file "app/javascript/utils/helpers.js"

run "bin/importmap add axios"
copy_file "app/lib/http_helper.rb"
copy_file "app/jobs/http_post_job.rb"
