require 'rails_helper'
RSpec.describe InvalidatedByActivityProvRelationSerializer, type: :serializer do
  let(:resource) { FactoryGirl.create(:invalidated_by_activity_prov_relation) }
  it_behaves_like 'a ProvRelationSerializer', from: FileVersionSerializer, to: ActivitySerializer
end
