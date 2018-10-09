require 'support/sharedcontext'
require 'support/kubevirt_context'

require 'vagrant-kubevirt/action/destroy_vm'

describe VagrantPlugins::Kubevirt::Action::DestroyVM do
  subject { described_class.new(app, env) }

  include_context 'unit'
  include_context 'kubevirt'

  let(:vminstances) { double('vminstances') }
  let(:vmi) { double('vmi') }

  describe '#call' do
    before do
      allow(compute).to receive(:vminstances).and_return(vminstances)
      allow(vminstances).to receive(:get).and_return(vmi)
      allow(vmi).to receive(:name).and_return('test')

      # always see this at the start of #call
      expect(ui).to receive(:info).with('Removing the VM...')
    end

    it 'destroys a vmi' do
      expect(vminstances).to receive(:destroy).with('test', 'default')
      expect(subject.call(env)).to be_nil
    end
  end
end