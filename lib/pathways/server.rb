require 'sinatra/base'
require 'erb'
require 'pathways'

module Pathways
  class Server < Sinatra::Base
    dir = File.dirname(File.expand_path(__FILE__))

    set :views,  "#{dir}/server/views"
    set :public, "#{dir}/server/public"
    set :static, true

    # Specify a logger to be used by the MongoDB driver
    # Value can be any that the Logger accepts for initialization
    # The following is the default setting
#    set :mongo_logfile, File.join("log", "mongo-driver-#{environment}.log")

    helpers do
      def tab(name)
        dname = name.to_s.downcase
        path = (dname == 'home') ? "/" : url_path(dname)
        "<li #{class_if_current(path)}><a href='#{path}'>#{name}</a></li>"
      end

      def tabs
        Pathways::Server.tabs
      end

      def url_path(*path_parts)
        [ path_prefix, path_parts ].join("/").squeeze('/')
      end
      alias_method :u, :url_path

      def current_section
        url_path request.path_info.sub('/','').split('/')[0].downcase
      end

      def current_page
        url_path request.path_info.sub('/','')
      end

      def path_prefix
        request.env['SCRIPT_NAME']
      end

      def class_if_current(path = '')
        'class="current"' if current_page[0, path.size] == path
      end

      def summary(amount,total)
        percent = ((amount.to_f / total.to_f)* 100).to_i
        "#{percent}% of sessions (#{amount} of #{total})"
      end
    end

    def show(page, layout = true)
      erb page.to_sym, {:layout => layout}
    end

    def self.tabs
      @tabs ||= ["Home","Sessions", "Actions", "Pages"]
    end

    # Assuming a MongoMapper document of Post
    get '/' do
      show :home
    end

    get '/sessions' do
      @sessions = Pathways::Session.all
      show :sessions
    end

    get '/actions' do
      @actions = Pathways::Session.popular_pages(:filter => "controller_action")
      show :actions
    end

    get '/pages' do
      @pages = Pathways::Session.popular_pages
      show :pages
    end

    get '/sessions/:id' do
      @session = Pathways::Session.find(params[:id])
      show :session
    end

  end
end