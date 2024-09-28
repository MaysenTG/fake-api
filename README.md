# Fake APi

This is a simple Ruby Sinatra application that provides a fake API for generating data. Given a type of content, OpenAI's API will return with a JSON object with relevant information based on the content name. Results are cached based on the properties and content name. Only results that aren't cached are rate limited, so fetch to your heart's content for cached content.

## Features

- Generate fake API data based on user prompts
- Rate limiting to prevent abuse
- Caching of responses to improve performance

## Getting Started

### Prerequisites

- Ruby (version 2.7 or higher)
- Bundler
- Redis
- OpenAI API Key

### Installation

1. **Clone the repository:**

   ```sh
   git clone https://github.com/MaysenTG/fake-api.git
   cd fake-api
   ```

2. **Install dependencies:**

   ```sh
   bundle install
   ```

3. **Set up environment variables:**

   Create a `.env` file in the root directory and add your OpenAI API key and Redis URL:

   ```env
   OPENAI_API_KEY=your_openai_api_key
   REDIS_URL=redis://localhost:6379/0
   ```

4. **Start the Redis server (assuming Redis on MacOS via Brew):**

   ```sh
   brew services start redis
   ```

5. **Run the application:**

   ```sh
   bundle exec bin/rackup -p 4567
   ```

   The application will be available at `http://localhost:4567`.

### Usage

- **Get help message:**

  ```sh
  curl http://localhost:4567/
  ```

- **Generate fake API data:**

  ```sh
  curl http://localhost:4567/api/your_route_name
  ```

  You can also specify properties and a key (for how the data is returned in the JSON response):

  ```sh
  curl http://localhost:4567/api/your_route_name?properties=prop1,prop2&key=your_key
  ```

  Rate limiting is disabled by default through the `.env` file, but can be enabled by changing `DISABLE_RATE_LIMITING` to true

  To change the rate limit configuration, update `RATE_LIMIT` and `RATE_LIMIT_PERIOD` in the .env file. `RATE_LIMIT_PERIOD` is in seconds, and defaults to 60 seconds.

### License

This project is licensed under the MIT License. See the LICENSE file for details.

### Acknowledgements

- [Sinatra](http://sinatrarb.com/)
- [Redis](https://redis.io/)
- [OpenAI](https://www.openai.com/)
