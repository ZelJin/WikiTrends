require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'sinatra/content_for'
require_relative 'api.rb'

get '/' do
  points = [
      {key: "2013-01-01", value: 500},
      {key: "2013-01-02", value: 430},
      {key: "2013-01-03", value: 570},
      {key: "2013-01-04", value: 1020},
      {key: "2013-01-05", value: 300},
      {key: "2013-01-06", value: 870},
      {key: "2013-01-07", value: 600},
      {key: "2013-01-08", value: 730},
      {key: "2013-01-09", value: 510},
      {key: "2013-01-10", value: 940},
      {key: "2013-01-11", value: 800},
      {key: "2013-01-12", value: 700},
      {key: "2013-01-13", value: 215}]
  haml :index, locals: {points: points}
end

get '/api' do
  haml :api
end

post '/api' do
  haml :api_result, locals: {data: request_views(params[:post][:name])}
end

get '/rss' do
  haml :rss
end

post '/rss' do
  haml :rss_result, locals: {feed: get_rss_feed(params[:post][:name])}
end

get '/parse' do
  parse_wikipedia_page
end

get '/views' do
  client = MongoClient.new('localhost', 27017)
  db = client["wikitrends"]
  db.authenticate("wikitrends", "wiki_admin_passwd")
  collection = db["articles"]
  articles = collection.find
  collection = db["views"]
  i = 0
  count = articles.count
  articles.each do |article|
    parse_article_views(article["name"], collection)
    puts "#{i += 1} out of #{count}"
  end
end