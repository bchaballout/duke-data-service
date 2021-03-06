require 'rails_helper'

describe "db:data:migrate" do
  include_context "rake"
  let(:task_path) { "lib/tasks/db_data_migrate" }
  let(:current_user) { FactoryGirl.create(:user) }
  let(:file_version_audits) { Audited.audit_class.where(auditable: FileVersion.all) }
  let(:data_file_audits) { Audited.audit_class.where(auditable: DataFile.all) }

  it { expect(subject.prerequisites).to  include("environment") }

  describe "#invoke" do
    context 'when creating fingerprints' do
      let(:fingerprint_upload) { FactoryGirl.create(:fingerprint).upload }
      let(:incomplete_upload_with_fingerprint_value) { FactoryGirl.create(:upload, fingerprint_value: SecureRandom.hex, fingerprint_algorithm: 'md5') }
      let(:upload_with_fingerprint_value) { FactoryGirl.create(:upload, :completed, :skip_validation, fingerprint_value: SecureRandom.hex, fingerprint_algorithm: 'md5') }
      let(:upload_with_capitalized_algorithm) { FactoryGirl.create(:upload, :completed, :skip_validation, fingerprint_value: SecureRandom.hex, fingerprint_algorithm: 'MD5') }
      let(:upload_with_invalid_fingerprint_algorithm) { FactoryGirl.create(:upload, :completed, :skip_validation, fingerprint_value: SecureRandom.hex, fingerprint_algorithm: 'md5000') }
      context 'for upload without fingerprint_value' do
        before { FactoryGirl.create(:upload) }
        it { expect {invoke_task}.not_to change{Fingerprint.count} }
        it { expect {invoke_task}.not_to change{Audited.audit_class.count} }
      end
      context 'for incomplete upload with fingerprint_value' do
        before { expect(incomplete_upload_with_fingerprint_value).to be_persisted }
        it { invoke_task(expected_stdout: /Creating fingerprints for 0 uploads/) }
        it { expect {invoke_task}.to change{Fingerprint.count}.by(0) }
        it { expect {invoke_task}.to change{Audited.audit_class.count}.by(0) }
      end
      context 'for upload with fingerprint_value' do
        before { expect(upload_with_fingerprint_value).to be_persisted }
        it { expect {invoke_task}.to change{Fingerprint.count}.by(1) }
        it { expect {invoke_task}.to change{Audited.audit_class.count}.by(1) }
      end
      context 'for upload with capitalized algorithm' do
        before { expect(upload_with_capitalized_algorithm).to be_persisted }
        it { expect {invoke_task}.to change{Fingerprint.count}.by(1) }
        it { expect {invoke_task}.to change{Audited.audit_class.count}.by(1) }
      end
      context 'for upload with invalid fingerprint_algorithm' do
        before { expect(upload_with_invalid_fingerprint_algorithm).to be_persisted }
        it { expect {invoke_task}.to change{Fingerprint.count}.by(0) }
        it { expect {invoke_task}.to change{Audited.audit_class.count}.by(0) }
      end
      context 'for upload with associated fingerprint' do
        before { expect(fingerprint_upload).to be_persisted }
        it { expect {invoke_task}.not_to change{Fingerprint.count} }
        it { expect {invoke_task}.not_to change{Audited.audit_class.count} }
      end
      context 'for upload with associated fingerprint and fingerprint_value' do
        let(:fingerprint) { FactoryGirl.create(:fingerprint, upload: upload_with_fingerprint_value) }
        before { expect(fingerprint).to be_persisted }
        it { expect {invoke_task}.not_to change{Fingerprint.count} }
        it { expect {invoke_task}.not_to change{Audited.audit_class.count} }
      end
    end

    context 'without any untyped authentication services' do
      let(:duke_authentication_service) { FactoryGirl.create(:duke_authentication_service) }
      let(:openid_authentication_service) { FactoryGirl.create(:openid_authentication_service) }

      it {
        expect {
          invoke_task expected_stderr: /0 untyped authentication_services changed/
        }.not_to change{
          AuthenticationService.where(type: nil).count
        }
      }
    end

    context 'with untyped authentication services' do
      let(:default_type) { DukeAuthenticationService }
      let(:untyped_authentication_service) {
        AuthenticationService.create(FactoryGirl.attributes_for(:duke_authentication_service))
      }
      let(:openid_authentication_service) { FactoryGirl.create(:openid_authentication_service) }

      it {
        expect(untyped_authentication_service).not_to be_a default_type
        expect {
          invoke_task expected_stderr: Regexp.new("1 untyped authentication_services changed to #{default_type}")
        }.to change{
          AuthenticationService.where(type: nil).count
        }.by(-1)
        expected_to_be_typed_auth_service = AuthenticationService.find(untyped_authentication_service.id)
        expect(expected_to_be_typed_auth_service).to be_a default_type
        openid_authentication_service.reload
        expect(openid_authentication_service).to be_a OpenidAuthenticationService
      }
    end

    shared_examples 'a consistency migration' do |prep_method_sym|
      let(:record_class) { record.class }
      before do
        expect(record).to be_persisted
      end
      context 'record is consistent' do
        let(:prep_method) { send(prep_method_sym) }
        before do
          expect { prep_method }.not_to raise_error
        end
        it 'should update is_consistent to true' do
          expect(record_class.where(is_consistent: nil)).to exist
          invoke_task
          expect(record_class.where(is_consistent: nil)).not_to exist
          record.reload
          expect(record.is_consistent).to eq true
        end
      end

      context 'record is not consistent' do
        it 'should update is_consistent to false' do
          expect(record_class.where(is_consistent: nil)).to exist
          invoke_task
          expect(record_class.where(is_consistent: nil)).not_to exist
          record.reload
          expect(record.is_consistent).to eq false
        end
      end
    end

    describe 'consistency migration', :vcr do
      let(:storage_provider) { FactoryGirl.create(:storage_provider, :swift) }

      before do
        expect(storage_provider).to be_persisted
      end

      context 'for project' do
        let(:record) { FactoryGirl.create(:project, is_consistent: nil) }
        let(:init_project_storage) {
          storage_provider.put_container(record.id)
          expect(storage_provider.get_container_meta(record.id)).not_to be_nil
        }
        it_behaves_like 'a consistency migration', :init_project_storage

        context 'with deleted project' do
          before(:each) { FactoryGirl.create(:project, :deleted, is_consistent: nil) }
          it { expect {invoke_task}.not_to change{Project.where(is_consistent: nil).count} }
        end
      end

      context 'for upload' do
        let(:record) { FactoryGirl.create(:upload, is_consistent: nil, storage_provider: storage_provider) }
        let(:init_upload) {
          storage_provider.put_container(record.project.id)
          expect(storage_provider.get_container_meta(record.project.id)).not_to be_nil
          record.create_and_validate_storage_manifest
          record.update_columns(is_consistent: nil)
          expect(storage_provider.get_object_metadata(record.project.id, record.id)).not_to be_nil
        }
        it_behaves_like 'a consistency migration', :init_upload
      end
    end
  end
end
