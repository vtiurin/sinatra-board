require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'sqlite3'

def init_db
  @db = SQLite3::Database.new 'board.db'
  @db.results_as_hash = true
end

before '/new' do
  init_db
end

get '/' do
  erb 'hi'
end

get '/new' do
  erb :new
end

post '/new' do
  erb params[:content]
end