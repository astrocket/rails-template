require "fileutils"
require "shellwords"
require "tmpdir"

RAILS_REQUIREMENT = "~> 6.0.0.rc1".freeze

def apply_template!
  assert_minimum_rails_version
  assert_postgresql
  add_template_repository_to_source_path

  template "Gemfile.tt", force: true

  copy_file "gitignore", ".gitignore", force: true
  copy_file "Procfile", "Procfile", force: true
  template "ruby-version.tt", ".ruby-version", force: true

  run "gem install bundler -v '~> 2.0.0' --no-document --conservative"
  run "bundle install"
  git_commit("Gemfile setup")
  rails_command("webpacker:install")
  rails_command("webpacker:install:stimulus")
  git_commit("Webpacker and Stimulus installed")
  rails_command("generate rspec:install")
  run "bundle exec guard init"
  run "guard init livereload"
  git_commit("Rspec & Guard setup")
  npms = %w(axios stimulus @stimulus/polyfills)
  run "yarn add #{npms.join(' ')}"
  git_commit("Yarn installed")
  apply 'app/template.rb'
  git_commit("app/* setup")
  apply 'config/template.rb'
  git_commit("config/* setup")
  apply 'lib/template.rb'
  git_commit("lib/* setup")
  apply 'spec/template.rb'
  git_commit("spec/* setup")
  apply 'docker/template.rb'
  template 'docker-compose.yml'
  git_commit("docker/* setup")
  run "rails generate active_admin:install AdminUser" if use_active_admin == 'yes'
  copy_file 'app/assets/stylesheets/active_admin.scss', force: true if use_active_admin == 'yes'
  git_commit("ActiveAdmin installed") if use_active_admin == 'yes'
  rails_command("db:create")
  rails_command("db:migrate")
  rails_command("db:seed")
  copy_file 'README.md', force: true
  git_commit("readme update")
end

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

def git_repo_url
  @git_repo_url ||= ask_with_default("What is the git remote URL for this project?", :blue, "skip")
end

def app_domain
  @app_domain ||= ask_with_default("What is the app domain for this project?", :blue, "example.com")
end

def admin_email
  @admin_email ||= ask_with_default("What is the admin's email address? (for SSL Certificate)", :blue, "admin@example.com")
end

def slack_notification
  @slack_notification ||= ask_with_default("Would you like to use Slack as a notification service?", :blue, "yes")
end

def use_active_admin
  @use_active_admin ||= ask_with_default("Would you like to use ActiveAdmin as admin?", :blue, "yes")
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
end

def git_push
  git :init unless preexisting_git_repo?

  git add: "-A ."
  git commit: "-n -m 'Project initalized'"
  if git_repo_specified?
    git remote: "add origin #{git_repo_url.shellescape}"
    git remote: "add upstream #{git_repo_url.shellescape}"
    git push: "-u origin --all"
  end
end

def run_bundle
  run 'bin/spring stop'
  p "Template setted."
  return
end

apply_template!
