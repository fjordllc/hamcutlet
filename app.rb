# -*- coding: utf-8 -*-
require 'sinatra'
require 'rack-flash'
require 'haml/html'
require 'exceptional'
require 'haml_ext'
require 'erb'
require 'open-uri'
require 'nkf'

class App < Sinatra::Base
  configure do
    use Rack::Session::Cookie
    use Rack::Flash
    use Rack::Static, :urls => ['/images'], :root => 'public'
    use Rack::Exceptional, '7a3ee516cdb490dd52d54cb29e10d194fcf48410'
    set :app_file, __FILE__
    set :haml, {:attr_wrapper => '"', :ugly => false}
    set :sass, {:style => :expanded}
    set :raise_errors, true
  end

  helpers do
    alias h escape_html

    def expand_tab(source)
      tabstop = '    '
      source.gsub(/\t/, tabstop)
    end
  end

  get '/' do
    if params[:url]
      content_type 'text/plain', :charset => 'utf-8'
      begin
        source = NKF.nkf('-w', expand_tab( open(params[:url]){ |f| f.read } ) )
        hamldoc = Haml::HTML.new(source).render
        @html = Haml::Engine.new(hamldoc, :attr_wrapper => '"').render
      rescue Haml::SyntaxError => e
        case e.message
        when 'Invalid doctype'
          halt 500, 'DOCTYPEが不正です。'
        else
          halt 500, e.message
        end
      end

      erb :created, :layout => false
    else
      haml :index
    end
  end

  post '/' do
    begin
      source = expand_tab(params[:source])
      hamldoc = Haml::HTML.new(source).render
      @html = Haml::Engine.new(hamldoc, :attr_wrapper => '"').render
    rescue Haml::SyntaxError => e
      case e.message
      when 'Invalid doctype'
        flash[:error] = 'DOCTYPEが不正です。'
      else
        flash[:error] = e.message
      end
    end

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
