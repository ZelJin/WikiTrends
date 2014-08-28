require 'rubygems'
require 'bundler/setup'
require 'sinatra/content_for'
require 'haml'

class ApplicationController < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  helpers ApplicationHelper
  helpers Sinatra::ContentFor
  set :views, File.expand_path('../../views', __FILE__)
  set :root, File.expand_path('../', __FILE__)

  configure :production, :develpoment do
    enable :logging
  end

  not_found do
    haml :error_404
  end

  get '/' do
    redirect('/daily')
  end

  get '/daily' do
    request_trends('daily')
    haml :index
  end

  get '/weekly' do
    request_trends('weekly')
    haml :index
  end

  def request_trends()

  end

end

