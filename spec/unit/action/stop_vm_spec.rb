require 'fog/kubevirt'

require 'spec_helper'
require 'support/sharedcontext'
require 'support/kubevirt_context'

require 'vagrant-kubevirt/errors'
require 'vagrant-kubevirt/action/stop_vm'

describe VagrantPlugins::Kubevirt::Action::StopVM do
  subject { described_class.new(app, env) }

  include_context 'unit'
  include_context 'kubevirt'

  let(:vms) { double('vms') }
  let(:vm) { double('vm') }

  describe '#call' do
    before do
      allow(compute).to receive(:vms).and_return(vms)
    end

    it 'stops a vm' do
      allow(vms).to receive(:get).and_return(vm)
      allow(vm).to receive(:status).and_return(:running)
      expect(vm).to receive(:stop)
      expect(ui).to receive(:info).with('Stopping the VM...')

      expect(subject.call(env)).to be_nil
    end

    it 'fails to find a vm' do
      allow(vms).to receive(:get).and_return(nil)

      expect { subject.call(env) }.to raise_error(::VagrantPlugins::Kubevirt::Errors::NoVMError)
    end

    it 'finds already stopped vm' do
      allow(vms).to receive(:get).and_return(vm)
      allow(vm).to receive(:status).and_return(:stopped)
      expect(vm).not_to receive(:stop)
      expect(ui).to receive(:info).with('The VM is already not_created.')

      expect(subject.call(env)).to be_nil
    end

    it 'fails to start a vm' do
      allow(vms).to receive(:get).and_return(vm)
      allow(vm).to receive(:status).and_return(:running)
      expect(vm).to receive(:stop).and_raise(::Fog::Errors::Error)
      expect(ui).to receive(:info).with('Stopping the VM...')

      expect { subject.call(env) }.to raise_error(::VagrantPlugins::Kubevirt::Errors::StopVMError)
    end
  end
end