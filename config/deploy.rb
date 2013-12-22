require "bundler/capistrano"
require "rvm/capistrano"
require "capistrano-unicorn"

server "zeldin.pro", :web, :app, :db, primary: true

set :application, "WikiTrends"
set :user, "zeljin"
set :port, 22
set :deploy_to, "/home/#{user}/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, :git
set :repository,  "git@github.com:ZelJin/WikiTrends.git"
set :branch, "master"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after "deploy", "deploy:cleanup"
after 'deploy:restart', 'unicorn:reload'
after 'deploy:restart', 'unicorn:restart'