require 'redis'

module RedisConnection
  DEFAULT_URL = 'redis://127.0.0.1:6379/0'

  module_function

  def client
    @client ||= Redis.new(url: url)
  end

  def url
    configured = ENV['REDIS_URL'].to_s.strip
    return configured if configured.match?(/\Arediss?:\/\//)

    DEFAULT_URL
  end

  def reset!
    @client = nil
  end
end
