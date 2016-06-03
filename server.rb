require "sinatra"
require "pg"
require_relative "./app/models/article"
require 'pry'

set :views, File.join(File.dirname(__FILE__), "app", "views")

configure :development do
  set :db_config, { dbname: "news_aggregator_development" }
end

configure :test do
  set :db_config, { dbname: "news_aggregator_test" }
end

def db_connection
  begin
    connection = PG.connect(Sinatra::Application.db_config)
    yield(connection)
  ensure
    connection.close
  end
end


get "/articles" do
  @articles = Article.all
  erb :index
end

get "/articles/new" do
  erb :form
end

post "/articles/new" do
  @new_art = Article.new(params)
  if !@new_art.valid?
    @errors = @new_art.errors
    erb :form
  else
    @new_art.save
    redirect "/articles"
  end
end
