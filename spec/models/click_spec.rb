# frozen_string_literal: true

require 'spec_helper'

describe Click do
  let(:url) { 'http://www.fda.gov/foo.html' }
  let(:ip) { '0.0.0.0' }
  let(:position) { '7' }
  let(:module_code) { 'BWEB' }
  let(:params) do
    {
      url: url,
      query: 'my query',
      client_ip: ip,
      affiliate: 'nps.gov',
      position: position,
      module_code: module_code,
      vertical: 'web',
      user_agent: 'mozilla'
    }
  end

  subject(:click) { described_class.new params }

  context 'with required params' do
    before do
      Rails.logger.info "STARTING SPEC"
    end
    describe '#valid?' do
      it { is_expected.to be_valid }
    end

  end
end
