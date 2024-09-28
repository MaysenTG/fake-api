require 'spec_helper'
require_relative '../../errors/rate_limiting'

RSpec.describe Errors::RateLimiting do
  describe '#initialize' do
    context 'with default parameters' do
      let(:error) { described_class.new }

      it 'sets the default message' do
        expect(error.message).to eq('Rate limit exceeded')
      end

      it 'sets the default status' do
        expect(error.status).to eq(429)
      end
    end

    context 'with custom parameters' do
      let(:custom_message) { 'Custom rate limit message' }
      let(:custom_status) { 403 }
      let(:error) { described_class.new(custom_message, custom_status) }

      it 'sets the custom message' do
        expect(error.message).to eq(custom_message)
      end

      it 'sets the custom status' do
        expect(error.status).to eq(custom_status)
      end
    end
  end

  describe '#status' do
    it 'returns the status' do
      error = described_class.new
      expect(error.status).to eq(429)
    end
  end

  describe '#message' do
    it 'returns the message' do
      error = described_class.new
      expect(error.message).to eq('Rate limit exceeded')
    end
  end
end
