require 'redis'
require 'dotenv/load'
require 'byebug'

class Cache
  REDIS_EXPIRATION_HOURS = 4

  def initialize(content_name, properties)
    @content_name = content_name
    @properties = properties
    @redis = Redis.new(url: ENV['REDIS_URL'])
    @cache_expiration = REDIS_EXPIRATION_HOURS * 60 * 60
  end

  def cache_key
    "#{@content_name}:#{@properties.sort.join(',')}"
  end

  def get
    @redis.get(cache_key)
  end

  def ttl
    @redis.ttl(cache_key)
  end

  def set(response)
    @redis.set(cache_key, response)
    @redis.expire(cache_key, 3600) # Set expiration time to 1 hour (3600 seconds)
  end
end
