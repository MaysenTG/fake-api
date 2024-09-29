require 'sinatra/base'

module Routes
  module Views
    def self.registered(app)
      app.before do
        cache_control :public, :must_revalidate, max_age: 43_200
      end

      app.get '/' do
        content_type :html
        erb :home
      end

      app.get '/sitemap.xml' do
        content_type :xml
        erb :sitemap, layout: false
      end

      app.get '/robots.txt' do
        content_type :text
        erb :robots, layout: false
      end
    end
  end
end
