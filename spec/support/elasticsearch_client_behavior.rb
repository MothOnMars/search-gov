shared_examples 'an Elasticsearch client' do
  describe 'configuration' do
    it 'uses a persistent connection' do
      handler = client.transport.connections.first.connection.builder.handlers.first
      expect(handler).to eq(Faraday::Adapter::Typhoeus)
    end

    it 'uses the specified options' do
      puts client.transport.options.to_s.red
      expect(client.transport.options).to include( retry_on_failure: true )
    end

    it 'can connect to Elasticsearch' do
      expect(client.ping).to eq(true)
    end
  end
end
