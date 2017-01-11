require "sinatra"
require "sinatra/reloader" if development?
require "sinatra/content_for"
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

  def calculate_total_cost
    total = 0
    @list.each do |item|
      total += (item[:price].to_i * item[:quantity])
    end

    formatted_price(total)
  end
end

def list_include?(item_name)
  @list.any? { |item| item[:name] == item_name }
end

def increase_quantity(item_name)
  @list.each { |item| item[:quantity] += 1 if item[:name] == item_name }
end

def decrease_quantity(item_name)
  @list.each do |item|
    if item[:name] == item_name && item[:quantity] > 1
      item[:quantity] -= 1 
    elsif item[:name] == item_name
      delete_item_from_list(item_name)
    end
  end
end

def delete_item_from_list(item_name)
  @list.reject! { |item| item[:name] == item_name }
end

before do
  @list = session[:list] ||= []
end

get "/" do
  redirect "/shop"
end

# view and shop available items
get "/shop" do
  @grocery_items = YAML.load_file('grocery_items.yaml').sort_by { |k, v| k }

  erb :grocery_items
end

# add meal ingredients to list
post "/add/meal/:meal_name" do
  meals = YAML.load_file("meals.yaml")
  meal = meals.select { |meal_name| meal_name == params[:meal_name] }

  meal.each_value do |ingredients|
    ingredients.each do |ingredient, price|
      if list_include?(ingredient)
        increase_quantity(ingredient)
      else
        @list << { name: ingredient, price: formatted_price(price), quantity: 1 }
      end
    end
  end

  session[:message] = "#{params[:meal_name]} ingredients added."
  redirect "/meals"
end

# add item to shopping list from item avail page
post "/add/:item/:price" do
  if list_include?(params[:item])
    increase_quantity(params[:item])
  else
    @list << { name: params[:item], price: params[:price], quantity: 1 }
  end

  session[:message] = "#{params[:item]} added!"
  redirect "/shop"
end

# view shopping list
get "/list" do
  erb :list
end

# add 1 to item quantity on list page
post "/increase/:item" do
  increase_quantity(params[:item])
  session[:message] = "Quantity increased."

  redirect "/list"
end

# subtract 1 from item quantity on list page
post "/decrease/:item" do
  decrease_quantity(params[:item])
  session[:message] = "Quantity decreased."

  redirect "/list"
end

# delete all items from list
post "/delete/all" do
  @list.clear

  session[:message] = "All items deleted from list."
  redirect "/list"
end

# delete all of item from list
post "/delete/:item" do
  delete_item_from_list(params[:item])
  session[:message] = "Item deleted."
  redirect "/list"
end

# shop by meals page
get "/meals" do
  @meals = YAML.load_file("meals.yaml").sort_by {|k,_| k }

  erb :meals
end





