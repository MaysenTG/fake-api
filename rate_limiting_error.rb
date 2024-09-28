class RateLimitingError < StandardError
  attr_reader :status, :message

  def initialize(message = 'Rate limit exceeded', status = 429)
    @message = message
    @status = status
    super(message)
  end
end
