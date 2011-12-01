# -*- coding: utf-8 -*-
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/r18n'
require 'rack-flash'
require 'haml/html'
require 'sass'
require './haml_ext'
require 'open-uri'
require 'hpricot'
require 'nkf'

Encoding.default_external = 'utf-8'

class App < Sinatra::Base
  configure do
    use Rack::Session::Cookie
    use Rack::Flash
    use Rack::Static, :urls => ['/images'], :root => 'public'
    set :app_file, __FILE__
    set :haml, {:attr_wrapper => '"', :ugly => false}
    set :sass, {:style => :expanded}
    set :raise_errors, true
    register Sinatra::R18n
  end

  configure :development do
    register Sinatra::Reloader
  end

  helpers do
    alias h escape_html
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

  get '/*.css' do |path|
    content_type 'text/css'
    sass path.to_sym, :sass => {:load_paths => [settings.views]}
  end

  private
  def html2haml(html)
    html5 = (doctype = Hpricot(html).children.detect{ |e| e.doctype? }) ? doctype.public_id.nil? : false
    haml = Haml::HTML.new(html.gsub(/\t/, '    ')).render
    Haml::Engine.new(haml, :attr_wrapper => '"', :format => html5 ? :html5 : :xhtml).render
  end
end
