require 'rails_helper'

describe DDS::V1::RelationsAPI do
  include_context 'with authentication'

  let(:viewable_project) { FactoryGirl.create(:project) }
  let(:view_auth_role) { FactoryGirl.create(:auth_role,
      id: "project_viewer",
      name: "Project Viewer",
      description: "Can only view project and file meta-data",
      contexts: %w(project),
      permissions: %w(view_project)
    )
  }

  let(:view_project_permission) { FactoryGirl.create(:project_permission, auth_role: view_auth_role, user: current_user, project: viewable_project) }
  let(:viewable_data_file) { FactoryGirl.create(:data_file, project: view_project_permission.project) }
  let(:used_file_version) { FactoryGirl.create(:file_version, data_file: viewable_data_file) }
  let(:generated_file_version) { FactoryGirl.create(:file_version, data_file: viewable_data_file) }

  let(:activity) { FactoryGirl.create(:activity, creator: current_user)}
  let(:other_user) { FactoryGirl.create(:user) }
  let(:other_users_activity) { FactoryGirl.create(:activity, creator: other_user) }

  describe 'Provenance Relations collection' do
    describe 'Create used relation' do
      let(:url) { "/api/v1/relations/used" }
      subject { post(url, payload.to_json, headers) }
      let(:resource_class) { UsedProvRelation }
      let(:called_action) { "POST" }
      let(:payload) {{
        activity: {
          id: activity.id
        },
        entity: {
          kind: used_file_version.kind,
          id: used_file_version.id
        }
      }}
      let(:resource_serializer) { UsedProvRelationSerializer }

      it_behaves_like 'a creatable resource'

      context 'with other users activity' do
        let(:payload) {{
          activity: {
            id: other_users_activity.id
          },
          entity: {
            kind: used_file_version.kind,
            id: used_file_version.id
          }
        }}
        it 'returns a Forbidden response' do
          is_expected.to eq(403)
          expect(response.status).to eq(403)
        end
      end

      context 'without activity in payload' do
        let(:payload) {{
          entity: {
            kind: used_file_version.kind,
            id: used_file_version.id
          }
        }}
        it 'returns a failed response' do
          is_expected.to eq(400)
          expect(response.status).to eq(400)
        end
      end

      context 'without entity in payload' do
        let(:payload) {{
          activity: {
            id: activity.id
          }
        }}

        it 'returns a failed response' do
          is_expected.to eq(400)
          expect(response.status).to eq(400)
        end
      end

      it_behaves_like 'an authenticated resource'
      it_behaves_like 'an authorized resource' do
        let(:resource_permission) { view_project_permission }
      end

      it_behaves_like 'a software_agent accessible resource' do
        let(:expected_response_status) { 201 }
        it_behaves_like 'an annotate_audits endpoint' do
          let(:expected_response_status) { 201 }
          let(:expected_auditable_type) { ProvRelation }
        end
      end
      it_behaves_like 'an annotate_audits endpoint' do
        let(:expected_response_status) { 201 }
        let(:expected_auditable_type) { ProvRelation }
      end
    end # 'Create used relation'

    describe 'Create was generated by relation' do
      let(:url) { "/api/v1/relations/was_generated_by" }
      subject { post(url, payload.to_json, headers) }
      let(:resource_class) { GeneratedByActivityProvRelation }
      let(:called_action) { "POST" }
      let(:payload) {{
        activity: {
          id: activity.id
        },
        entity: {
          kind: generated_file_version.kind,
          id: generated_file_version.id
        }
      }}
      let(:resource_serializer) { GeneratedByActivityProvRelationSerializer }

      it_behaves_like 'a creatable resource'

      context 'with other users activity' do
        let(:payload) {{
          activity: {
            id: other_users_activity.id
          },
          entity: {
            kind: generated_file_version.kind,
            id: generated_file_version.id
          }
        }}
        it 'returns a Forbidden response' do
          is_expected.to eq(403)
          expect(response.status).to eq(403)
        end
      end

      context 'without activity in payload' do
        let(:payload) {{
          entity: {
            kind: generated_file_version.kind,
            id: generated_file_version.id
          }
        }}
        it 'returns a failed response' do
          is_expected.to eq(400)
          expect(response.status).to eq(400)
        end
      end

      context 'without entity in payload' do
        let(:payload) {{
          activity: {
            id: activity.id
          }
        }}

        it 'returns a failed response' do
          is_expected.to eq(400)
          expect(response.status).to eq(400)
        end
      end

      it_behaves_like 'an authenticated resource'
      it_behaves_like 'an authorized resource' do
        let(:resource_permission) { view_project_permission }
      end

      it_behaves_like 'a software_agent accessible resource' do
        let(:expected_response_status) { 201 }
        it_behaves_like 'an annotate_audits endpoint' do
          let(:expected_response_status) { 201 }
          let(:expected_auditable_type) { ProvRelation }
        end
      end
      it_behaves_like 'an annotate_audits endpoint' do
        let(:expected_response_status) { 201 }
        let(:expected_auditable_type) { ProvRelation }
      end
    end # 'Create was generated by relation'

    describe 'Create was derived from relation' do
      let(:url) { "/api/v1/relations/was_derived_from" }
      subject { post(url, payload.to_json, headers) }
      let(:resource_class) { DerivedFromFileVersionProvRelation }
      let(:called_action) { "POST" }
      let(:payload) {{
        used_entity: {
          kind: used_file_version.kind,
          id: used_file_version.id
        },
        generated_entity: {
          kind: generated_file_version.kind,
          id: generated_file_version.id
        }
      }}
      let(:resource_serializer) { DerivedFromFileVersionProvRelationSerializer }

      it_behaves_like 'a creatable resource'

      context 'without used_entity in payload' do
        let(:payload) {{
          generated_entity: {
            kind: generated_file_version.kind,
            id: generated_file_version.id
          }
        }}
        it 'returns a failed response' do
          is_expected.to eq(400)
          expect(response.status).to eq(400)
        end
      end

      context 'without generated_entity in payload' do
        let(:payload) {{
          used_entity: {
            kind: used_file_version.kind,
            id: used_file_version.id
          }
        }}

        it 'returns a failed response' do
          is_expected.to eq(400)
          expect(response.status).to eq(400)
        end
      end

      it_behaves_like 'an authenticated resource'
      it_behaves_like 'an authorized resource' do
        let(:resource_permission) { view_project_permission }
      end

      it_behaves_like 'a software_agent accessible resource' do
        let(:expected_response_status) { 201 }
        it_behaves_like 'an annotate_audits endpoint' do
          let(:expected_response_status) { 201 }
          let(:expected_auditable_type) { ProvRelation }
        end
      end
      it_behaves_like 'an annotate_audits endpoint' do
        let(:expected_response_status) { 201 }
        let(:expected_auditable_type) { ProvRelation }
      end
    end # 'Create was derived from relation'

    describe 'Create was invalidated by relation' do
      let(:url) { "/api/v1/relations/was_invalidated_by" }
      subject { post(url, payload.to_json, headers) }
      let(:resource_class) { InvalidatedByActivityProvRelation }
      let(:called_action) { "POST" }
      let(:deletable_project) { FactoryGirl.create(:project) }
      let(:delete_auth_role) { FactoryGirl.create(:auth_role,
          id: "file_deleter",
          name: "File Deleter",
          description: "Can only delete files",
          contexts: %w(project),
          permissions: %w(delete_file)
        )
      }

      let(:delete_file_permission) { FactoryGirl.create(:project_permission, auth_role: delete_auth_role, user: current_user, project: deletable_project) }
      let(:deletable_data_file) { FactoryGirl.create(:data_file, project: delete_file_permission.project) }
      let(:invalidated_file_version) { FactoryGirl.create(:file_version, :deleted, data_file: deletable_data_file) }

      let(:payload) {{
        activity: {
          id: activity.id
        },
        entity: {
          kind: invalidated_file_version.kind,
          id: invalidated_file_version.id
        }
      }}
      let(:resource_serializer) { InvalidatedByActivityProvRelationSerializer }

      context 'with entity that has not been deleted' do
        before do
          invalidated_file_version.update(is_deleted: false)
        end
        it 'returns a validation failure response' do
          is_expected.to eq(400)
          expect(response.status).to eq(400)
        end
      end

      context 'without entity in payload' do
        let(:payload) {{
          activity: {
            id: activity.id
          }
        }}
        it 'returns a failed response' do
          is_expected.to eq(400)
          expect(response.status).to eq(400)
        end
      end

      context 'without activity in payload' do
        let(:payload) {{
          entity: {
            kind: invalidated_file_version.kind,
            id: invalidated_file_version.id
          }
        }}

        it 'returns a failed response' do
          is_expected.to eq(400)
          expect(response.status).to eq(400)
        end
      end

      it_behaves_like 'a creatable resource'
      it_behaves_like 'an authenticated resource'
      it_behaves_like 'an authorized resource' do
        let(:resource_permission) { delete_file_permission }
      end

      it_behaves_like 'a software_agent accessible resource' do
        let(:expected_response_status) { 201 }
        it_behaves_like 'an annotate_audits endpoint' do
          let(:expected_response_status) { 201 }
          let(:expected_auditable_type) { ProvRelation }
        end
      end
      it_behaves_like 'an annotate_audits endpoint' do
        let(:expected_response_status) { 201 }
        let(:expected_auditable_type) { ProvRelation }
      end
    end # 'Create was invalidated by relation'

  end # 'Provenance Relations Relations collection'
end
