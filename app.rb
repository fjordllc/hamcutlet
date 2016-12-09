# -*- coding: utf-8 -*-
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/r18n'
require 'rack-flash'
require 'haml/html'
require './haml_ext'
require 'open-uri'
require 'hpricot'
require 'nkf'
require 'sprockets'
require 'oulu'
require 'uglifier'
require 'autoprefixer-rails'

Encoding.default_external = 'utf-8'

class App < Sinatra::Base
  configure do
    use Rack::Session::Cookie
    use Rack::Flash
    use Rack::Static, :urls => ['/images'], :root => 'public'
    set :app_file, __FILE__
    set :haml, {:attr_wrapper => '"', :ugly => false}
    set :raise_errors, true
    register Sinatra::R18n
  end

  configure do
    Oulu.load_paths.each do |path|
      assets.append_path(path)
    end
  end

  assets = Sprockets::Environment.new do |env|
    # This ensures sprockets can find the CSS files
    env.append_path "assets/stylesheets/"
    env.append_path "assets/javascripts/"
  end

  AutoprefixerRails.install(assets)

  configure :development do
    register Sinatra::Reloader
  end

  helpers do
    alias h escape_html
  end

  get '/assets/stylesheets/*' do
    env["PATH_INFO"].sub!("/assets/stylesheets", "")
    assets.call(env)
  end

  get '/assets/javascripts/*' do
    env["PATH_INFO"].sub!("/assets/javascripts", "")
    assets.call(env)
  end

  get '/' do
    if params[:url]
      content_type 'text/plain', :charset => 'utf-8'
      begin
        ua = request.user_agent || "Ruby/#{RUBY_VERSION}"
        source = NKF.nkf('-w', open(params[:url], "User-Agent" => ua){|f| f.read })
        html2haml(source)
      rescue Haml::SyntaxError => e
        case e.message
        when 'Invalid doctype'
          halt 500, t.invalid_doctype
        else
          halt 500, e.message
        end
      end
    else
      haml :index
    end
  end

  post '/' do
    begin
      if params[:source].empty?
        flash[:error] = t.required_html_tags
      else
        @html = html2haml(params[:source])
      end
    rescue Haml::SyntaxError => e
      case e.message
      when 'Invalid doctype'
        flash[:error] = t.invalid_doctype
      else
        flash[:error] = e.message
      end
    end

    haml :created
  end

  private
  def html2haml(html)
    html5 = (doctype = Hpricot(html).children.detect{ |e| e.doctype? }) ? doctype.public_id.nil? : false
    haml = Haml::HTML.new(html.gsub(/\t/, '    ')).render
    Haml::Engine.new(haml, :attr_wrapper => '"', :format => html5 ? :html5 : :xhtml).render
  end
end
