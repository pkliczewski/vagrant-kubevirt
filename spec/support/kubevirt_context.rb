require 'fog/kubevirt'

shared_context 'kubevirt' do
  include_context 'unit'

  let(:kubevirt_context) { true }
  let(:id)               { 'dummy-vagrant_dummy' }

  before (:each) do
    stub_const('Fog::Kubevirt::Compute', compute)
    allow(compute).to receive(:new).with(hash_including(:kubevirt_hostname, :kubevirt_port, :kubevirt_token, :kubevirt_namespace, :kubevirt_log)).and_return(compute)

    allow(machine).to receive(:id).and_return(id)
  end
end