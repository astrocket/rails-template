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
    at_exit {FileUtils.remove_entry(tempdir)}
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

def terminal_length
  require 'io/console'
  IO.console.winsize[1]
rescue LoadError
  Integer(`tput co`)
end

def full_liner(string)
  remaining_length = terminal_length - string.length - 2
  "#{string}" + "#{'-' * remaining_length}"
end

def ask_questions
  use_stimulus
  use_tailwind
  use_active_admin
  git_repo_url
  app_domain
  admin_email
end

def k8s_name
  app_name.downcase.gsub("_", "-")
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

def use_active_admin
  @use_active_admin ||= ask_with_default("Would you like to use ActiveAdmin as admin?", :blue, "yes")
  @use_active_admin == "yes"
end

def use_react
  !use_stimulus
end

def use_stimulus
  @use_stimulus ||= ask_with_default("Would you like to use Stimulus as front-end? (if not react.js will be installed)", :blue, "yes")
  @use_stimulus == "yes"
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

def commit_count
  @commit_count ||= 1
end

def git_commit(msg)
  git :init unless preexisting_git_repo?

  git add: "-A ."
  git commit: "-n -m '#{msg}'"
  puts set_color full_liner("🏃 #{msg}"), :green
  @commit_count = +1
end

def apply_and_commit(applying)
  apply applying
  git_commit("generated #{applying}")
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

after_bundle do
  git_commit("webpacker installed & gems are bundled & binstubs are generated")

  if use_react
    rails_command("webpacker:install:react")
    npms = ["axios", "hookrouter"]
    run "yarn add eslint-plugin-react-hooks --dev"
    git_commit("webpacker:react installed")
  else
    rails_command("webpacker:install:stimulus")
    npms = %w(axios stimulus @stimulus/polyfills)
    git_commit("webpacker:stimulus installed")
  end

  run "yarn add #{npms.join(' ')}"
  if use_react
    run "yarn remove turbolinks"
  end
  git_commit("yarn installed")

  run "bundle exec guard init"
  run "guard init livereload"
  git_commit("guard installed")

  apply_and_commit('app/template.rb')
  apply_and_commit 'lib/template.rb'
  after_spring_stop do
    rails_command("generate rspec:install")
  end
  apply_and_commit 'spec/template.rb'
  apply_and_commit('k8s/template.rb')
  template "Dockerfile.tt"
  git_commit("generated Dockerfile")

  rails_command("db:create")
  rails_command("db:migrate")

  if use_active_admin
    run "rails generate devise:install"
    rails_command("db:migrate")
    run "rails generate active_admin:install AdminUser"
    rails_command("db:migrate")
    copy_file 'app/assets/javascripts/active_admin.js', force: true
    copy_file 'app/assets/stylesheets/active_admin.scss', force: true
    git_commit("active_admin installed")
  end

  rails_command("db:seed")

  apply_and_commit 'config/template.rb'

  copy_file "public/robots.txt", force: true
  template "README.md.tt", "README.md", force: true
  git_commit("project ready")

  puts set_color full_liner("Done"), :green
  puts set_color full_liner("Start by running 'cd #{app_name} && yarn && rails hot'"), :green
  puts set_color full_liner(""), :green
end

