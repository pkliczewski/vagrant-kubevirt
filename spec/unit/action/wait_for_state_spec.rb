require "timeout"

require 'spec_helper'
require 'support/sharedcontext'
require 'support/kubevirt_context'

require 'vagrant-kubevirt/errors'
require 'vagrant-kubevirt/action/wait_for_state'

describe VagrantPlugins::Kubevirt::Action::WaitForState do
  subject { described_class.new(app, env, :running, 0.2) }

  include_context 'unit'
  include_context 'kubevirt'

  let(:vms) { double('vms') }
  let(:vm) { double('vm') }
  let(:watch) { double('watch') }
  let(:notice) { double('notice') }

  describe '#call' do
    before do
      allow(compute).to receive(:watch_vms).and_return(watch)
      allow(compute).to receive(:vms).and_return(vms)
      allow(vms).to receive(:get).and_return(vm)
    end

    it 'checks already running vm' do
      allow(vm).to receive(:status).and_return(:running)
      expect(ui).to receive(:info).with('The VM is already running.')
      expect(watch).to receive(:finish)

      expect(subject.call(env)).to be_nil
    end

    it 'timeouts when waiting on running state' do
      allow(vm).to receive(:status).and_return(:stopped)
      expect(ui).to receive(:info).with('Waiting for VM to reach state running')
      expect(Timeout).to receive(:timeout).and_raise(Timeout::Error)

      expect { subject.call(env) }.to raise_error(::VagrantPlugins::Kubevirt::Errors::VMReadyTimeout)
    end

    it 'waits on vm to start' do
      allow(vm).to receive(:status).and_return(:stopped)
      expect(ui).to receive(:info).with('Waiting for VM to reach state running')

      allow(notice).to receive(:kind).and_return('VirtualMachine')
      allow(notice).to receive(:name).and_return('test')
      allow(notice).to receive(:status).and_return('running')

      allow(watch).to receive(:each).and_return(notice)

      expect(watch).to receive(:finish)
      expect(subject.call(env)).to be_nil
    end
  end
end