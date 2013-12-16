require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'sinatra/content_for'
require_relative 'api.rb'

get '/' do
  client = MongoClient.new('localhost', 27017)
  db = client["wikitrends"]
  db.authenticate("wikitrends", "wiki_admin_passwd")
  @trends = db["trends"].find.sort({diff: -1}).limit(5).to_a
  @views = {}
  @news = {}
  @trends.each do |trend|
    @views[trend["name"]] = db["views"].find({name: trend["name"]})
    @news[trend["name"]] = request_news(trend["name"])
  end
  haml :index
end

get '/daily' do
  client = MongoClient.new('localhost', 27017)
  db = client["wikitrends"]
  db.authenticate("wikitrends", "wiki_admin_passwd")
  @trends = db["trends"].find.sort({diff: -1}).limit(5).to_a
  puts "Trends"
  @views = {}
  @news = {}
  @trends.each do |trend|
    puts "I've been there"
    @views[trend["name"]] = db["views"].find({name: trend["name"]})
    @news[trend["name"]] = request_news(trend["name"])
  end
  haml :index
end

get '/weekly' do
  client = MongoClient.new('localhost', 27017)
  db = client["wikitrends"]
  db.authenticate("wikitrends", "wiki_admin_passwd")
  @trends = db["trends"].find.sort({diff: -1, valid_date: 1}).limit(5).to_a
  puts "Trends"
  @views = {}
  @news = {}
  @trends.each do |trend|
    puts "I've been there"
    @views[trend["name"]] = db["views"].find({name: trend["name"]})
    @news[trend["name"]] = request_news(trend["name"])
  end
  haml :index
end

get '/monthly' do
  client = MongoClient.new('localhost', 27017)
  db = client["wikitrends"]
  db.authenticate("wikitrends", "wiki_admin_passwd")
  @trends = db["trends"].find.sort({diff: -1}).limit(5).to_a
  puts "Trends"
  @views = {}
  @news = {}
  @trends.each do |trend|
    puts "I've been there"
    @views[trend["name"]] = db["views"].find({name: trend["name"]})
    @news[trend["name"]] = request_news(trend["name"])
  end
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
  parse_wikipedia_page
end

get '/views' do
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