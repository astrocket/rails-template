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
  app_domain
  admin_email
  git_repo_url
  container_registry_path
  use_k8s
  if use_k8s
    k8s_cluster_name
  end
end

def k8s_name
  app_name.downcase.tr("_", "-")
end

def git_repo_path
  git_repo_url[/github\.com(\/|:)(.+).git/, 2] || "username/#{app_name}"
end

def git_repo_url
  @git_repo_url ||= ask_with_default("What is the git remote URL for this project?", :green, "skip")
end

def app_domain
  @app_domain ||= ask_with_default("What is the app domain for this project?", :green, "example.com")
end

def admin_email
  @admin_email ||= ask_with_default("What is the admin's email address? (for SSL Certificate)", :green, "admin@example.com")
end

def use_active_admin
  @use_active_admin ||= ask_with_default("Would you like to use ActiveAdmin as admin?", :green, "yes")
  @use_active_admin == "yes"
end

def use_k8s
  @use_k8s ||= ask_with_default("Would you like to use k8s as default deployment stack?", :green, "yes")
  @use_k8s == "yes"
end

def container_registry_path
  @container_registry_path ||= ask_with_default("What is your container registry path?", :green, "registry.digitalocean.com/#{git_repo_path}")
end

def k8s_cluster_name
  @k8s_cluster_name ||= ask_with_default("What is digital ocean k8s cluster name?", :green, "example-cluster")
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

run("gem install bundler --no-document --conservative")
run("bundle config set --local force_ruby_platform false")

after_bundle do
  run("bundle add rails-i18n image_processing sidekiq connection_pool kredis")
  rails_command("kredis:install")
  run("bundle add letter_opener --group development")
  run("bundle add rspec-rails factory_bot_rails mock_redis database_cleaner-active_record --group test")
  run("bundle add sidekiq-cron sidekiq_alive --group production")
  run("touch config/schedule.yml")

  apply_and_commit("app/template.rb")
  apply_and_commit "lib/template.rb"
  rails_command("generate rspec:install")
  apply_and_commit "spec/template.rb"
  if use_k8s
    apply_and_commit("k8s/template.rb")
  end

  rails_command("db:create")
  rails_command("db:migrate")

  if use_active_admin
    run("bundle add activeadmin")
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
  template ".circleci/config.yml.tt"

  copy_file "public/robots.txt", force: true
  template "README.md.tt", "README.md", force: true
  git_commit("project ready")
  puts set_color full_liner("Start by running 'cd #{@app_path} && foreman start'"), :green
  puts set_color full_liner(""), :green
end
