require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "erb"
require "yaml"

configure do
  enable :sessions
  set :session_secret, 'super secret'
end

helpers do
  def formatted_price(price)
    sprintf('%.2f', price)
  end
end

before do
  @list = session[:list] ||= []
end

get "/" do
  redirect "/shop"
end

get "/shop" do
  @grocery_items = YAML.load_file('grocery_items.yaml').sort_by { |k, v| k }

  erb :grocery_items
end

def increase_quantity(item_name)
  @list.each { |item| item[:quantity] += 1 if item[:name] == item_name }
end

# add item to shopping list
post "/add/:item/:price" do
  if @list.any? { |item| item[:name] == params[:item] }
    increase_quantity(params[:item])
  else
    @list << { name: params[:item], price: params[:price], quantity: 1 }
  end

  redirect "/shop"
end

# view shopping list
get "/list" do
  erb :list
end