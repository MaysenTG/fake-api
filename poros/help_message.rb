class HelpMessage
  def self.help
    {
      message: "This is an API that generates fake data based on a user's prompt. To generate fake data, send a GET request to the /api/:content_name endpoint.",
      query_params: {
        content_name: 'The name of the data you want to generate. Replace :content_name with the name of the data you want to generate.',
        properties: 'A list of properties to include in the generated data. Separate multiple properties with commas.',
        key: 'The key to use for the returned data. Default is \'data\'. If you wanted nested keys, separate them with slashes. For example: \'/data/0/name\''
      },
      info: 'API responses are cached based on the content name and properties'
    }
  end
end
