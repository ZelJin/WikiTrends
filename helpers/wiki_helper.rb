require 'rest-client'

module WikiHelper
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
end