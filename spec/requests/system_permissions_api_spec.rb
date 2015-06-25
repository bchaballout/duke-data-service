require 'rails_helper'
require 'jwt'
require 'securerandom'

describe DDS::V1::SystemPermissionsAPI do
  let(:json_headers) { { 'Accept' => 'application/json', 'Content-Type' => 'application/json'} }
  let(:user) { FactoryGirl.create(:user) }
  let(:auth_user) { FactoryGirl.create(:user, :with_auth_role) }

  describe 'List system permissions' do
    it 'should return a list of users and auth_role objects' do
      user_role_hash = {
        user: auth_user.uuid
      }
      user_role_hash[:auth_roles] = auth_user.auth_roles.collect do |role|
        {
          id: role.text_id,
          name: role.name,
          description: role.description,
          permissions: role.permissions,
          contexts: role.contexts,
          is_deprecated: role.is_deprecated
        }.stringify_keys
      end
      get '/api/v1/system/permissions', json_headers
      expect(response.status).to eq(200)
      expect(response.body).to be
      expect(response.body).not_to eq('null')
      response_json = JSON.parse(response.body)
      expect(response_json).to have_key('results')
      expect(response_json['results']).to be_a Array
      expect(response_json['results']).to include(user_role_hash.stringify_keys)
    end
  end

  describe 'Grant system permissions to user' do
    it 'should set auth_roles for a given user' do
      payload = {
        auth_roles: ['platform_user']
      }
      put "/api/v1/system/permissions/#{user.id}", payload.to_json, json_headers
      expect(response.status).to eq(200)
      expect(response.body).to be
      expect(response.body).not_to eq('null')
      response_json = JSON.parse(response.body)
      expect(response_json).to have_key('user')
      expect(response_json['user']).to eq(user.uuid)
      expect(response_json).to have_key('auth_roles')
      expect(response_json['auth_roles']).to be_a Array
      expect(response_json['auth_roles']).to eq(payload[:auth_roles])
    end
  end

  describe 'View system permissions for user' do
    it 'should get auth_roles for a given user' do
      get "/api/v1/system/permissions/#{auth_user.id}", json_headers
      expect(response.status).to eq(200)
      expect(response.body).to be
      expect(response.body).not_to eq('null')
      response_json = JSON.parse(response.body)
      expect(response_json).to have_key('user')
      expect(response_json['user']).to eq(auth_user.uuid)
      expect(response_json).to have_key('auth_roles')
      expect(response_json['auth_roles']).to be_a Array
      expect(response_json['auth_roles']).to eq(auth_user.auth_role_ids)
    end
  end

  describe 'Revoke system permissions for user' do
    it 'should delete all auth_roles for a given user' do
      delete "/api/v1/system/permissions/#{auth_user.id}", json_headers
      expect(response.status).to eq(204)
      expect(response.body).to be
      expect(response.body).not_to eq('null')
      auth_user.reload
      expect(auth_user.auth_role_ids).to be_nil
    end
  end
end
