require 'rubygems'
require 'bundler/setup'

require 'vcr'

VCR.configure do |conf|
  conf.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  conf.hook_into :webmock
  conf.default_cassette_options = { :record => :new_episodes }
end

# Rspec config goes here
RSpec.configure do |conf|

end