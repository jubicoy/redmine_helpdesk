require "simplecov"
require "codeclimate-test-reporter"
SimpleCov.start do
  add_filter '.*_test.rb'
  add_filter 'init.rb'
  formatters = []
  at_exit do
    puts "Coverage done"
  end
  root File.expand_path(File.dirname(__FILE__) + '/../')
end

# Load the normal Rails helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

class TestHelper
  def self.files_path
      File.dirname(__FILE__) + '/fixtures/'
  end
  def self.fixture_path
    if Redmine::VERSION::MAJOR == 3
      File.dirname(__FILE__) + '/fixtures/3.0'
    else
      File.dirname(__FILE__) + '/fixtures/2.6'
    end
  end
end

class ActiveSupport::TestCase
  self.fixture_path = TestHelper.fixture_path
end
