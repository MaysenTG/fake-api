require 'sinatra/base'
require_relative 'data_generator'
require_relative 'help_message'
require_relative 'rate_limiter'

class FakeApi < Sinatra::Base
  before do
    content_type :json
  end

  get '/' do
    { message: HelpMessage.help }.to_json
  end

  get '/api' do
    { message: HelpMessage.help }.to_json
  end

  get %r{/api/([^/]+)} do
    route_name = params['captures'].first
    properties = params['properties']&.split(',') || []
    key = params['key'] || 'data'

    nested_keys = key.split('/')
    data = DataGenerator.generate(content_name: route_name, properties:, ip: request.ip)

    nested_hash = nested_keys.reverse.inject(data) { |acc, k| { k => acc } }

    { input: { content_type: route_name, properties: },
      nested_keys.first => nested_hash[nested_keys.first] }.to_json
  rescue RateLimitingError => e
    status 429
    { error: e.message }.to_json
  rescue StandardError => e
    { error: e.message }.to_json
  end

  not_found do
    request_path = request.path_info
    if request_path.start_with?('/api/') && request_path.split('/').length > 3
      { error: "We don't accept nested routes" }.to_json
    else
      { message: 'This is nowhere to be found.' }.to_json
    end
  end

  run! if app_file == $0
end
