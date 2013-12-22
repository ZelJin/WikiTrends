class ApplicationController < Sinatra::Base
  helpers WikiHelper

  set :views, File.expand_path('../../views', __FILE__)

  configure :production, :develpoment do
    enable :logging
  end

  not_found do
    haml :error_404
  end
end