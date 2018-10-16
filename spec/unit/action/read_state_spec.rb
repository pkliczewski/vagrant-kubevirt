require 'support/sharedcontext'
require 'support/kubevirt_context'

require 'vagrant-kubevirt/action/read_state'

describe VagrantPlugins::Kubevirt::Action::ReadState do
  subject { described_class.new(app, env) }

  include_context 'unit'
  include_context 'kubevirt'

  let(:vms) { double('vms') }
  let(:vm) { double('vm') }

  describe '#call' do
    before do
      allow(compute).to receive(:vms).and_return(vms)
    end

    it 'checks when no vm' do
      allow(env[:machine]).to receive(:id).and_return(nil)
      expect(subject.call(env)).to be_nil

      expect(env[:machine_state_id]).to eq(:not_created)
    end

    it 'checks when a vm in running state' do
      allow(vms).to receive(:get).and_return(vm)
      allow(vm).to receive(:status).and_return(:running)

      expect(subject.call(env)).to be_nil

      expect(env[:machine_state_id]).to eq(:running)
    end

    it 'checks when a vm not found' do
      allow(vms).to receive(:get).and_raise(Fog::Kubevirt::Errors::ClientError, "404")

      expect(subject.call(env)).to be_nil

      expect(env[:machine_state_id]).to eq(:not_created)
    end
  end
end