require 'spec_helper'
require 'rack/test'
require_relative '../fakeapi'
require 'byebug'

RSpec.describe FakeApi do
  include Rack::Test::Methods

  def app
    FakeApi.new
  end

  describe 'GET /' do
    it 'returns the help message' do
      get '/'
      expect(last_response).to be_ok
      expect(parse_json(last_response)).to eq({ message: HelpMessage.help })
    end
  end

  describe 'GET /api' do
    it 'returns the help message' do
      get '/api'
      expect(last_response).to be_ok
      expect(parse_json(last_response)).to eq({ message: HelpMessage.help })
    end
  end

  describe 'GET /api/:route_name' do
    before do
      allow(DataGenerator).to receive(:generate).and_return({ 'people' => [{ name: 'Maysen', age: 100 },
                                                                           { name: 'Bob', age: 101 }] })
    end

    context 'with valid parameters' do
      it 'returns generated data' do
        get '/api/people?properties=name,age'
        expect(last_response).to be_ok
        response = parse_json(last_response)
        expect(response[:input]).to eq({ content_type: 'people', properties: %w[name age] })
      end
    end

    context 'when passing in a key' do
      it 'returns an error message' do
        get '/api/people?properties=name,age&key=api/v1'
        expect(last_response.status).to eq(200)
        expect(parse_json(last_response)).to have_key(:api)
        expect(parse_json(last_response)[:api]).to have_key(:v1)
        expect(parse_json(last_response)[:api][:v1]).to eq({ people: [{ name: 'Maysen', age: 100 },
                                                                      { name: 'Bob', age: 101 }] })
      end
    end

    context 'when rate limited' do
      before do
        allow(DataGenerator).to receive(:generate).and_raise(RateLimitingError.new('Rate limit exceeded'))
      end

      it 'returns a rate limiting error' do
        get '/api/test_route'
        expect(last_response.status).to eq(429)
        expect(parse_json(last_response)).to eq({ error: 'Rate limit exceeded' })
      end
    end
  end

  describe 'not_found' do
    it 'returns an error message for nested routes' do
      get '/api/nested/route/too/deep'
      expect(last_response.status).to eq(404)
      expect(parse_json(last_response)).to eq({ error: "We don't accept nested routes" })
    end

    it 'returns a not found message for other paths' do
      get '/nonexistent'
      expect(last_response.status).to eq(404)
      expect(parse_json(last_response)).to eq({ message: 'This is nowhere to be found.' })
    end
  end
end
