require 'rest-client'
require 'nokogiri'

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
    puts page.class
    page.css('.wikitable a').each do |element|
      if element[:title] != nil
        puts element[:title]
      end
    end
  end
end