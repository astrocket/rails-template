require "fileutils"
require "shellwords"
require "tmpdir"

RAILS_REQUIREMENT = ">= 6".freeze

def assert_minimum_rails_version
  requirement = Gem::Requirement.new(RAILS_REQUIREMENT)
  rails_version = Gem::Version.new(Rails::VERSION::STRING)
  return if requirement.satisfied_by?(rails_version)

  prompt = "This template requires Rails #{RAILS_REQUIREMENT}. "\
             "You are using #{rails_version}. Continue anyway?"
  exit 1 if no?(prompt)
end

def add_template_repository_to_source_path
  if __FILE__.match?(%r{\Ahttps?://})
    source_paths.unshift(tempdir = Dir.mktmpdir("rails-template-"))
    at_exit { FileUtils.remove_entry(tempdir) }
    git clone: [
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
  req = @original_gemfile[/gem\s+['"]#{name}['"]\s*(,[><~= \t\d.\w'"]*)?.*$/, 1]
  req && req.tr("'", %(")).strip.sub(/^,\s*"/, ', "')
end

def terminal_length
  require "io/console"
  IO.console.winsize[1]
rescue LoadError
  Integer(`tput co`)
end

def full_liner(string)
  remaining_length = terminal_length - string.length - 2
  string.to_s + ("-" * remaining_length).to_s
end

def ask_questions
  use_active_admin
  git_repo_url
  app_domain
  admin_email
end

def k8s_name
  app_name.downcase.tr("_", "-")
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
add_template_repository_to_source_path
ask_questions

copy_file "gitignore", ".gitignore", force: true
copy_file "dockerignore", ".dockerignore", force: true
copy_file "Procfile", "Procfile", force: true
template "ruby-version.tt", ".ruby-version", force: true

run "gem install bundler --no-document --conservative"

after_bundle do
  run("bundle add rails-i18n image_processing sidekiq letter_opener rspec-rails")
  run("bundle add sidekiq_alive --group production")

  apply_and_commit("app/template.rb")
  apply_and_commit "lib/template.rb"
  rails_command("generate rspec:install")
  apply_and_commit "spec/template.rb"
  apply_and_commit("k8s/template.rb")

  rails_command("db:create")
  rails_command("db:migrate")

  if use_active_admin
    # https://github.com/activeadmin/activeadmin/pull/7235 Rails 7 fix
    run("bundle add inherited_resources --git \"https://github.com/activeadmin/inherited_resources\"")
    run("bundle add arbre --git \"https://github.com/activeadmin/arbre\"")
    run("bundle add activeadmin --git \"https://github.com/tagliala/activeadmin.git\" --branch \"feature/railties-7\"")
    run("bundle add devise devise-i18n sass-rails activeadmin_addons arctic_admin")
    run "rails generate devise:install"
    rails_command("db:migrate")
    run "rails generate active_admin:install AdminUser"
    rails_command("db:migrate")
    copy_file "app/assets/javascripts/active_admin.js", force: true
    copy_file "app/assets/stylesheets/active_admin.scss", force: true
    git_commit("active_admin installed")
  end

  rails_command("db:seed")

  apply_and_commit "config/template.rb"

  copy_file "public/robots.txt", force: true
  template "README.md.tt", "README.md", force: true
  git_commit("project ready")
  puts set_color full_liner("Start by running 'cd #{@app_path} && yarn && rails hot'"), :green
  puts set_color full_liner(""), :green
end
