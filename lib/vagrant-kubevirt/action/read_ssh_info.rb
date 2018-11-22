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

          vmi_name = machine.id

          # Find the machine
          vmi = kubevirt.vminstances.get(vmi_name)
          if vmi.nil?
            # The machine can't be found
            @logger.info(I18n.t("vagrant_kubevirt.vm_not_found"))
            machine.id = nil
            return nil
          end

          node_name = vmi.node_name
          if node_name.nil?
            @logger.info(I18n.t("vagrant_kubevirt.not_running"))
            return nil
          end
  
          service = kubevirt.services.get("#{vmi_name}-ssh")
          if service.nil?
            raise Errors::NoServiceError, :name => vmi_name
          end

          info = { :host => vmi.node_name, :port => service.node_port }
          key_path = machine.config.ssh.private_key_path
          info[:private_key_path] = key_path unless key_path.nil? || key_path.empty?

          return info
        end
      end
    end
  end
end