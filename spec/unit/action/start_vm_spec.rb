require 'support/sharedcontext'
require 'support/kubevirt_context'

require 'vagrant-kubevirt/errors'
require 'vagrant-kubevirt/action/start_vm'

describe VagrantPlugins::Kubevirt::Action::StartVM do
  subject { described_class.new(app, env) }

  include_context 'unit'
  include_context 'kubevirt'

  let(:vms) { double('vms') }
  let(:vm) { double('vm') }

  describe '#call' do
    before do
      allow(compute).to receive(:vms).and_return(vms)

      # always see this at the start of #call
      expect(ui).to receive(:info).with('Starting the VM...')
    end

    it 'starts a vm' do
      allow(vms).to receive(:get).and_return(vm)
      expect(vm).to receive(:start)

      expect(subject.call(env)).to be_nil
    end

    it 'fails to find a vm' do
      allow(vms).to receive(:get).and_return(nil)

      expect { subject.call(env) }.to raise_error(::VagrantPlugins::Kubevirt::Errors::NoVMError)
    end

    it 'fails to start a vm' do
      allow(vms).to receive(:get).and_return(vm)
      expect(vm).to receive(:start).and_raise(::Fog::Errors::Error)

      expect { subject.call(env) }.to raise_error(::VagrantPlugins::Kubevirt::Errors::StartVMError)
    end
  end
end