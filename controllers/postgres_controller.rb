require 'rubygems'
require 'bundler/setup'
require 'sinatra/content_for'
require 'haml'

class PostgresController < Sinatra::Base
  helpers WikiHelper
  helpers PostgresHelper
  helpers Sinatra::ContentFor
  set :views, File.expand_path('../../views', __FILE__)
  set :root, File.expand_path('../', __FILE__)

  configure :production, :develpoment do
    enable :logging
  end

  not_found do
    haml :error_404
  end

  get '/daily' do
    @db = 'postgres'
    request_trends('daily')
    haml :index
  end

  get '/weekly' do
    @db = 'postgres'
    request_trends('weekly')
    haml :index
  end

  get '/monthly' do
    @db = 'postgres'
    request_trends('monthly')
    haml :index
  end
end