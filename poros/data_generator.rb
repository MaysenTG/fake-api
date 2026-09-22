require 'openai'
require 'json'

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
    if (cached = read_cache)
      return cached
    end

    check_rate_limit

    response = openai_client.request_data(content_name, properties)
    data = parse_valid_response!(response)
    cache.set(response)

    { data:, cached: false }
  end

  private

  def read_cache
    cached_response = cache.get
    return if cached_response.nil? || cached_response.empty?

    {
      data: JSON.parse(cached_response),
      cached: true,
      time_to_expiration: (Time.now + cache.ttl).strftime('%Y-%m-%d %H:%M')
    }
  rescue JSON::ParserError
    nil
  end

  def parse_valid_response!(response)
    raise StandardError, 'OpenAI returned an empty response' if response.nil? || response.strip.empty?

    data = JSON.parse(response)
    unless data.is_a?(Hash) || data.is_a?(Array)
      raise StandardError, 'OpenAI returned an unexpected JSON structure'
    end

    data
  rescue JSON::ParserError
    raise StandardError, 'OpenAI returned invalid JSON'
  end

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
