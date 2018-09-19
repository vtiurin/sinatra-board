require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'sqlite3'

def init_db
  @db = SQLite3::Database.new 'board.db'
  @db.results_as_hash = true
end

before '/' do
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
  @posts = @db.execute 'select * from Posts order by created_date desc'
  @db.close
  erb :index
end

get '/new' do
  erb :new
end

post '/new' do
  post_content = params[:content]
  if post_content.strip.empty?
    @error = 'Enter post text'
    return erb :new
  end
  @db.execute "INSERT INTO Posts (created_date, content) VALUES (datetime('now', 'localtime'), ?)", [post_content]
  @bdb.close
  erb post_content
end