require "log4r"

module VagrantPlugins
  module Kubevirt
    module Action
      # This action reads the state of the machine and puts it in the
      # `:machine_state_id` key in the environment.
      class ReadState
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_kubevirt::action::read_state")
        end

        def call(env)
          env[:machine_state_id] = read_state(env[:kubevirt_compute], env[:machine])
          @app.call(env)
        end

        def read_state(kubevirt, machine)
          return :not_created if machine.id.nil?

          # Find the machine
          vm = kubevirt.vms.get(machine.id)
          if vm.nil?
            # The machine can't be found
            @logger.info(I18n.t("vagrant_kubevirt.vm_not_found"))
            machine.id = nil
            return :not_created
          end

          # Return the state
          return vm.status
        end
      end
    end
  end
end