require 'support/sharedcontext'
require 'support/kubevirt_context'

require 'vagrant-kubevirt/action/read_ssh_info'

describe VagrantPlugins::Kubevirt::Action::ReadSSHInfo do
  subject { described_class.new(app, env) }

  include_context 'unit'
  include_context 'kubevirt'

  let(:services) { double('services') }
  let(:service) { double('service') }
  let(:vminstances) { double('vminstances') }
  let(:vmi) { double('vmi') }

  describe '#call' do
    before do
      allow(compute).to receive(:vminstances).and_return(vminstances)
      allow(compute).to receive(:services).and_return(services)
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
      allow(vmi).to receive(:node_name).and_return('127.0.0.1')
      allow(services).to receive(:get).and_return(service)
      allow(service).to receive(:node_port).and_return(30000)

      expect(subject.call(env)).to be_nil
      expect(env[:machine_ssh_info]).to eq({:host => '127.0.0.1', :port => 30000 })
    end
  end
end