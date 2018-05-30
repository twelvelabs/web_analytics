require 'test_helper'

class PageviewTest < ActiveSupport::TestCase

  describe 'Pageview' do
    it 'has a valid factory' do
      pageview = build(:pageview)
      assert_equal(true, pageview.valid?)
    end

    it 'can be persisted' do
      pageview = build(:pageview)
      assert_not_nil(pageview.save)
    end

    it 'ensures url is present and a valid URL' do
      assert_equal(false, build(:pageview, url: nil).valid?)
      assert_equal(false, build(:pageview, url: 'ftp://ham').valid?)
      assert_equal(true, build(:pageview, url: 'http://snausages').valid?)
    end

    it 'ensures referrer is either nil or a valid URL' do
      assert_equal(true, build(:pageview, referrer: nil).valid?)
      assert_equal(false, build(:pageview, url: 'ftp://ham').valid?)
      assert_equal(true, build(:pageview, url: 'http://snausages').valid?)
    end

    it 'ensures created_at is present' do
      assert_equal(false, build(:pageview, created_at: nil).valid?)
      assert_equal(true, build(:pageview, created_at: 1.day.ago).valid?)
    end

    it 'ensures hash is present' do
      assert_equal(false, build(:pageview, hash: nil).valid?)
      assert_equal(true, build(:pageview, hash: Digest::MD5.hexdigest('something')).valid?)
    end

    it 'properly persists #hash' do
      pageview = create(:pageview)
      pageview.hash = new_hash = Digest::MD5.hexdigest('something new')
      pageview.save
      pageview.refresh
      assert_equal(new_hash, pageview.hash)
    end
  end

end
