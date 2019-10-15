shared_examples 'an Elasticsearch client' do
  describe 'configuration' do
    it 'uses a persistent connection' do
      handler = client.transport.connections.first.connection.builder.handlers.first
      expect(handler).to eq(Faraday::Adapter::Typhoeus)
    end

    it 'uses the specified options' do
      options = {
        log: false,
        randomize_connections: true,
        reload_connections: true,
        reload_on_failure: true,
        retry_on_failure: true
      }
      expect(client.transport.options).to include(options)
    end

    it 'can connect to Elasticsearch' do
      expect(client.ping).to eq(true)
    end
  end
end
