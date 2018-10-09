require 'support/sharedcontext'
require 'support/kubevirt_context'

require 'vagrant-kubevirt/action/create_vm'

describe VagrantPlugins::Kubevirt::Action::CreateVM do
  subject { described_class.new(app, env) }

  include_context 'unit'
  include_context 'kubevirt'

  let(:vms) { double('vms') }
  let(:vm) { double('vm') }

  describe '#call' do
    before do
      allow(compute).to receive(:vms).and_return(vms)
      allow(vms).to receive(:get).and_return(vm)
      allow(vm).to receive(:name).and_return('Test')

      expect(ui).to receive(:info).with('Creating VM with the following settings...')
      expect(ui).to receive(:info).with(' -- Name:          Test')
      expect(ui).to receive(:info).with(' -- Namespace:     default')
      expect(ui).to receive(:info).with(' -- Cpus:          1')
      expect(ui).to receive(:info).with(' -- Memory:        512M')
    end

    context 'when template defined' do
      let(:templates) { double('templates') }
      let(:template) { double('template') }

      before do
        allow(compute).to receive(:templates).and_return(templates)
        allow(templates).to receive(:get).and_return(template)

        expect(template).to receive(:clone)
        expect(ui).to receive(:info).with(' -- Template:      working')
      end

      it 'clones a template' do
        expect(subject.call(env)).to be_nil
      end

      it 'recovers after interruption' do
        env[:interrupted] = true
        expect(runner).to receive(:run)

        expect(subject.call(env)).to be_nil
      end
    end

    context 'when image defined' do
      let(:vagrantfile) do
        <<-EOF
        Vagrant.configure('2') do |config|
          config.vm.box = 'kubevirt'
          config.vm.define :test

          config.vm.provider :kubevirt do |kubevirt|
            kubevirt.token = 'abc'
            kubevirt.image = 'kubevirt/fedora'
          end
        end
        EOF
      end

      it 'creates a vm using image' do
        expect(vms).to receive(:create).with(hash_including(:vm_name => "Test", :cpus => 1, :memory_size => 512, :image => 'kubevirt/fedora', :pvc => nil))

        expect(subject.call(env)).to be_nil
      end
    end

    context 'when pvc defined' do
      let(:vagrantfile) do
        <<-EOF
        Vagrant.configure('2') do |config|
          config.vm.box = 'kubevirt'
          config.vm.define :test

          config.vm.provider :kubevirt do |kubevirt|
            kubevirt.token = 'abc'
            kubevirt.pvc = 'my_disk'
          end
        end
        EOF
      end

      it 'creates a vm using pvc' do
        expect(vms).to receive(:create).with(hash_including(:vm_name => "Test", :cpus => 1, :memory_size => 512, :image => nil, :pvc => "my_disk"))

        expect(subject.call(env)).to be_nil
      end
    end
  end
end