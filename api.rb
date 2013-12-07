require 'rest-client'
require 'coderay'

#API helpers
helpers do
  def request_views(name)
    response = RestClient.get "http://stats.grok.se/json/en/latest90/#{name}"
    if response.code == 200
      CodeRay.scan(response, :JSON).div
    else
      response.code
    end
  end
end