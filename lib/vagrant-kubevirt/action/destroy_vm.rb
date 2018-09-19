require 'log4r'

module VagrantPlugins
  module Kubevirt
    module Action
      class DestroyVM
        def initialize(app, env)
          @logger = Log4r::Logger.new("vagrant_kubevirt::action::destroy_vm")
          @app = app
        end

        def call(env)
          # Destroy the server, remove the tracking ID
          env[:ui].info(I18n.t("vagrant_kubevirt.destroy_vm"))

          vm = env[:kubevirt_compute].vms.get(env[:machine].id.to_s)
          if vm != nil
            env[:kubevirt_compute].delete_vm_instance(vm.name)
          end
          env[:machine].id = nil

          @app.call(env)
        end
      end
    end
  end
end