#require 'rubygems'
#require 'bundler'
#Bundler.require
require 'rubygems'
require 'sinatra'

require 'app'
use Rack::Static, :urls => ["/images"], :root => "public"
run App
