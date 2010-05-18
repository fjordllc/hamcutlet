class App < Sinatra::Base
  set :app_file, __FILE__

  get '/' do
    haml :index
  end

  post '/' do
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
