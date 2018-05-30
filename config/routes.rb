Rails.application.routes.draw do
  get '/top_urls'       => 'pageviews#top_urls',      format: :json, as: :top_urls
  get '/top_referrers'  => 'pageviews#top_referrers', format: :json, as: :top_referrers
end
