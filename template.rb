require "fileutils"
require "shellwords"
require "tmpdir"

RAILS_REQUIREMENT = "~> 6.0.0".freeze

def assert_minimum_rails_version
  requirement = Gem::Requirement.new(RAILS_REQUIREMENT)
  rails_version = Gem::Version.new(Rails::VERSION::STRING)
  return if requirement.satisfied_by?(rails_version)

  prompt = "This template requires Rails #{RAILS_REQUIREMENT}. "\
             "You are using #{rails_version}. Continue anyway?"
  exit 1 if no?(prompt)
end

def assert_postgresql
  return if IO.read("Gemfile") =~ /^\s*gem ['"]pg['"]/
  fail Rails::Generators::Error,
       "This template requires PostgreSQL, "\
         "but the pg gem isn’t present in your Gemfile."
end

def add_template_repository_to_source_path
  if __FILE__ =~ %r{\Ahttps?://}
    source_paths.unshift(tempdir = Dir.mktmpdir("rails-template-"))
    at_exit { FileUtils.remove_entry(tempdir) }
    git :clone => [
        "--quiet",
        "https://github.com/astrocket/rails-template",
        tempdir
    ].map(&:shellescape).join(" ")
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

def gemfile_requirement(name)
  @original_gemfile ||= IO.read("Gemfile")
  req = @original_gemfile[/gem\s+['"]#{name}['"]\s*(,[><~= \t\d\.\w'"]*)?.*$/, 1]
  req && req.gsub("'", %(")).strip.sub(/^,\s*"/, ', "')
end

def ask_questions
  use_react
  use_tailwind
  use_active_admin
  use_slack_notification
  git_repo_url
  app_domain
  admin_email
end

def git_repo_url
  @git_repo_url ||= ask_with_default("What is the git remote URL for this project?", :blue, "skip")
end

def app_domain
  @app_domain ||= ask_with_default("What is the app domain for this project?", :blue, "example.com")
end

def admin_email
  @admin_email ||= ask_with_default("What is the admin's email address? (for SSL Certificate)", :blue, "admin@example.com")
end

def use_slack_notification
  @use_slack_notification ||= ask_with_default("Would you like to use Slack as a notification service?", :blue, "yes")
  @use_slack_notification == "yes"
end

def use_active_admin
  @use_active_admin ||= ask_with_default("Would you like to use ActiveAdmin as admin?", :blue, "yes")
  @use_active_admin == "yes"
end

def use_react
  @use_react ||= ask_with_default("Would you like to use React as front-end? (if not stimulus.js will be installed)", :blue, "yes")
  @use_react == "yes"
end

def use_tailwind
  @use_tailwind ||= ask_with_default("Would you like to use Tailswind.css? (if not default scss set will be installed)", :blue, "yes")
  @use_tailwind == "yes"
end

def ask_with_default(question, color, default)
  return default unless $stdin.tty?
  question = (question.split("?") << " [#{default}]?").join
  answer = ask(question, color)
  answer.to_s.strip.empty? ? default : answer
end

def preexisting_git_repo?
  @preexisting_git_repo ||= (File.exist?(".git") || :nope)
end

def git_repo_specified?
  git_repo_url != "skip" && !git_repo_url.strip.empty?
end

def git_commit(msg)
  git :init unless preexisting_git_repo?

  git add: "-A ."
  git commit: "-n -m '#{msg}'"
  puts set_color msg, :green
end

def git_push
  git :init unless preexisting_git_repo?

  git add: "-A ."
  git commit: "-n -m 'initializing project'"
  if git_repo_specified?
    git remote: "add origin #{git_repo_url.shellescape}"
    git remote: "add upstream #{git_repo_url.shellescape}"
    git push: "-u origin --all"
  end
end

def apply_and_commit(applying)
  apply applying
  git_commit("Applied => #{applying}")
end

def after_spring_stop
  run "bin/spring stop"
  yield if block_given?
end

assert_minimum_rails_version
assert_postgresql
add_template_repository_to_source_path
ask_questions

template "Gemfile.tt", force: true

copy_file "gitignore", ".gitignore", force: true
copy_file "Procfile", "Procfile", force: true
template "ruby-version.tt", ".ruby-version", force: true

run "gem install bundler -v '~> 2.0.0' --no-document --conservative"
run "bundle install"

git_commit("Gemfile setup")

after_bundle do
  if use_react
    rails_command("webpacker:install:react")
    npms = ["axios", "hookrouter"]
    run "yarn add eslint-plugin-react-hooks --dev"
  else
    rails_command("webpacker:install:stimulus")
    npms = %w(axios stimulus @stimulus/polyfills)
  end

  run "yarn add #{npms.join(' ')}"
  if use_react
    run "yarn remove turbolinks"
  end
  git_commit("Yarn installed")

  run "bundle exec guard init"
  run "guard init livereload"
  git_commit("Guard setup")

  apply_and_commit('app/template.rb')
  apply_and_commit 'lib/template.rb'
  after_spring_stop do
    rails_command("generate rspec:install")
  end
  apply_and_commit 'spec/template.rb'
  apply_and_commit 'docker/template.rb'

  rails_command("db:create")
  rails_command("db:migrate")

  if use_active_admin
    run "rails generate devise:install"
    rails_command("db:migrate")
    run "rails generate active_admin:install AdminUser"
    rails_command("db:migrate")
    copy_file 'app/assets/stylesheets/active_admin.scss', force: true
    git_commit("ActiveAdmin installed")
  end

  apply_and_commit 'config/template.rb'

  copy_file 'README.md', force: true

  apply("cd #{app_name} && yarn")

  git_commit("Project ready")

  puts set_color "All set!=================================", :green
  puts set_color "Start by running 'cd #{app_name} && rails hot'", :green
  puts set_color "=========================================", :green
end

