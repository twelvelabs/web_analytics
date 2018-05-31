require 'test_helper'

class PageviewReportTest < ActiveSupport::TestCase

  before do
    Pageview.dataset.delete
  end

  describe 'PageviewReport' do
    it 'should raise if start_date is invalid' do
      assert_raise(ArgumentError) { PageviewReport.new(start_date: nil, end_date: Date.today) }
      assert_raise(ArgumentError) { PageviewReport.new(start_date: 'ham', end_date: Date.today) }
    end

    it 'should raise if end_date is invalid' do
      assert_raise(ArgumentError) { PageviewReport.new(start_date: Date.today, end_date: nil) }
      assert_raise(ArgumentError) { PageviewReport.new(start_date: Date.today, end_date: 'ham') }
    end

    it 'should raise if start_date is after end_date' do
      assert_raise(ArgumentError) { PageviewReport.new(start_date: Date.today, end_date: 2.days.ago.to_date) }
    end

    it 'should have sensible defaults' do
      report = PageviewReport.new(start_date: 5.days.ago.to_date, end_date: Date.today)
      assert_nil(report.url_limit)
      assert_nil(report.referrer_limit)
      assert_equal(false, report.include_referrers)
    end

    it 'should return a hash keyed by iso date' do
      start_date = Date.new(2018, 5, 30)
      end_date = Date.new(2018, 6, 3)
      report = PageviewReport.new(start_date: start_date, end_date: end_date)
      data = report.call
      expected = %w[2018-05-30 2018-05-31 2018-06-01 2018-06-02 2018-06-03]
      assert_equal(expected, data.keys)
    end
  end

  describe 'PageviewReport for top urls' do
    let(:yesterday) { Date.new(2018, 5, 29) }
    let(:today)     { Date.new(2018, 5, 30) }
    let(:tomorrow)  { Date.new(2018, 5, 31) }

    let(:report) do
      PageviewReport.new(start_date: today, end_date: today)
    end

    before do
      1.times { create(:pageview, url: 'http://example.com/1', referrer: nil, created_at: today.beginning_of_day) }
      2.times { create(:pageview, url: 'http://example.com/2', referrer: nil, created_at: today.beginning_of_day) }
      3.times { create(:pageview, url: 'http://example.com/3', referrer: nil, created_at: today.beginning_of_day) }
      4.times { create(:pageview, url: 'http://example.com/4', referrer: nil, created_at: today.beginning_of_day) }
      5.times { create(:pageview, url: 'http://example.com/5', referrer: nil, created_at: today.beginning_of_day) }
      # beyond date range
      create(:pageview, url: 'http://example.com/wat', referrer: nil, created_at: yesterday.end_of_day)
      create(:pageview, url: 'http://example.com/wat', referrer: nil, created_at: tomorrow.beginning_of_day)
    end

    it 'should only return data in the date range' do
      data = report.call
      # shouldn't include results for yesterday or tomorrow
      assert_equal(['2018-05-30'], data.keys)
      assert_equal(5, data['2018-05-30'].length)
      # pageviews for each date should be ordered by visits DESC
      assert_equal('http://example.com/5',  data['2018-05-30'][0][:url])
      assert_equal(5,                       data['2018-05-30'][0][:visits])
      assert_equal('http://example.com/4',  data['2018-05-30'][1][:url])
      assert_equal(4,                       data['2018-05-30'][1][:visits])
      assert_equal('http://example.com/3',  data['2018-05-30'][2][:url])
      assert_equal(3,                       data['2018-05-30'][2][:visits])
      # etc...
    end
  end

  describe 'PageviewReport for top referrers' do
    let(:yesterday) { Date.new(2018, 5, 29) }
    let(:today)     { Date.new(2018, 5, 30) }
    let(:tomorrow)  { Date.new(2018, 5, 31) }

    let(:report) do
      PageviewReport.new(
        start_date:         today,
        end_date:           today,
        include_referrers:  true,
        url_limit:          1,
        referrer_limit:     3
      )
    end

    before do
      # referrer 1
      create(:pageview, url: 'http://example.com/1', referrer: 'http://foo.com/', created_at: today.beginning_of_day)
      create(:pageview, url: 'http://example.com/1', referrer: 'http://foo.com/', created_at: today.beginning_of_day)
      create(:pageview, url: 'http://example.com/1', referrer: 'http://foo.com/', created_at: today.beginning_of_day)
      create(:pageview, url: 'http://example.com/1', referrer: 'http://foo.com/', created_at: today.beginning_of_day)
      # referrer 2
      create(:pageview, url: 'http://example.com/1', referrer: 'http://bar.com/', created_at: today.beginning_of_day)
      create(:pageview, url: 'http://example.com/1', referrer: 'http://bar.com/', created_at: today.beginning_of_day)
      create(:pageview, url: 'http://example.com/1', referrer: 'http://bar.com/', created_at: today.beginning_of_day)
      # referrer 3
      create(:pageview, url: 'http://example.com/1', referrer: 'http://baz.com/', created_at: today.beginning_of_day)
      create(:pageview, url: 'http://example.com/1', referrer: 'http://baz.com/', created_at: today.beginning_of_day)

      # beyond `referrer_limit`, but should be counted in number of `url` visits
      create(:pageview, url: 'http://example.com/1', referrer: 'http://wat.com/', created_at: today.beginning_of_day)
      # beyond `url_limit`
      create(:pageview, url: 'http://example.com/2', referrer: 'http://foo.com/', created_at: today.beginning_of_day)
      # beyond date range
      create(:pageview, url: 'http://example.com/wat', referrer: nil, created_at: yesterday.end_of_day)
      create(:pageview, url: 'http://example.com/wat', referrer: nil, created_at: tomorrow.beginning_of_day)
    end

    it 'should return only top N referrers' do
      data = report.call
      # `url_limit` is 1, so should only include the top url from `today`
      assert_equal(['2018-05-30'], data.keys)
      assert_equal(1, data['2018-05-30'].length)
      # visit count should be correct
      assert_equal('http://example.com/1', data['2018-05-30'][0][:url])
      assert_equal(10, data['2018-05-30'][0][:visits])
      # referrers should respect `referrer_limit`
      assert_equal(3, data['2018-05-30'][0][:referrers].length)
      # referrers should be correctly ordered
      assert_equal('http://foo.com/', data['2018-05-30'][0][:referrers][0][:url])
      assert_equal(4,                 data['2018-05-30'][0][:referrers][0][:visits])
      assert_equal('http://bar.com/', data['2018-05-30'][0][:referrers][1][:url])
      assert_equal(3,                 data['2018-05-30'][0][:referrers][1][:visits])
      assert_equal('http://baz.com/', data['2018-05-30'][0][:referrers][2][:url])
      assert_equal(2,                 data['2018-05-30'][0][:referrers][2][:visits])
    end
  end

end
