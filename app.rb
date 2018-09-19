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
    content TEXT,
    author TEXT,
    title TEXT
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
  author = params[:author]
  title = params[:title]
  # validation
  # make a hash where key = name of a parameter and value = error message
  errors = {
    author: 'Enter your name',
    title: 'Enter a title',
    content: 'Enter a post text'
  }
  # filter errors hash
  @error = errors.select { |k, v| params[k] == '' }.values.join ', '
  return erb :new if @error != ''
  
  @db.execute "INSERT INTO Posts
    (
      created_date,
      content,
      author,
      title
    )
      VALUES
    (
      datetime('now','localtime'),
      ?,
      ?,
      ?
    )", [post_content, author, title]
  @db.close
  redirect to '/'
end

before '/details/:post_id' do
  post_id = params[:post_id]
  posts = @db.execute 'select * from Posts where id=?', [post_id]
  @post = posts[0]
  @comments =  @db.execute 'select * from Comments where post_id=? order by created_date', [@post['id']]
  
end

after '/details/:post_id' do
  @db.close
end

get '/details/:post_id' do
  erb :details
end

post '/details/:post_id' do
  content = params[:content]
  post_id = params[:post_id]

  if content.strip.empty?
    @error = "Enter commentary text"
    return erb :details
  end

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
  redirect to "/details/#{post_id}"
end