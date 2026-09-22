require 'spec_helper'
require 'rack/test'
require_relative '../../poros/data_generator'
require_relative '../../poros/rate_limiter'

RSpec.describe DataGenerator do
  let(:content_name) { 'test_content' }
  let(:properties) { %w[property1 property2] }
  let(:ip) { '127.0.0.1' }
  let(:redis) { instance_double(Redis) }
  let(:rate_limiter) { instance_double(RateLimiter) }
  let(:openai_client) { instance_double(OpenAIClient) }
  let(:cache) { instance_double(Cache) }
  let(:data_generator) { described_class.new(content_name:, properties:, ip:) }

  before do
    allow(RedisConnection).to receive(:client).and_return(redis)
    allow(RateLimiter).to receive(:new).and_return(rate_limiter)
    allow(OpenAIClient).to receive(:new).and_return(openai_client)
    allow(Cache).to receive(:new).and_return(cache)
  end

  describe '#initialize' do
    it 'initializes with content_name, properties, and ip' do
      expect(data_generator.content_name).to eq(content_name)
      expect(data_generator.properties).to eq(properties)
      expect(data_generator.ip).to eq(ip)
    end
  end

  describe '#generate' do
    context 'when data is cached' do
      it 'returns cached data' do
        allow(cache).to receive(:get).and_return('{"key":"value"}')
        allow(cache).to receive(:ttl).and_return(1000)

        expect(data_generator.generate).to eq(
          {
            data: { 'key' => 'value' },
            cached: true,
            time_to_expiration: (Time.now + 1000).strftime('%Y-%m-%d %H:%M')
          }
        )
      end
    end

    context 'when cached data is invalid JSON' do
      it 'ignores the cache and regenerates' do
        allow(cache).to receive(:get).and_return('not-json')
        allow(rate_limiter).to receive(:call).with(ip).and_return([200, {}, {}])
        allow(openai_client).to receive(:request_data).and_return('{"key":"value"}')
        expect(cache).to receive(:set).with('{"key":"value"}')

        expect(data_generator.generate).to eq({ data: { 'key' => 'value' }, cached: false })
      end
    end

    context 'when data is not cached' do
      before do
        allow(cache).to receive(:get).and_return(nil)
        allow(rate_limiter).to receive(:call).with(ip).and_return([200, {}, {}])
      end

      it 'generates new data and caches it' do
        allow(openai_client).to receive(:request_data).and_return('{"key":"value"}')
        expect(cache).to receive(:set).with('{"key":"value"}')

        expect(data_generator.generate).to eq({ data: { 'key' => 'value' }, cached: false })
      end

      it 'does not cache empty responses' do
        allow(openai_client).to receive(:request_data).and_return('   ')
        expect(cache).not_to receive(:set)

        expect { data_generator.generate }.to raise_error(StandardError, 'OpenAI returned an empty response')
      end

      it 'does not cache invalid JSON' do
        allow(openai_client).to receive(:request_data).and_return('not-json')
        expect(cache).not_to receive(:set)

        expect { data_generator.generate }.to raise_error(StandardError, 'OpenAI returned invalid JSON')
      end

      it 'does not cache non-object JSON values' do
        allow(openai_client).to receive(:request_data).and_return('"just a string"')
        expect(cache).not_to receive(:set)

        expect { data_generator.generate }.to raise_error(StandardError, 'OpenAI returned an unexpected JSON structure')
      end
    end
  end
end
