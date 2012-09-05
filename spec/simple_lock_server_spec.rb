require_relative 'spec_helper'

include Rack::Test::Methods

def app() SimpleLockServer::Application end

describe "simple lock server" do
  before do
    app.settings.locks.clear
  end

  it "should allow a lock to be acquired" do
    put '/test_lock'
    last_response.status.must_equal 204
  end

  it "should prevent a lock from being acquired more than once" do
    put '/test_lock'
    last_response.status.must_equal 204
    put '/test_lock'
    last_response.status.must_equal 409
  end

  it "should allow a lock to be released and re-acquired" do
    put '/test_lock'
    last_response.status.must_equal 204
    put '/test_lock'
    last_response.status.must_equal 409
    delete '/test_lock'
    last_response.status.must_equal 204
    put '/test_lock'
    last_response.status.must_equal 204
  end

  describe "basic auth" do
    before do
      app.settings.username = 'admin'
      app.settings.password = 'admin'
    end

    after do
      app.settings.username = nil
      app.settings.password = nil
    end
    
    it "should require a username and password" do
      put '/test_lock'
      last_response.status.must_equal 401
      delete '/test_lock'
      last_response.status.must_equal 401
    end

    it "should accept the correct username and password" do
      authorize 'admin', 'admin'
      put '/test_lock'
      last_response.status.must_equal 204
      delete '/test_lock'
      last_response.status.must_equal 204
    end
  end
end
