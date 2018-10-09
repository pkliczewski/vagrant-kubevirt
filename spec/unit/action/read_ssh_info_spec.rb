require 'support/sharedcontext'
require 'support/kubevirt_context'

require 'vagrant-kubevirt/action/read_ssh_info'

describe VagrantPlugins::Kubevirt::Action::ReadSSHInfo do
  subject { described_class.new(app, env) }

  include_context 'unit'
  include_context 'kubevirt'

  let(:vminstances) { double('vminstances') }
  let(:vmi) { double('vmi') }

  describe '#call' do
    before do
      allow(compute).to receive(:vminstances).and_return(vminstances)
    end

    it 'checks when no id' do
      allow(env[:machine]).to receive(:id).and_return(nil)

      expect(subject.call(env)).to be_nil
    end

    it 'checks when no running vm' do
      allow(vminstances).to receive(:get).and_return(nil)

      expect(subject.call(env)).to be_nil
    end

    it 'checks when a running vm' do
      allow(vminstances).to receive(:get).and_return(vmi)
      allow(vmi).to receive(:ip_address).and_return('127.0.0.1')

      expect(subject.call(env)).to be_nil
      expect(env[:machine_ssh_info]).to eq({:host => '127.0.0.1', :port => 22 })
    end
  end
end