require 'spec_helper'

shared_context 'unit' do
  include_context 'vagrant-unit'

  let(:vagrantfile) do
    <<-EOF
    Vagrant.configure('2') do |config|
      config.vm.box = 'kubevirt'
      config.vm.define :test

      config.vm.provider :kubevirt do |kubevirt|
        kubevirt.token = 'abc'
        kubevirt.template = 'working'
      end
    end
    EOF
  end
  let(:test_env) do
    test_env = isolated_environment
    test_env.vagrantfile vagrantfile
    test_env
  end
  let(:env)              { { env: iso_env, machine: machine, ui: ui, root_path: '/rootpath',  kubevirt_compute: compute} }
  let(:conf)             { Vagrant::Config::V2::DummyConfig.new }
  let(:ui)               { Vagrant::UI::Basic.new }
  let(:iso_env)          { test_env.create_vagrant_env ui_class: Vagrant::UI::Basic }
  let(:machine)          { iso_env.machine(:test, :kubevirt) }
  let(:app)              { ->(env) {} }
  let(:plugin)           { register_plugin }
  let(:compute)          { double('compute') }
end