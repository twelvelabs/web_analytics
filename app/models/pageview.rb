require 'uri'

class Pageview < Sequel::Model
  plugin :validation_helpers

  # Quack like ActiveRecord to make factory_bot happy :/
  alias save! save

  URL_REGEX = URI.regexp(%w[http https])

  # Overriding Sequel::Model's existing #hash method (:grimacing:).
  # It's clashing w/ the `hash` DB column, and the requirements seemed specific re: the name.
  # Normally I'd look into either renaming the column or finding a less hacky way to solve this,
  # but I'm already short on time and in unfamiliar territory w/ Sequel. So it goes...
  def hash
    values[:hash]
  end

  def validate
    super

    # url
    validates_presence :url
    validates_format URL_REGEX, :url

    # referrer
    validates_format URL_REGEX, :referrer, allow_nil: true

    # created_at
    validates_presence :created_at

    # hash
    validates_presence :hash
  end

end
