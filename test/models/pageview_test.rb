require 'test_helper'

class PageviewTest < ActiveSupport::TestCase

  describe 'Pageview' do

    it 'can be persisted' do
      pageview = Pageview.new(
        url:        'https://example.com',
        referrer:   'https://example.com/foo',
        created_at: Time.current,
        hash:       Digest::MD5.hexdigest('foo')
      )
      assert_not_nil(pageview.save)
    end

  end

end
