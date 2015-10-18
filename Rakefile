require 'bundler/setup'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

# Style tests. Rubocop
namespace :style do
  desc 'Run Ruby style checks'
  RuboCop::RakeTask.new(:ruby)
end

desc 'Run all style checks'
task style: ['style:ruby']

# Rspec and ChefSpec
desc 'Run ChefSpec unit tests'
RSpec::Core::RakeTask.new(:spec) do |t, _args|
  t.rspec_opts = 'spec/unit'
end

# Default
task default: %w(style spec)
