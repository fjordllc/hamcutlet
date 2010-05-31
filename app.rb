require 'sinatra'
require 'tempfile'
require 'tmpdir'
require 'haml/html'

class App < Sinatra::Base
  set :app_file, __FILE__

  helpers do
    alias h escape_html
  end

  get '/' do
    haml :index
  end

  post '/' do
    open('first.html', 'w') {|f| f.write(params[:source]) }
    params[:source].gsub!(/\r\n/, "\n")
    params[:source].gsub!(/\r/, "\n")
    params[:source].gsub!(/\n\n/m, "\n")
    params[:source].gsub!(/<!-.*?-->/m, "")
    params[:source].gsub!(/\t/, '    ')
    @haml = Haml::HTML.new(params[:source]).render
    @html = Haml::Engine.new(@haml, :attr_wrapper => '"').render
    haml :created
  end

  get '/*.css' do |path|
    content_type 'text/css'
    sass path.to_sym, :sass => {:load_paths => [options.views]}
  end

  get '/*' do |path|
    pass unless File.exist?(File.join(options.views, "#{path}.haml"))
    haml path.to_sym
  end
end
