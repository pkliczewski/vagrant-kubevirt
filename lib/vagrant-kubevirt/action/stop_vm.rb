
require "log4r"

module VagrantPlugins
  module Kubevirt
    module Action
      # This stops the running instance.
      class StopVM
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_kubevirt::action::stop_vm")
        end

        def call(env)
          begin
            vm = kubevirt.vms.get(env[:machine].id.to_s)
            if vm == nil
              raise Errors::NoVMError,
                :vm_name => env[:domain_name]
            end

            if vm.status == :stopped
              env[:ui].info(I18n.t("vagrant_kubevirt.already_status", :status => env[:machine].state.id))
            else
              env[:ui].info(I18n.t("vagrant_kubevirt.stopping"))
              vm.stop
            end
          rescue Fog::Errors::Error => e
            raise Errors::StopVMError,
              :error_message => e.message
          end

          @app.call(env)
        end
      end
    end
  end
end