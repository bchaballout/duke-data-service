require 'rails_helper'

RSpec.describe UploadCompletionJob, type: :job do
  let(:upload) { FactoryGirl.create(:upload, :inconsistent) }
  let(:job_transaction) { described_class.initialize_job(upload) }
  let(:prefix) { Rails.application.config.active_job.queue_name_prefix }
  let(:prefix_delimiter) { Rails.application.config.active_job.queue_name_delimiter }

  before do
    expect(upload).to be_persisted
  end

  it { is_expected.to be_an ApplicationJob }
  it { expect(prefix).not_to be_nil }
  it { expect(prefix_delimiter).not_to be_nil }
  it { expect(described_class.queue_name).to eq("#{prefix}#{prefix_delimiter}upload_completion") }
  it {
    expect {
      described_class.perform_now
    }.to raise_error(ArgumentError)
    expect {
      described_class.perform_now(job_transaction)
    }.to raise_error(ArgumentError)
  }

  context 'perform_now' do
    include_context 'tracking job', :job_transaction
    it 'should complete the upload' do
      expect(Upload).to receive(:find).with(upload.id).and_return(upload)
      expect(upload).to receive(:create_and_validate_storage_manifest).and_return(true)
      described_class.perform_now(job_transaction, upload.id)
    end
  end
end
