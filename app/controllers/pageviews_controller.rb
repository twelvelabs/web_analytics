class PageviewsController < ApplicationController

  def top_urls
    report = PageviewReport.new(
      start_date: 4.days.ago.to_date,
      end_date:   Date.today
    )
    render json: report.call
  end

  def top_referrers
    report = PageviewReport.new(
      start_date:         4.days.ago.to_date,
      end_date:           Date.today,
      include_referrers:  true,
      url_limit:          10,
      referrer_limit:     5
    )
    render json: report.call
  end

end
