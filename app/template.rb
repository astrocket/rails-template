apply 'app/controllers/application_controller.rb'
copy_file 'app/controllers/errors_controller.rb'
apply 'app/models/application_record.rb'
apply 'app/helpers/application_helper.rb'

copy_file 'app/views/errors/404.html.erb'
copy_file 'app/views/errors/422.html.erb'
copy_file 'app/views/errors/500.html.erb'

copy_file 'app/controllers/api/api_controller.rb'

copy_file 'app/controllers/home_controller.rb'
copy_file 'app/views/home/index.html.erb'

copy_file 'app/javascript/utils/api.js'
copy_file 'app/javascript/utils/helpers.js'

if use_react
  template 'app/javascript/packs/application.react.js.tt', 'app/javascript/packs/application.js', force: true
  copy_file 'app/javascript/packs/routes.js'
  copy_file 'app/javascript/packs/stylesheet.js'
  copy_file 'app/javascript/packs/App.jsx'
  copy_file 'app/javascript/packs/pages/home/Index.jsx'
  template 'app/javascript/packs/components/Navigation.jsx.tt'

  copy_file 'app/controllers/react_controller.rb'
  template 'app/views/layouts/react.html.erb.tt'

  copy_file 'app/controllers/api/home_controller.rb'
else
  template 'app/javascript/packs/application.stimulus.js.tt', 'app/javascript/packs/application.js', force: true
  copy_file 'app/javascript/controllers/index.js', force: true
end

template "app/views/layouts/application.html.erb.tt", force: true

if use_tailwind
  run "yarn add tailwindcss"

  run "mkdir -p app/javascript/stylesheets"
  run "mkdir -p app/javascript/stylesheets/components"

  copy_file "app/javascript/stylesheets/application.scss"
  copy_file "app/javascript/stylesheets/tailwind.config.js"
  copy_file "app/javascript/stylesheets/components/_buttons.scss"
  copy_file "app/javascript/stylesheets/components/_forms.scss"

  inject_into_file("./postcss.config.js",
                   "var tailwindcss = require('tailwindcss');\n",  before: "module.exports")
  inject_into_file("./postcss.config.js", "\n    tailwindcss('./app/javascript/stylesheets/tailwind.config.js'),", after: "plugins: [")
else
  copy_file 'app/assets/stylesheets/application.scss'
  copy_file 'app/assets/stylesheets/designs/_constants.scss'
  copy_file 'app/assets/stylesheets/designs/_base.scss'
end

remove_file 'app/assets/stylesheets/application.css', force: true
remove_file "app/javascript/packs/hello_react.jsx"

copy_file 'app/jobs/http_post_job.rb'
template 'app/lib/exceptions/default_error.rb.tt'
copy_file 'app/lib/bot_helper.rb'