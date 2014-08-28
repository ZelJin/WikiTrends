require 'rubygems'
require 'sinatra/base'
require 'sinatra/activerecord'

Dir.glob('./{helpers,controllers,models}/*.rb').each { |file| require file}
