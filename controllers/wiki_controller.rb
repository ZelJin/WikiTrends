require 'rubygems'
require 'bundler/setup'
require 'sinatra/content_for'
require 'haml'

class WikiController < Sinatra::Base

  helpers WikiHelper
  helpers Sinatra::ContentFor
  set :views, File.expand_path('../../views', __FILE__)

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

  get '/monthly' do
    request_trends('monthly')
    haml :index
  end

  get '/api' do
    haml :api
  end

  post '/api' do
    haml :api_result, locals: {data: request_views(params[:post][:name])}
  end

  get '/news' do
    haml :news
  end

  post '/news' do
    haml :news_result, locals: {feed: request_news(params[:post][:name])}
  end

  get '/parse' do
    Thread.new do
      parse_wikipedia_page
    end
    haml :wait
  end

  get '/views' do
    Thread.new do
      client = MongoClient.new('localhost', 27017)
      db = client["wikitrends"]
      db.authenticate("wikitrends", "wiki_admin_passwd")
      articles = db["articles"].find
      i = 0
      count = articles.count
      articles.each do |article|
        parse_views(article["name"], db["views"])
        puts "#{i += 1} out of #{count}"
      end
    end
    haml :wait
  end
end

