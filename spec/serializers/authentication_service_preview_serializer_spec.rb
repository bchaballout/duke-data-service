require 'rails_helper'

RSpec.describe AuthenticationServicePreviewSerializer, type: :serializer do
  describe 'duke_authentication_service' do
      let(:resource) { FactoryGirl.create(:duke_authentication_service) }
      it_behaves_like 'an authentication_service_preview_serializer serializable resource'
  end

  describe 'openid_authentication_service' do
    let(:resource) { FactoryGirl.create(:openid_authentication_service) }
    it_behaves_like 'an authentication_service_preview_serializer serializable resource'
  end
end
