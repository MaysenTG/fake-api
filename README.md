# Sinatra API App

This is a simple Ruby Sinatra application that provides a fake API for generating data. It includes rate limiting to prevent abuse of the API.

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
   ruby fakeapi.rb
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

### License

This project is licensed under the MIT License. See the LICENSE file for details.

### Acknowledgements

- [Sinatra](http://sinatrarb.com/)
- [Redis](https://redis.io/)
- [OpenAI](https://www.openai.com/)
