require 'rubygems'
#require 'bundler'
#Bundler.require
require 'rubygems'
require 'sinatra'
require 'haml'

require 'app'
use Rack::Static, :urls => ["/images"], :root => "public"
run App
