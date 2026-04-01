require "test_helper"

class Admin::QuotesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_quotes_index_url
    assert_response :success
  end

  test "should get show" do
    get admin_quotes_show_url
    assert_response :success
  end
end
