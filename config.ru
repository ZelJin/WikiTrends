require './app'

use Rack::Static, :urls => ['/css', '/fonts', '/js'], root: 'public'

map '/' do
  run ApplicationController.new
end

map '/api' do
  run ApiController.new
end