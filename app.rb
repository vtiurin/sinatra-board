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

configure do
  init_db
  @db.execute 'CREATE TABLE IF NOT EXISTS Posts
  (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_date DATE,
    content TEXT
  )'
  @db.close
end

get '/' do
  erb 'hi'
end

get '/new' do
  erb :new
end

post '/new' do
  post_content = params[:content]
  # current_date =  datetime('now', 'localtime')
  if post_content.strip.empty?
    return erb 'Enter your post'
  end
  @db.execute "INSERT INTO Posts (created_date, content) VALUES (datetime('now', 'localtime'), ?)", [post_content]
  erb post_content
end