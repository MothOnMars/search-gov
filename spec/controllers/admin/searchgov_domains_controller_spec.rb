require 'spec_helper'

describe Admin::SearchgovDomainsController do
  let(:searchgov_domain) { searchgov_domains(:agency_domain) }
  let(:params) do
    { id: searchgov_domain.id }
  end

  include_context 'super admin logged in' do
    describe '#reindex' do
      subject(:reindex) { post :reindex, params: params }

      it 'triggers a reindex on the domain' do
        expect_any_instance_of(SearchgovDomain).to receive(:reindex)
        reindex
      end
    end
  end
end
