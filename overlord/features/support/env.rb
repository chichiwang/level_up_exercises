require File.join(File.dirname(__FILE__), '..', '..', 'server')

ENV['RACK_ENV'] = 'test'

require 'capybara'
require 'capybara/cucumber'
require 'rspec'

Capybara.default_driver = :selenium
Capybara.app = Server

class ServerWorld
  include Capybara::DSL
  include RSpec::Expectations
  include RSpec::Matchers
end

World do
  ServerWorld.new
end
