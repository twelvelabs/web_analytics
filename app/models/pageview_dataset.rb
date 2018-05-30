require 'csv'

class PageviewDataset

  URLS_PATH = Rails.root.join('db', 'data', 'urls.txt')
  URLS = File.read(URLS_PATH).split("\n").freeze

  REFERRERS_PATH = Rails.root.join('db', 'data', 'referrers.txt')
  REFERRERS = (File.read(REFERRERS_PATH).split("\n") + [nil]).freeze

  TIMES = (2.weeks.ago.to_date...Time.current.to_date).to_a.map(&:to_time).freeze

  DEFAULT_CSV_PATH = Rails.root.join('tmp', 'pageviews.csv').freeze

  attr_accessor :total_rows, :csv_path

  def initialize(options = {})
    @total_rows = options[:total_rows] || 100
    @csv_path   = options[:csv_path].presence || DEFAULT_CSV_PATH
  end

  def clean
    File.delete(csv_path) if File.exist?(csv_path)
  end

  def import
    # Generating takes a while, no need to redo it every time
    generate unless File.exist?(csv_path)
    # It's faster to drop and re-add the index before importing
    # See: https://www.postgresql.org/docs/9.6/static/populate.html
    connection.run 'DROP INDEX IF EXISTS pageviews_created_at_url_referrer_index'
    connection.run 'DELETE FROM pageviews'
    # Can't pass the CSV filepath to the COPY command because the file is in the
    # Rails container... not the postgres one :(
    File.open(csv_path, 'r') do |f|
      connection.copy_into(:pageviews, format: :csv) { f.gets }
    end
    # Reset the PK sequence (lol, postgres) and restore the index
    connection.run "ALTER SEQUENCE pageviews_id_seq RESTART WITH #{total_rows + 1}"
    connection.run 'CREATE INDEX pageviews_created_at_url_referrer_index ON pageviews (created_at, url, referrer)'
  end

  def generate
    CSV.open(csv_path, 'w') do |csv|
      total_rows.times do |i|
        pageview = generate_pageview(id: i + 1)
        csv << [pageview[:id], pageview[:url], pageview[:referrer], pageview[:created_at], pageview[:hash]]
      end
    end
  end

  private

  def connection
    @connection ||= SequelRails.setup(Rails.env)
  end

  def generate_pageview(id: 1)
    pageview = {
      id:         id,
      url:        URLS.sample,
      referrer:   REFERRERS.sample,
      created_at: TIMES.sample
    }
    pageview[:hash] = Digest::MD5.hexdigest(pageview.compact.to_s)
    pageview
  end

end
