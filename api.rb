require 'rest-client'
require 'nokogiri'
require 'mongo'
include Mongo

#API helpers
helpers do
  def request_views(name)
    response = RestClient.get "http://stats.grok.se/json/en/latest90/#{name}"
    if response.code == 200
      response
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
        collection.insert({name: element[:title], parse_date: Time.now.utc})
      end
    end
  end
end