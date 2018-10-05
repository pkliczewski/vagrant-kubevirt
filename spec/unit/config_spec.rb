require 'spec_helper'
require 'support/sharedcontext'

require 'vagrant-kubevirt/config'

describe VagrantPlugins::Kubevirt::Config do
  include_context 'unit'

  def assert_invalid
    errors = subject.validate(machine)
    raise "No errors: #{errors.inspect}" if errors.values.all?(&:empty?)
  end

  def assert_valid
    errors = subject.validate(machine)
    raise "Errors: #{errors.inspect}" unless errors.values.all?(&:empty?)
  end

  describe '#validate' do
    it 'is valid with defaults' do
      assert_valid
    end

    context 'with missing params' do
      let(:vm) { double('vm') }
      let(:config) { double('config')}

      before do
        allow(subject).to receive(:template).and_return(nil)
        allow(subject).to receive(:image).and_return(nil)
        allow(subject).to receive(:pvc).and_return(nil)

	    expect(machine).to receive(:provider_config).and_return(subject).at_least(:once) 
	  end

      it 'is missing image info' do
      	assert_invalid
      end
	end
  end
end