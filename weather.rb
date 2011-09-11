require 'rubygems'
require 'sinatra'

get '/style.css' do
  sass :style
end

get '/' do
  @timeframe = "1d"
  @image_path = '/images/1d/'
  haml :homepage
end

get '/:timeframe' do
  @timeframe = params[:timeframe]
  @image_path = '/images/'
  @image_path += @timeframe + "/" if @timeframe
  haml :homepage
end

get '/style.css' do
  sass :style
end
