apply 'app/models/application_record.rb'
apply 'app/helpers/application_helper.rb'

copy_file 'app/views/errors/404.html.erb'
copy_file 'app/views/errors/422.html.erb'
copy_file 'app/views/errors/500.html.erb'
copy_file 'app/views/home/index.html.erb'

apply 'app/controllers/application_controller.rb'
copy_file 'app/controllers/errors_controller.rb'
copy_file 'app/controllers/api/api_controller.rb'
copy_file 'app/controllers/api/home_controller.rb'
copy_file 'app/controllers/home_controller.rb'

copy_file 'app/javascript/utils/api.js'
copy_file 'app/javascript/utils/helpers.js'

if use_stimulus
  template 'app/javascript/packs/application.stimulus.js.tt', 'app/javascript/packs/application.js', force: true
  copy_file 'app/javascript/controllers/index.js', force: true
end

template "app/views/layouts/application.html.erb.tt", force: true

if use_tailwind
  run "yarn add tailwindcss@npm:@tailwindcss/postcss7-compat @tailwindcss/postcss7-compat postcss@^7 autoprefixer@^9"
  run "yarn add @tailwindcss/forms @tailwindcss/typography @tailwindcss/aspect-ratio alpinejs" if use_tailwind_ui
  run "mkdir -p app/javascript/stylesheets"
  run "mkdir -p app/javascript/stylesheets/components"

  copy_file "app/javascript/stylesheets/application.scss"
  template "tailwind.config.js.tt", force: true

  inject_into_file("./postcss.config.js",
                   "var tailwindcss = require('tailwindcss');\n", before: "module.exports")
  inject_into_file("./postcss.config.js", "\n    tailwindcss('./tailwind.config.js'),", after: "plugins: [")
else
  copy_file 'app/assets/stylesheets/application.scss'
  copy_file 'app/assets/stylesheets/designs/_constants.scss'
  copy_file 'app/assets/stylesheets/designs/_base.scss'
end

remove_file 'app/assets/stylesheets/application.css', force: true

copy_file 'app/jobs/http_post_job.rb'
template 'app/lib/exceptions/default_error.rb.tt'
copy_file 'app/lib/bot_helper.rb'