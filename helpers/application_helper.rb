require 'rest-client'
require 'nokogiri'

module ApplicationHelper
  def request_views(name)
    response = RestClient.get "http://stats.grok.se/json/en/latest90/#{URI.escape(name.tr(" ", "_"))}"
    if response.code == 200
      JSON.parse(response)["daily_views"]
    else
      response.code
    end
  end


  def request_news(request)
    response = RestClient.get("https://ajax.googleapis.com/ajax/services/search/news?v=1.0&q=#{URI.escape(request)}")
    if response.code == 200
      JSON.parse(response)["responseData"]["results"][0..2]
    else
      response.code
    end
  end

  def prettify_string(str)
    prepositions = %w{a an the and but or for nor of}
    str.split.each_with_index.map{|x, index| prepositions.include?(x) && index > 0 ? x : x.capitalize }.join(" ")
  end

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