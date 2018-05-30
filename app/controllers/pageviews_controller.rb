class PageviewsController < ApplicationController

  def top_urls
    report = PageviewReport.new(
      start_date: 5.days.ago.to_date,
      end_date:   Date.today
    )
    # TODO: cache
    results = report.call
    render json: results
  end

  def top_referrers
    report = PageviewReport.new(
      start_date:         5.days.ago.to_date,
      end_date:           Date.today,
      include_referrers:  true,
      url_limit:          10,
      referrer_limit:     5
    )
    # TODO: cache
    results = report.call
    render json: results
  end

end
