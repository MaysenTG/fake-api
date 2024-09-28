require 'dotenv/load'
require 'redis'

class RateLimiter
  def initialize(options = {})
    @limit = options[:limit] || 50
    @period = options[:period] || 60
    @redis = Redis.new(url: ENV['REDIS_URL'])
  end

  def call(ip)
    key = "#{ip}:#{Time.now.to_i / @period}"
    count = @redis.incr(key)
    @redis.expire(key, @period) if count == 1

    if count > @limit
      [429, { 'Content-Type' => 'application/json' },
       "Rate limit exceeded. You are limited to #{@limit} requests every #{@period} seconds. My wallet can't handle more than that."]
    else
      [200, {}, []]
    end
  end
end
