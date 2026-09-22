require 'spec_helper'
require 'redis'
require_relative '../../poros/cache'
require_relative '../../poros/redis_connection'

RSpec.describe Cache do
  let(:redis) { instance_double(Redis) }
  let(:cache) { described_class.new('people', %w[name age]) }

  before do
    RedisConnection.reset!
    allow(RedisConnection).to receive(:client).and_return(redis)
  end

  describe '#set' do
    it 'stores the response with the configured expiration' do
      expect(redis).to receive(:setex).with('people:age,name', Cache::REDIS_EXPIRATION_SECONDS, '{"ok":true}')

      cache.set('{"ok":true}')
    end
  end
end
