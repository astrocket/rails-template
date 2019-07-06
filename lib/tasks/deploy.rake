namespace :deploy do
  task :production => :environment do
    remote_server = nil # Type your remove server information. ex) ubuntu@172.0.0.1
    project_path = nil # Type your project path. ex) /home/project/sample
    raise "Server Information Not Given. (Check '/lib/tasks/deploy.rake' for detail)" if remote_server.nil? or project_path.nil?
    sh("ssh -t #{remote_server} 'cd #{project_path}; git pull origin master && docker-compose build && docker-compose up -d --scale rails=2 sidekiq=2 && docker rmi $(docker images -f 'dangling=true' -q)'")
  end
end