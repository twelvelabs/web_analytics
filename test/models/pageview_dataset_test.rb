require 'test_helper'

class PageviewDatasetTest < ActiveSupport::TestCase

  let(:csv_path) { '/tmp/pageviews.csv' }

  before do
    File.delete(csv_path) if File.exist?(csv_path)
  end

  describe 'PageviewDataset' do
    it 'can generate a CSV of pageviews' do
      dataset = PageviewDataset.new(total_rows: 10, csv_path: csv_path)
      dataset.generate
      assert_equal(true, File.exist?(csv_path))
      assert_equal(10, File.readlines(csv_path).length)
    end

    it 'can import pageview rows into the DB' do
      dataset = PageviewDataset.new(total_rows: 10, csv_path: csv_path)
      dataset.import
      assert_equal(10, Pageview.count)
    end
  end

end
