require 'rest-client'
require 'nokogiri'
require 'mongo'
require 'rss'
include Mongo

#API helpers
helpers do
  def request_views(name)
    response = RestClient.get "http://stats.grok.se/json/en/latest90/#{URI.escape(name.tr(" ", "_"))}"
    if response.code == 200
      JSON.parse(response)["daily_views"]
    else
      response.code
    end
  end

  def parse_wikipedia_page()
    page = Nokogiri.HTML(RestClient.get("http://en.wikipedia.org/wiki/User:West.andrew.g/Popular_pages"))
    client = MongoClient.new('localhost', 27017)
    db = client["wikitrends"]
    db.authenticate("wikitrends", "wiki_admin_passwd")
    collection = db["articles"]
    page.css('.wikitable a').each do |element|
      if element[:title] != nil
        collection.update({name: element[:title]}, {name: element[:title], parse_date: Time.now.utc}, {upsert: true})
      end
    end
  end

  def parse_article_views(name, collection)
    daily_views = request_views(name)
    daily_views.each do |key, value|
      collection.insert({name: name, date: key},{name: name, date: key, views: value}, {upsert: true})
    end
  end

  def get_rss_feed(request)
    response = RestClient.get("http://news.google.com/news?q=#{URI.escape(request)}&output=rss")
    if response.code == 200
      RSS::Parser.parse(response)
    else
      response.code
    end
  end

  def get_news(request)
    response = RestClient.get("https://ajax.googleapis.com/ajax/services/search/news?v=1.0&q=#{URI.escape(request)}")
    if response.code == 200
      puts response
      JSON.parse(response)["responseData"]["results"]
    else
      response.code
    end
  end
end