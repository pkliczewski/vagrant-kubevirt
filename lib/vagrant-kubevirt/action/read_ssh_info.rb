require "log4r"

module VagrantPlugins
  module Kubevirt
    module Action
      # This action reads the SSH info for the machine and puts it into the
      # `:machine_ssh_info` key in the environment.
      class ReadSSHInfo
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_kubevirt::action::read_ssh_info")
        end

        def call(env)
          env[:machine_ssh_info] = read_ssh_info(env[:kubevirt_compute], env[:machine])

          @app.call(env)
        end

        def read_ssh_info(kubevirt, machine)
          return nil if machine.id.nil?

          # Find the machine
          vmi = kubevirt.vminstances.get(machine.id)
          if vmi.nil?
            # The machine can't be found
            @logger.info(I18n.t("vagrant_kubevirt.vm_not_found"))
            machine.id = nil
            return nil
          end

          return { :host => vmi.ip_address, :port => 22 }
        end
      end
    end
  end
end