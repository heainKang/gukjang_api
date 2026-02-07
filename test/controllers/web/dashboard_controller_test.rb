require "test_helper"

class Web::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get web_dashboard_index_url
    assert_response :success
  end
end
