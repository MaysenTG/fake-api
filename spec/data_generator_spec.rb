require 'spec_helper'
require 'rack/test'
require 'byebug'
require_relative '../data_generator'

RSpec.describe DataGenerator do
  let(:content_name) { 'test_content' }
  let(:properties) { %w[property1 property2] }
  let(:ip) { '127.0.0.1' }
  let(:redis) { instance_double(Redis) }
  let(:rate_limiter) { instance_double(RateLimiter) }
  let(:openai_client) { instance_double(OpenAI::Client) }
  let(:data_generator) { described_class.new(content_name:, properties:, ip:) }

  before do
    allow(Redis).to receive(:new).and_return(redis)
    allow(RateLimiter).to receive(:new).and_return(rate_limiter)
    allow(OpenAI::Client).to receive(:new).and_return(openai_client)
  end

  describe '#initialize' do
    it 'initializes with content_name, properties, and ip' do
      expect(data_generator.content_name).to eq(content_name)
      expect(data_generator.properties).to eq(properties)
    end
  end

  describe '#cache_key' do
    it 'generates the correct cache key' do
      expect(data_generator.cache_key).to eq('test_content:property1,property2')
    end
  end

  describe '#cached_response' do
    it 'retrieves the correct cached response' do
      allow(redis).to receive(:get).with('test_content:property1,property2').and_return('{"key":"value"}')
      expect(data_generator.cached_response).to eq('{"key":"value"}')
    end
  end

  describe '#check_rate_limit' do
    it 'raises RateLimitingError when rate limit is exceeded' do
      allow(rate_limiter).to receive(:call).with(ip).and_return([429, {}, 'Rate limit exceeded'])
      expect { data_generator.send(:check_rate_limit) }.to raise_error(RateLimitingError, 'Rate limit exceeded')
    end
  end

  describe '#generate' do
    context 'when data is cached' do
      it 'returns cached data' do
        allow(data_generator).to receive(:cached_response).and_return('{"key":"value"}')
        expect(data_generator.generate).to eq({ 'key' => 'value' })
      end
    end

    context 'when data is not cached' do
      it 'generates new data and caches it' do
        allow(data_generator).to receive(:cached_response).and_return(nil)
        allow(data_generator).to receive(:check_rate_limit)
        allow(data_generator).to receive(:request_openai_data).and_return('{"key":"value"}')
        allow(redis).to receive(:set).with('test_content:property1,property2', '{"key":"value"}')

        expect(data_generator.generate).to eq({ 'key' => 'value' })
      end
    end
  end

  describe '#request_openai_data' do
    it 'requests data from OpenAI' do
      allow(openai_client).to receive(:chat).and_return('choices' => [{ 'message' => { 'content' => '{"key":"value"}' } }])
      expect(data_generator.send(:request_openai_data)).to eq('{"key":"value"}')
    end
  end
end
