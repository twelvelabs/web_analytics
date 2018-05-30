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

  private

  def pageview_data_for_day(date)
    iso_date_string = date.strftime('%F')
    # SELECT date(created_at), url, COUNT(*) AS count
    # FROM pageviews
    # WHERE created_at = 'YYYY-MM-DD'
    # GROUP BY date(created_at), url
    # ORDER BY count DESC;
    url_dataset = Pageview.dataset
                          .where(created_at: iso_date_string)
                          .group_and_count { [date(:created_at), :url] }
                          .order(Sequel.desc(:count))
    # respect `url_limit`
    url_dataset = url_dataset.limit(url_limit) if url_limit

    url_dataset.all.map do |url_data|
      result = {
        url:    url_data[:url],
        visits: url_data[:count]
      }
      result[:referrers] = referrer_data_for_day(date, url_data[:url]) if include_referrers
      result
    end
  end

  def referrer_data_for_day(date, url)
    iso_date_string = date.strftime('%F')
    ref_dataset = Pageview.dataset
                          .where(created_at: iso_date_string)
                          .where(url: url)
                          .group_and_count { [date(:created_at), :url, :referrer] }
                          .order(Sequel.desc(:count))
    ref_dataset = ref_dataset.limit(referrer_limit) if referrer_limit
    ref_dataset.all.map do |ref_data|
      {
        url:    ref_data[:referrer],
        visits: ref_data[:count]
      }
    end
  end

  def validate!
    raise ArgumentError, 'Invalid start date' unless start_date.is_a?(Date)
    raise ArgumentError, 'Invalid end date'   unless end_date.is_a?(Date)
    raise ArgumentError, 'Invalid date range' unless start_date <= end_date
  end

end
