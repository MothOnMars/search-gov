shared_examples 'an Elasticsearch client' do
  describe 'configuration' do
    it 'uses a persistent connection' do
      handler = client.transport.connections.first.connection.builder.handlers.first
      expect(handler).to eq(Faraday::Adapter::Typhoeus)
    end
  end
end
