require 'rubygems'
require 'sinatra/base'
Dir.glob('./{helpers,controllers}/*.rb').each { |file| require file}
use Rack::Static, :urls => ['/css', '/fonts', '/js'], root: 'public'

map '/' do
  run WikiController.new
end

map '/postgres' do
  run PostgresController.new
end

map '/mongo' do
  run MongoController.new
end

map '/api' do
  run ApiController.new
end