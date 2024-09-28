require 'sinatra/base'

module Routes
  module Views
    def self.registered(app)
      app.get '/' do
        content_type :html
        erb :home
      end
    end
  end
end
