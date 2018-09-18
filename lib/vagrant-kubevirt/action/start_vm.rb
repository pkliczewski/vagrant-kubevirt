
require 'log4r'

module VagrantPlugins
  module Kubevirt
    module Action

      # Just start the VM.
      class StartVM
      	def initialize(app, env)
          @logger = Log4r::Logger.new("vagrant_kubevirt::action::start_vm")
          @app = app
        end

        def call(env)
          env[:ui].info(I18n.t("vagrant_kubevirt.starting_vm"))

          vm_id = env[:kubevirt_compute].servers.get(env[:machine].id.to_s)
          if vm_id == nil
            raise Errors::NoVMError,
              :vm_name => env[:domain_name]
          end

          kubevirt = env[:kubevirt_compute]
          # Start VM.
          begin
            vm = kubevirt.vms.get(env[:domain_name])
            vm.start
          rescue Fog::Errors::Error => e
            raise Errors::StartVMError,
              :error_message => e.message
          end

          @app.call(env)
        end
      end
    end
  end
end