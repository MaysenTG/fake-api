require 'sinatra/base'
require_relative '../poros/data_generator'
require_relative '../poros/help_message'

module Routes
  module Api
    def self.registered(app)
      app.before do
        content_type :json
      end

      app.get '/api' do
        { message: HelpMessage.help }.to_json
      end

      app.get %r{/api/([^/]+)} do
        handle_api_request
      end
    end
  end
end
