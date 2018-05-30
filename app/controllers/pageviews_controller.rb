class PageviewsController < ApplicationController

  def top_urls
    json = json_for_date_range
    render json: json
  end

  def top_referrers
    json = json_for_date_range(limit: 10, referrers: true)
    render json: json
  end

  private

  def json_for_date_range(limit: nil, referrers: false)
    json        = {}
    start_time  = 5.days.ago.beginning_of_day
    end_time    = Time.current.end_of_day
    condition   = Sequel.lit('created_at BETWEEN ? AND ?', start_time, end_time)
    pageviews   = Pageview.dataset.where(condition).group_and_count { [date(:created_at), :url] }.all

    pageviews.each do |pageview|
      key = pageview[:date].strftime('%F')
      json[key] ||= []
      json[key] << {
        url:    pageview[:url],
        visits: pageview[:count]
      }
    end

    json.each_key do |key|
      json[key].sort_by { |hash| hash[:visits] }.reverse!
      if limit
        json[key] = json[key][0, limit]
      end
      if referrers
        json[key].each do |hash|
          results = Pageview.dataset
                            .where(created_at: key)
                            .where(url: hash[:url])
                            .group_and_count { [date(:created_at), :url, :referrer] }
                            .order(Sequel.desc(:count))
                            .limit(5)
                            .all

          hash[:referrers] = results.map do |r|
            {
              url:    r[:referrer],
              visits: r[:count]
            }
          end
        end
      end
    end

    json
  end

end
