require 'rails_helper'

RSpec.describe StorageProvider, type: :model do
  describe "swift access method", :if => ENV['SWIFT_USER'] do
    # these tests only run if the SWIFT ENV variables are set
    # to allow it to communicate with a SWIFT backend
    before(:all) do
      @subject = FactoryGirl.create(:storage_provider, :swift_env)
      @auth_resp = HTTParty.get(
          "#{ENV['SWIFT_URL_ROOT']}#{ENV['SWIFT_AUTH_URI']}",
          headers: {
            'X-Auth-User' => ENV['SWIFT_USER'],
            'X-Auth-Key' => ENV['SWIFT_PASS']})
      @project = FactoryGirl.create(:project)
      @existing_upload = FactoryGirl.create(:upload,
        project_id: @project.id,
        storage_provider_id: @subject.id)
      HTTParty.put(
        "#{@auth_resp['x-storage-url']}/#{@project.id}",
        headers:{"X-Auth-Token" => @auth_resp['x-auth-token']})
    end

    after(:all) do
      resp = HTTParty.get(
        "#{@auth_resp['x-storage-url']}/#{@project.id}",
        headers:{"X-Auth-Token" => @auth_resp['x-auth-token']}
      )
      if resp.headers['x-container-object-count'].to_i > 0
        resp.body.split("\n").each do |obj|
          resp = HTTParty.delete(
            "#{@auth_resp['x-storage-url']}/#{@project.id}/#{obj}",
            headers:{"X-Auth-Token" => @auth_resp['x-auth-token']})
        end
      end

      HTTParty.delete(
        "#{@auth_resp['x-storage-url']}/#{@project.id}",
        headers:{"X-Auth-Token" => @auth_resp['x-auth-token']})

      HTTParty.post(
        @auth_resp['x-storage-url'],
          headers:{
            "X-Auth-Token" => @auth_resp['x-auth-token'],
            'X-Account-Meta-Temp-URL-Key' => @subject.primary_key,
            'X-Account-Meta-Temp-URL-Key-2' => @subject.secondary_key})
    end

    describe "register_keys" do
      it 'should register the primary and secondary key with the swift account' do
        unexpected_key = 'unexpected'
        expect(@subject).to respond_to('register_keys')
        resp = HTTParty.get(@auth_resp['x-storage-url'], headers:{"X-Auth-Token" => @auth_resp['x-auth-token']})
        if resp.headers['x-account-meta-temp-url-key']
          #temporarily unset them
          HTTParty.post(
            @auth_resp['x-storage-url'],
              headers:{
                "X-Auth-Token" => @auth_resp['x-auth-token'],
                'X-Account-Meta-Temp-URL-Key' => unexpected_key,
                'X-Account-Meta-Temp-URL-Key-2' => unexpected_key})
        end
        @subject.register_keys
        resp = HTTParty.get(@auth_resp['x-storage-url'], headers:{"X-Auth-Token" => @auth_resp['x-auth-token']})
        expect(resp.headers['x-account-meta-temp-url-key']).to eq(@subject.primary_key)
        expect(resp.headers['x-account-meta-temp-url-key-2']).to eq(@subject.secondary_key)
      end
    end

    describe "get_signed_url" do
      before(:all) do
        @new_upload = FactoryGirl.create(:upload,
          project_id: @project.id,
          storage_provider_id: @subject.id)
        @new_chunk = FactoryGirl.create(:chunk,
          upload_id: @new_upload.id)
        @existingobject = Faker::Lorem.characters(100)

        HTTParty.put(
          "#{@auth_resp['x-storage-url']}/#{@project.id}/#{@existing_upload.id}",
           body: @existingobject,
           headers:{"X-Auth-Token" => @auth_resp['x-auth-token']})
      end

      it 'should take an upload and return a signed tempoary url to GET the upload object' do
        expect(@subject).to respond_to('get_signed_url')
        url = @subject.get_signed_url(@existing_upload)
        expect(url).to match([
          @subject.provider_version,
          @subject.name,
          @project.id,
          @existing_upload.id
        ].join('/'))

        temp_url = "#{@subject.url_root}#{url}"
        resp = HTTParty.get("#{temp_url}")
        expect(resp.response.code.to_i).to eq(200)
        expect(resp.body).to eq(@existingobject)
      end

      it 'should take a chunk and method PUT and return a signed tempoary url to PUT data for the chunk object' do
        new_data = Faker::Lorem.characters(100)
        expect(@subject).to respond_to('get_signed_url')
        url = @subject.get_signed_url(@new_chunk, 'PUT')
        expect(url).to match([
          @subject.provider_version,
          @subject.name,
          @project.id,
          @new_upload.id,
          @new_chunk.id,
          @new_chunk.number
        ].join('/'))
        resp = HTTParty.put("#{@subject.url_root}/#{url}", body: new_data)
        expect(resp.response.code.to_i).to eq(201)
        resp = HTTParty.get(
            "#{@auth_resp['x-storage-url']}/#{@project.id}/#{@new_upload.id}/#{@new_chunk.id}/#{@new_chunk.number}",
            headers:{"X-Auth-Token" => @auth_resp['x-auth-token']})
        expect(resp.body).to eq(new_data)
      end
    end

    describe "create_slo_manifest" do
      before(:all) do
        @chunk_data = []
        @chunks = []
        10.times do |i|
          chunk_number = i + 1
          chunk_data = Faker::Lorem.characters(1048576)
          @chunk_data << chunk_data
          chunk = FactoryGirl.create(:chunk,
            upload_id: @existing_upload.id,
            size: chunk_data.length,
            fingerprint_value: Digest::MD5.hexdigest(chunk_data),
            number: chunk_number
           )
           HTTParty.put(
             "#{@auth_resp['x-storage-url']}/#{chunk.upload.project.id}/#{chunk.upload.id}/#{chunk.id}/#{chunk.number}",
             body: chunk_data,
             headers:{"X-Auth-Token" => @auth_resp['x-auth-token']})
           @chunks << chunk
        end
      end

      it 'should take an upload, and create a manifest file for each chunk, then upload the manifest as an slo to the upload' do
        expect(@subject).to respond_to('create_slo_manifest')
        HTTParty.delete(
          "#{@auth_resp['x-storage-url']}/#{@project.id}/#{@existing_upload.id}",
          headers:{"X-Auth-Token" => @auth_resp['x-auth-token']})
        @subject.create_slo_manifest(@existing_upload)
        resp = HTTParty.get(
          "#{@auth_resp['x-storage-url']}/#{@project.id}/#{@existing_upload.id}",
          headers:{"X-Auth-Token" => @auth_resp['x-auth-token']})
        expect(resp.response.code.to_i).to eq(200)
        expect(resp.body).to eq(@chunk_data.join(''))
      end
    end
  end
end