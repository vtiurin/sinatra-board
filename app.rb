require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'sqlite3'

def init_db
  @db = SQLite3::Database.new 'board.db'
  @db.results_as_hash = true
end

before do
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
  @db.execute 'create table if not exists Comments
  (
    id integer primary key autoincrement,
    created_date date,
    content text,
    post_id integer
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
  @db.close
  redirect to '/'
end

get '/details/:post_id' do
  post_id = params[:post_id]
  posts = @db.execute 'select * from Posts where id=?', [post_id]
  @post = posts[0]
  @comments =  @db.execute 'select * from Comments where post_id=? order by created_date', [@post['id']]
  @db.close
  erb :details
end

post '/details/:post_id' do
  content = params[:content]
  post_id = params[:post_id]
  @db.execute "insert into Comments
    (
      created_date,
      content,
      post_id
    )
      values
    (
      datetime('now',
      'localtime'),
      ?,
      ?
    )", [content, post_id]
  @db.close
  redirect to "/details/#{post_id}"
end