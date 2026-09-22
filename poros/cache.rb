require_relative 'redis_connection'

class Cache
  REDIS_EXPIRATION_HOURS = 4
  REDIS_EXPIRATION_SECONDS = REDIS_EXPIRATION_HOURS * 60 * 60

  def initialize(content_name, properties)
    @content_name = content_name
    @properties = properties
    @redis = RedisConnection.client
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
    @redis.setex(cache_key, REDIS_EXPIRATION_SECONDS, response)
  end
end
