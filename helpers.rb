module Helpers
  def handle_api_request
    route_name = params['captures'].first
    properties = params['properties']&.split(',') || []
    key = params['key'] || 'data'

    nested_keys = key.split('/')
    data = DataGenerator.generate(content_name: route_name, properties:, ip: request.ip)

    generated_data = data[:data]
    cached = data[:cached]
    time_to_expiration = data[:time_to_expiration]

    nested_hash = nested_keys.reverse.inject(generated_data) { |acc, k| { k => acc } }

    {
      input: {
        content_type: route_name, properties:
      },
      cached:,
      time_to_expiration:,
      data_expiration_hours: "#{Cache::REDIS_EXPIRATION_HOURS} hours",
      nested_keys.first => nested_hash[nested_keys.first]
    }.to_json
  rescue Errors::RateLimiting => e
    status 429
    { error: e.message }.to_json
  rescue StandardError => e
    { error: e.message }.to_json
  end

  def handle_not_found
    request_path = request.path_info
    if request_path.start_with?('/api/') && request_path.split('/').length > 3
      content_type :json
      { error: "We don't accept nested routes" }.to_json
    else
      content_type :html
      erb :'errors/404/index', layout: :'errors/404/layout'
    end
  end
end
