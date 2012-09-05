require 'minitest/autorun'
require 'rack/test'

lock_path = File.expand_path('../test_locks', __FILE__)
FileUtils.mkdir(lock_path) unless File.directory?(lock_path)

ENV['RACK_ENV'] = 'test'
ENV['LOCK_PATH'] = lock_path

require_relative '../simple_lock_server'
