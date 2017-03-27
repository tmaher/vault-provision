require 'bundler/setup'
require 'rspec'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new :spec
rescue LoadError => e
  puts "load error: #{e.message}"
end

task :default => :spec
task :test    => :spec
