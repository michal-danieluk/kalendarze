require "test_helper"

class Admin::OrdersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_orders_index_url
    assert_response :success
  end

  test "should get show" do
    get admin_orders_show_url
    assert_response :success
  end

  test "should get confirm" do
    get admin_orders_confirm_url
    assert_response :success
  end

  test "should get reject" do
    get admin_orders_reject_url
    assert_response :success
  end

  test "should get export" do
    get admin_orders_export_url
    assert_response :success
  end
end
