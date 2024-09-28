require 'dotenv/load'
require 'redis'
require 'openai'
require 'byebug'

require_relative './rate_limiter'
require_relative '../errors/rate_limiting'
require_relative './cache'
require_relative './openai_client'

class DataGenerator
  attr_accessor :content_name, :properties, :ip

  def initialize(content_name:, properties:, ip:)
    @content_name = content_name
    @properties = properties
    @ip = ip
  end

  def self.generate(**kwargs)
    new(**kwargs).generate
  end

  def generate
    cached_response = cache.get
    if cached_response
      return { data: JSON.parse(cached_response), cached: true,
               time_to_expiration: (Time.now + cache.ttl).strftime('%Y-%m-%d %H:%M') }
    end

    check_rate_limit

    response = openai_client.request_data(content_name, properties)
    cache.set(response)
    { data: JSON.parse(response), cached: false }
  end

  private

  def check_rate_limit
    status, _, body = rate_limiter.call(@ip)
    raise Errors::RateLimiting, body if status == 429
  end

  def cache
    @cache ||= Cache.new(content_name, properties)
  end

  def rate_limiter
    @rate_limiter ||= RateLimiter.new
  end

  def openai_client
    @openai_client ||= OpenAIClient.new
  end
end
