require 'rubygems'
require 'sinatra'
require "sinatra/reloader" if development?

get '/' do
  erb 'hi'
end

get '/new' do
  erb :new
end