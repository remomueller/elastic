require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  setup do
    # Nothing
  end

  test "should get about" do
    get :about
    assert_response :success
  end
end
