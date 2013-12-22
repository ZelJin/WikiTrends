require 'sinatra/base'
Dir.glob('./{helpers,controllers}/*.rb').each { |file| require file}
use Rack::Static, :urls => ['/css', '/fonts', '/js'], :root => 'public'
map '/' do
  run WikiController
end