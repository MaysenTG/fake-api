require 'spec_helper'
require 'rack/test'
require 'redis'
require 'byebug'
require_relative '../rate_limiter'

RSpec.describe RateLimiter do
  let(:redis) { instance_double(Redis) }
  let(:rate_limiter) { RateLimiter.new }
  let(:ip) { '127.0.0.1' }

  before do
    allow(Redis).to receive(:new).and_return(redis)
    allow(ENV).to receive(:[]).with('RATE_LIMIT').and_return('5')
    allow(ENV).to receive(:[]).with('RATE_LIMIT_PERIOD').and_return('60')
    allow(ENV).to receive(:[]).with('REDIS_URL').and_return('redis://localhost:6379/0')
  end

  describe '#call' do
    context 'when rate limiting is disabled' do
      before do
        allow(ENV).to receive(:[]).with('DISABLE_RATE_LIMITING').and_return('true')
      end

      it 'returns a 200 status' do
        status, headers, body = rate_limiter.call(ip)
        expect(status).to eq(200)
        expect(headers).to eq({})
        expect(body).to eq({})
      end
    end

    context 'when rate limiting is enabled' do
      before do
        allow(ENV).to receive(:[]).with('DISABLE_RATE_LIMITING').and_return('false')
      end

      it 'returns a 200 status when within limit' do
        allow(redis).to receive(:incr).and_return(1)
        allow(redis).to receive(:expire)

        status, headers, body = rate_limiter.call(ip)
        expect(status).to eq(200)
        expect(headers).to eq({})
        expect(body).to eq({})
      end

      it 'returns a 429 status when limit is exceeded' do
        allow(redis).to receive(:incr).and_return(6)
        allow(redis).to receive(:expire)

        status, headers, body = rate_limiter.call(ip)
        expect(status).to eq(429)
        expect(headers).to eq({ 'Content-Type' => 'application/json' })
        expect(body).to eq("Rate limit exceeded. You are limited to 5 requests every 60 seconds. My wallet can't handle more than that.")
      end

      it 'sets the expiration on the Redis key' do
        allow(redis).to receive(:incr).and_return(1)
        expect(redis).to receive(:expire).with("#{ip}:#{Time.now.to_i / 60}", 60)

        rate_limiter.call(ip)
      end
    end
  end
end
