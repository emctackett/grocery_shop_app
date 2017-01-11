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
    post "/add/beef/5"

    assert_equal 302, last_response.status
    assert_equal "beef added!", session[:message]

    get "/list"
    assert_includes last_response.body, "beef"
  end

  def test_view_shopping_list
    get "/list"

    assert_equal 200, last_response.status
    assert "text/plain", last_response["Content-Type"]
    assert_includes last_response.body, "Your Grocery List"
    assert_includes last_response.body, "Total Cost:"
  end

  def test_increase_quantity
    post "/increase/beef"

    assert_equal 302, last_response.status
    assert_equal "Quantity increased.", session[:message]
  end

  def test_decrease_quantity
    post "/decrease/beef"

    assert_equal 302, last_response.status
    assert_equal "Quantity decreased.", session[:message]
  end

  def test_delete_all_of_item
    post "/delete/beef"

    assert_equal 302, last_response.status
    assert_equal "Item deleted.", session[:message]

    get "/list"

    refute_includes last_response.body, "beef"
  end
end