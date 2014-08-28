require 'rubygems'
require 'bundler/setup'
require 'sinatra/content_for'
require 'haml'

class ApiController < Sinatra::Base
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

  get '/articles' do
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