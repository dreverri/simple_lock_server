require 'bundler/setup'
require 'rake/testtask'

Rake::TestTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.verbose = true
end

task :default => :spec
