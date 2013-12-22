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
set :ssh_options, { forward_agent: true }

set :scm, "git"
set :repository,  "git@bitbucket.org:ZelJin/wikitrends.git"
set :branch, "master"

default_run_options[:pty] = true

after "deploy", "deploy:cleanup"
after 'deploy:restart', 'unicorn:reload'
after 'deploy:restart', 'unicorn:restart'