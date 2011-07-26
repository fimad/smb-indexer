require 'test_helper'

class BrowseControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get path" do
    get :path
    assert_response :success
  end

end
