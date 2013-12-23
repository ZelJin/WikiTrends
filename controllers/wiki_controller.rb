require 'rubygems'
require 'bundler/setup'
require 'sinatra/content_for'
require 'haml'

class WikiController < Sinatra::Base

  helpers WikiHelper
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
    redirect('/mongo/daily')
  end
end

