ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/reporters'
require 'mocha/minitest'

Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new]

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  # Wrap test runs in a transaction to replicate AR's transactional fixtures
  # See: http://sequel.jeremyevans.net/rdoc/files/doc/testing_rdoc.html#label-Transactional+tests
  def run(*args, &block)
    Sequel::Model.db.transaction(rollback: :always, auto_savepoint: true) { super }
  end

end
