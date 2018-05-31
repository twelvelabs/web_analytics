require 'test_helper'

class PageviewsControllerTest < ActionDispatch::IntegrationTest

  test 'should get top_urls' do
    start_key = 4.days.ago.to_date.strftime('%F')
    end_key   = Date.today.strftime('%F')

    get top_urls_url
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal(5, json.keys.length)
    assert_equal(start_key, json.keys.first)
    assert_equal(end_key, json.keys.last)
  end

  test 'should get top_referrers' do
    start_key = 4.days.ago.to_date.strftime('%F')
    end_key   = Date.today.strftime('%F')

    get top_referrers_url
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal(5, json.keys.length)
    assert_equal(start_key, json.keys.first)
    assert_equal(end_key, json.keys.last)
  end

end
