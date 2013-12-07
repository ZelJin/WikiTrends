require 'rest-client'

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
end