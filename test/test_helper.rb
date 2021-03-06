require 'simplecov'
require 'pry'
require 'minitest/autorun'
require 'minitest/hell'
require 'minitest/pride'

SimpleCov.start do
  command_name 'MiniTest::Spec'
  add_filter   '/test/'
end unless ENV['no_simplecov']

require 'playa'

require 'mocha/setup'

GC.disable

# commented out by default (makes tests slower)
# require 'minitest/reporters'
# Minitest::Reporters.use!(
  # Minitest::Reporters::DefaultReporter.new({ color: true, slow_count: 5 }),
  # Minitest::Reporters::SpecReporter.new
# )
