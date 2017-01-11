ENV["RACK_ENV"] = "test"

require 'minitest/autorun'
require 'rack/test'

require_relative "../grocery.rb"

class GroceryTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def session
    last_request.env["rack.session"]
  end

  def add_item(food_item)
    get "/list", {}, {"rack.session" => {list: [{name: food_item, price: 2.00, quantity: 1}]}}
  end

  def setup
    add_item('Lettuce')
  end

  def test_homepage
    get "/"

    assert_equal 302, last_response.status
  end

  def test_shop_items_available
    get "/shop"

    assert_equal 200, last_response.status
    assert "text/plain", last_response["Content-Type"]
    assert_includes last_response.body, %q(<button type="submit")
  end

  def test_add_item_from_shop_page
    post "/add/Beef/5"

    assert_equal 302, last_response.status
    assert_equal "Beef added!", session[:message]

    get "/list"
    assert_includes last_response.body, "Beef"
  end

  def test_view_shopping_list
    get "/list"

    assert_equal 200, last_response.status
    assert "text/plain", last_response["Content-Type"]
    assert_includes last_response.body, "Your Grocery List"
    assert_includes last_response.body, "Lettuce"
    assert_includes last_response.body, "Total Cost:"
  end

  def test_increase_quantity
    post "/increase/Lettuce"

    assert_equal 302, last_response.status
    assert_equal "Quantity increased.", session[:message]

    get "/list"
    assert_includes last_response.body, "Lettuce"
    assert_includes last_response.body, "Quantity: 2"
  end

  def test_decrease_quantity
    post "/decrease/Lettuce"

    assert_equal 302, last_response.status

    assert_equal "Quantity decreased.", session[:message]
  end

  def test_delete_all_of_item
    post "/delete/Lettuce"

    assert_equal 302, last_response.status
    assert_equal "Item deleted.", session[:message]

    get "/list"

    refute_includes last_response.body, "Lettuce"
  end

  def test_view_meals_page
    get "/meals"

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Salad"
    assert_includes last_response.body, %q(<button type="submit")
  end

  def test_add_meal_ingredients
    post "/add/meal/Salad"

    assert_equal 302, last_response.status
    assert_equal "Salad ingredients added.", session[:message]

    get "/list"
    assert_includes last_response.body, "Croutons"
  end

  def test_delete_all_items_on_list_at_once
    post "/delete/all"

    assert_equal 302, last_response.status
    assert_equal "All items deleted from list.", session[:message]

    get "/list"
    refute_includes last_response.body, "Lettuce"
  end
end