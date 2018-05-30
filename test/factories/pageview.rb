FactoryBot.define do

  factory :pageview do
    url        'https://example.com'
    referrer   'https://example.com/foo'
    created_at { Time.current }
    hash       Digest::MD5.hexdigest('foo')
  end

end
