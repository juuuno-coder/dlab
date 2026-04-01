require "test_helper"

class Admin::AgenciesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_agencies_index_url
    assert_response :success
  end

  test "should get show" do
    get admin_agencies_show_url
    assert_response :success
  end

  test "should get new" do
    get admin_agencies_new_url
    assert_response :success
  end

  test "should get edit" do
    get admin_agencies_edit_url
    assert_response :success
  end

  test "should get create" do
    get admin_agencies_create_url
    assert_response :success
  end

  test "should get update" do
    get admin_agencies_update_url
    assert_response :success
  end

  test "should get destroy" do
    get admin_agencies_destroy_url
    assert_response :success
  end
end
