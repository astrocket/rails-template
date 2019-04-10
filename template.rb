require "fileutils"
require "shellwords"
require "tmpdir"

RAILS_REQUIREMENT = "~> 6.0.0.beta3".freeze

def apply_template!
  assert_minimum_rails_version
  assert_postgresql
  add_template_repository_to_source_path

  template "Gemfile.tt", force: true

  copy_file "gitignore", ".gitignore", force: true
  copy_file "Procfile", "Procfile", force: true
  template "ruby-version.tt", ".ruby-version", force: true

  run "gem install bundler --no-document --conservative"
  run "bundle install"
  git_commit("Gemfile setup")
  rails_command("webpacker:install")
  rails_command("webpacker:install:stimulus")
  git_commit("Webpacker and Stimulus installed")
  rails_command("generate rspec:install")
  run "bundle exec guard init"
  copy_file "Guardfile", "Guardfile", force: true
  git_commit("Rspe & Guard setup")
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