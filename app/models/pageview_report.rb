class PageviewReport
  attr_reader :start_date, :end_date, :url_limit, :referrer_limit, :include_referrers

  def initialize(options = {})
    @start_date         = options[:start_date]
    @end_date           = options[:end_date]
    @url_limit          = options[:url_limit]
    @referrer_limit     = options[:referrer_limit]
    @include_referrers  = options[:include_referrers] || false
    @pageview_data      = {}
    validate!
  end

  def call
    date = start_date
    loop do
      iso_date_string = date.strftime('%F')
      @pageview_data[iso_date_string] = pageview_data_for_day(date)
      date = date.advance(days: 1)
      break if date > end_date
    end
    @pageview_data
  end

  def cache_key_for_day(iso_date_string)
    [
      'pageview_report',
      iso_date_string,
      url_limit,
      referrer_limit,
      include_referrers
    ].join('/')
  end

  private

  def pageview_data_for_day(date)
    iso_date_string = date.strftime('%F')

    # SELECT date("created_at"), "url", "referrer", count(*) AS "count"
    # FROM "pageviews"
    # WHERE "created_at" = '2018-05-25'
    # GROUP BY date("created_at"), "url", "referrer"
    # ORDER BY "count" DESC;
    rows = Pageview.dataset
                   .where(created_at: iso_date_string)
                   .group_and_count { [date(:created_at), :url, :referrer] }
                   .order(Sequel.desc(:count))

    Rails.cache.fetch(cache_key_for_day(iso_date_string), expires_in: 5.minutes) do
      results = {}
      rows.each do |row|
        key = row[:url]
        results[key] ||= {
          url:        row[:url],
          visits:     0
        }
        results[key][:visits] += row[:count]
        next unless include_referrers
        results[key][:referrers] ||= []
        results[key][:referrers] << {
          url:    row[:referrer],
          visits: row[:count]
        }
      end
      # sort by url `visits` DESC (referrer visits are already sorted in SQL)
      results = results.values.sort_by { |r| r[:visits] }.reverse!
      # respect `url_limit`
      results = results[0, url_limit] if url_limit
      # respect `referrer_limit`
      if referrer_limit && include_referrers
        results.each do |r|
          r[:referrers] = r[:referrers][0, referrer_limit]
        end
      end
      results
    end
  end

  def validate!
    raise ArgumentError, 'Invalid start date' unless start_date.is_a?(Date)
    raise ArgumentError, 'Invalid end date'   unless end_date.is_a?(Date)
    raise ArgumentError, 'Invalid date range' unless start_date <= end_date
  end

end
