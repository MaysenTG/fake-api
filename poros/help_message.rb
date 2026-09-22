class HelpMessage
  def self.help
    {
      message: "Fake API generates mock JSON from a content name. Send a GET request to /api/:content_name.",
      query_params: {
        content_name: 'The kind of data to generate (the :content_name path segment).',
        properties: 'Optional comma-separated fields to include on each item.',
        key: "Path to nest the payload under. Default is 'data'. Use slashes for nesting, e.g. data/v1."
      },
      info: 'Responses are cached by content name and properties.'
    }
  end
end
