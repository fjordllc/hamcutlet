require 'rubygems'
require 'bundler'
Bundler.setup

require 'app'
use Rack::Static, :urls => ["/images"], :root => "public"
run App
