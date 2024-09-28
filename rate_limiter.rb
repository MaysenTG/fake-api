require 'dotenv/load'
require 'redis'

class RateLimiter
  def initialize
    @limit = ENV['RATE_LIMIT'].to_i
    @period = ENV['RATE_LIMIT_PERIOD'].to_i
    @rate_limiting_disabled = ENV['DISABLE_RATE_LIMITING'] == 'true'
    @redis = Redis.new(url: ENV['REDIS_URL'])
  end

  def call(ip)
    return [200, {}, {}] if @rate_limiting_disabled

    key = "#{ip}:#{Time.now.to_i / @period}"
    count = @redis.incr(key)
    @redis.expire(key, @period) if count == 1

    if count > @limit
      [429, { 'Content-Type' => 'application/json' },
       "Rate limit exceeded. You are limited to #{@limit} requests every #{@period} seconds. My wallet can't handle more than that."]
    else
      [200, {}, {}]
    end
  end
end
