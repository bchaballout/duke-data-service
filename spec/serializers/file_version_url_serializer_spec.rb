require 'rails_helper'

RSpec.describe FileVersionUrlSerializer, type: :serializer do
  let(:resource) { FactoryGirl.create(:file_version) }
  let(:expected_attributes) {{
    'http_verb' => resource.http_verb,
    'host' => resource.host,
    'url' => resource.url,
    'http_headers' => []
  }}

  it_behaves_like 'a json serializer' do
    it { is_expected.to include(expected_attributes) }
  end
end
