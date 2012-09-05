require 'sinatra/base'
require 'uri'

module SimpleLockServer
  class Locks
    def initialize(path)
      if not File.directory?(path)
        raise ArgumentError, "Lock path \"#{File.absolute_path(path)}\" is not a directory"
      end
      @path = path
    end

    def filename(name)
      File.join(@path, URI.encode(name, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")))
    end

    def acquire(name, info)
      lock = filename(name)
      begin
        File.open(lock, File::WRONLY|File::CREAT|File::EXCL) do |file|
          file.write(info)
        end
        return true
      rescue Errno::EEXIST
        return false
      end
    end

    def release(name)
      lock = filename(name)
      File.delete(lock) if File.exists?(lock)
    end

    def clear
      FileUtils.rm Dir.glob("#{@path}/*")
    end
  end

  class Application < Sinatra::Base
    configure do
      set :locks, Locks.new(ENV['LOCK_PATH'] || 'locks')
      set :username, ENV['LOCK_USER']
      set :password, ENV['LOCK_PASS']
    end

    helpers do
      def authorize!
        unless authorized?
          response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
          throw(:halt, [401, "Not authorized\n"])
        end
      end

      def authorized?
        @auth ||=  Rack::Auth::Basic::Request.new(request.env)
        @auth.provided? && @auth.basic? && @auth.credentials &&
          @auth.credentials == [settings.username, settings.password]
      end

      def should_authorize?
        settings.username && settings.password
      end
    end

    before do
      authorize! if should_authorize?
    end

    put '/:lock' do
      # Rack::Protection prevents directory traversal from URL paths
      # http://www.sinatrarb.com/intro#Configuring%20attack%20protection
      if settings.locks.acquire(params[:lock], request.body.read)
        halt 204
      else
        halt 409
      end
    end

    delete '/:lock' do
      # Rack::Protection prevents directory traversal from URL paths
      # http://www.sinatrarb.com/intro#Configuring%20attack%20protection
      settings.locks.release(params[:lock])
      halt 204
    end
  end
end
