require 'sinatra/base'
require_relative 'poros/data_generator'
require_relative 'poros/help_message'
require_relative 'poros/rate_limiter'
require_relative 'poros/cache'
require_relative 'routes/api'
require_relative 'routes/views'
require_relative 'helpers'

class FakeApi < Sinatra::Base
  set :public_folder, File.expand_path('public', __dir__)

  helpers Helpers

  register Routes::Views
  register Routes::Api

  not_found do
    handle_not_found
  end

  run! if app_file == $0
end
