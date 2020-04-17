template 'lib/tasks/deploy.rake.tt'
copy_file 'lib/tasks/hot.rake'
if use_react

else
  template 'lib/generators/stimulus/templates/controller.js.erb.tt'
  copy_file 'lib/generators/stimulus/stimulus_generator.rb'
  copy_file 'lib/generators/stimulus/USAGE'
end
