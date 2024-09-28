require 'spec_helper'
require 'rack/test'
require 'byebug'
require_relative '../../poros/data_generator'
require_relative '../../poros/rate_limiter'

RSpec.describe DataGenerator do
  let(:content_name) { 'test_content' }
  let(:properties) { %w[property1 property2] }
  let(:ip) { '127.0.0.1' }
  let(:redis) { instance_double(Redis) }
  let(:rate_limiter) { RateLimiter.new }
  let(:openai_client) { OpenAIClient.new }
  let(:data_generator) { described_class.new(content_name:, properties:, ip:) }

  before do
    allow(Redis).to receive(:new).and_return(redis)
    allow(RateLimiter).to receive(:new).and_return(rate_limiter)
    allow(OpenAIClient).to receive(:new).and_return(openai_client)
  end

  describe '#initialize' do
    it 'initializes with content_name, properties, and ip' do
      expect(data_generator.content_name).to eq(content_name)
      expect(data_generator.properties).to eq(properties)
      expect(data_generator.ip).to eq(ip)
    end
  end

  describe '#cache' do
    it 'returns a Cache instance' do
      expect(data_generator.send(:cache)).to be_a(Cache)
    end
  end

  describe '#rate_limiter' do
    it 'returns a RateLimiter instance' do
      expect(data_generator.send(:rate_limiter)).to be_a(RateLimiter)
    end
  end

  describe '#openai_client' do
    it 'returns an OpenAIClient instance' do
      expect(data_generator.send(:openai_client)).to be_a(OpenAIClient)
    end
  end

  describe '#check_rate_limit' do
    it 'raises Errors::RateLimiting when rate limit is exceeded' do
      allow(rate_limiter).to receive(:call).with(ip).and_return([429, {}, 'Rate limit exceeded'])
      expect { data_generator.send(:check_rate_limit) }.to raise_error(Errors::RateLimiting, 'Rate limit exceeded')
    end
  end

  describe '#generate' do
    context 'when data is cached' do
      it 'returns cached data' do
        allow(data_generator.send(:cache)).to receive(:get).and_return('{"key":"value"}')
        expect(data_generator.generate).to eq({ data: { 'key' => 'value' }, cached: true })
      end
    end

    context 'when data is not cached' do
      it 'generates new data and caches it' do
        allow(data_generator.send(:cache)).to receive(:get).and_return(nil)
        allow(data_generator).to receive(:check_rate_limit)
        allow(data_generator.send(:openai_client)).to receive(:request_data).and_return('{"key":"value"}')
        allow(data_generator.send(:cache)).to receive(:set).with('{"key":"value"}')

        expect(data_generator.generate).to eq({ data: { 'key' => 'value' }, cached: false })
      end
    end
  end
end
