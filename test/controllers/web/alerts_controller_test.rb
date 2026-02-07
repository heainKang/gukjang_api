require "test_helper"

class Web::AlertsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get web_alerts_index_url
    assert_response :success
  end

  test "should get new" do
    get web_alerts_new_url
    assert_response :success
  end

  test "should get create" do
    get web_alerts_create_url
    assert_response :success
  end

  test "should get edit" do
    get web_alerts_edit_url
    assert_response :success
  end

  test "should get update" do
    get web_alerts_update_url
    assert_response :success
  end

  test "should get destroy" do
    get web_alerts_destroy_url
    assert_response :success
  end
end
