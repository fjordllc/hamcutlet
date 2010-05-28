require 'rubygems'
require 'bundler'
Bundler.require

require 'app'
use Rack::Static, :urls => ["/images"], :root => "public"
run App
