# Gems
#
require 'rubygems'
require 'sinatra'
require 'datamapper'
require 'ruby-debug'
require 'eventmachine'
require 'rack-flash'
require 'logger'

# Enigma code
#
require File.dirname(__FILE__) + '/enigmamachine'
require File.dirname(__FILE__) + '/enigmamachine/models/encoder'
require File.dirname(__FILE__) + '/enigmamachine/models/encoding_task'
require File.dirname(__FILE__) + '/enigmamachine/models/video'
require File.dirname(__FILE__) + '/enigmamachine/encoding_queue'

# Database config
#
configure :production do
  db = "sqlite3:///#{Dir.pwd}/enigmamachine.sqlite3"
  DataMapper.setup(:default, db)
end

configure :development do
  db = "sqlite3:///#{Dir.pwd}/enigmamachine.sqlite3"
  DataMapper.setup(:default, db)
end

configure :test do
  db = "sqlite3::memory:"
  DataMapper.setup(:default, db)
end

Video.auto_migrate! unless Video.storage_exists?
Encoder.auto_migrate! unless Encoder.storage_exists?
EncodingTask.auto_migrate! unless EncodingTask.storage_exists?
DataMapper.auto_upgrade!

# Extensions to Sinatra
#
require File.dirname(__FILE__) +  '/ext/partials'
require File.dirname(__FILE__) +  '/ext/array_ext'

# Set the views to the proper path inside the gem
#
set :views, File.dirname(__FILE__) + '/enigmamachine/views'
set :public, File.dirname(__FILE__) + '/enigmamachine/public'


# Register helpers
#
helpers do
  include Sinatra::Partials
  alias_method :h, :escape_html
end


# Set up Rack authentication
#
use Rack::Auth::Basic do |username, password|
  [username, password] == ['admin', 'admin']
end

# Include flash notices
#
use Rack::Session::Cookie
use Rack::Flash

configure do
  Log = Logger.new("enigma.log")
  Log.level  = Logger::INFO
end
