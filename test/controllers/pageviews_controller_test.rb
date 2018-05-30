require 'test_helper'

class PageviewsControllerTest < ActionDispatch::IntegrationTest

  test 'should get top_urls' do
    pageview = create(:pageview)

    get top_urls_url
    json = JSON.parse(response.body)

    assert_response :success
  end

  test 'should get top_referrers' do
    pageview = create(:pageview)

    get top_referrers_url
    json = JSON.parse(response.body)

    assert_response :success
  end

end
