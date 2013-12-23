require 'rest-client'
require 'nokogiri'
require 'mongo'
include Mongo

module PostgresHelper
  def parse_wikipedia_page()
    page = Nokogiri.HTML(RestClient.get("http://en.wikipedia.org/wiki/User:West.andrew.g/Popular_pages"))
    client = MongoClient.new('localhost', 27017)
    db = client["wikitrends"]
    db.authenticate("wikitrends", "wiki_admin_passwd")
    page.css('.wikitable a').each do |element|
      if element[:title] != nil
        db["articles"].update({name: element[:title].downcase},
                              {name: element[:title].downcase,
                               parse_date: Time.now.utc},
                              {upsert: true})
      end
    end
  end

  def parse_views(name, collection)
    daily_views = request_views(name)
    daily_views.each do |key, value|
      collection.update({name: name.downcase, date: key}, {name: name.downcase, date: key, views: value}, {upsert: true})
    end
  end

  def request_trends(type)
    client = MongoClient.new('localhost', 27017)
    db = client["wikitrends"]
    db.authenticate("wikitrends", "wiki_admin_passwd")
    @trends = db["trends"].find({type: type}).sort({valid_date: -1, diff: -1}).limit(5).to_a
    @views = {}
    @news = {}
    @type = type
    @trends.each do |trend|
      @views[trend["name"]] = db["views"].find({name: trend["name"]})
      @news[trend["name"]] = request_news(trend["name"])
    end
  end
end