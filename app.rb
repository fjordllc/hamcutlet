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
#    time = Time.now.to_f
#    Tempfile.open(time) do |f|
#      f.write params[:source]
#    end
#    Dir.tmpdir
    @haml = Haml::HTML.new(params[:source]).render
    @html = Haml::Engine.new(@haml).render
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
