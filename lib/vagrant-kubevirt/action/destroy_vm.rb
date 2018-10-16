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
          kubevirt = env[:kubevirt_compute]

          vm = kubevirt.vminstances.get(env[:machine].id.to_s)
          if vm != nil
            config = env[:machine].provider_config
            kubevirt.vminstances.destroy(vm.name, config.namespace)
            kubevirt.services.delete("#{vm.name}-ssh")
          end
          env[:machine].id = nil

          @app.call(env)
        end
      end
    end
  end
end