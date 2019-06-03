require "log4r"
require 'json'

require 'vagrant/util/retryable'

module VagrantPlugins
  module Kubevirt
    module Action
      # This creates the virtual machine.
      class CreateVM
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_kubevirt::action::create_vm")
        end

        def call(env)
          # Get config.
          config = env[:machine].provider_config
          ssh_info = env[:machine].config.ssh

          vm_name = env[:domain_name]
          namespace = config.namespace
          cpus = config.cpus
          memory_size = config.memory
          image = config.image
          pvc = config.pvc
          port_node = config.port_node
 
          template = config.template

          # Output the settings we're going to use to the user
          env[:ui].info(I18n.t("vagrant_kubevirt.creating_vm"))
          env[:ui].info(" -- Name:          #{vm_name}")
          env[:ui].info(" -- Namespace:     #{namespace}")
          env[:ui].info(" -- Cpus:          #{cpus}")
          env[:ui].info(" -- Memory:        #{memory_size}M")

          kubevirt = env[:kubevirt_compute]

          if template == nil
            volumes = []
            if !image.nil?
              volume = Fog::Kubevirt::Compute::Volume.new
              volume.type = 'containerDisk'
              volume.info = image
              volumes << volume
            end
            if !pvc.nil?
              volume = Fog::Kubevirt::Compute::Volume.new
              volume.type = 'persistentVolumeClaim'
              volume.info = pvc
              volumes << volume
            end
            provision_vm(kubevirt, vm_name, cpus, memory_size, volumes, ssh_info)
          else
            env[:ui].info(" -- Template:      #{template}")
            provision_from_template(kubevirt, template, vm_name, cpus, memory_size)
          end

          create_service(kubevirt, vm_name, port_node)

          vm = kubevirt.vms.get(vm_name)
          env[:machine].id = vm.name

          # Terminate the instance if we were interrupted
          terminate(env) if env[:interrupted]

          @app.call(env)
        end

        def recover(env)
          return if env["vagrant.error"].is_a?(Vagrant::Errors::VagrantError)

          if env[:machine].provider.state.id != :not_created
            env[:ui].info(I18n.t("vagrant_kubevirt.error_recovering"))
            terminate(env)
          end
        end

        private

        def provision_from_template(kubevirt, template, vm_name, cpus, memory_size)
          begin
            temp = kubevirt.templates.get(template)
            temp.clone(name: vm_name, memory: memory_size, cpu_cores: cpus)
          rescue Fog::Errors::Error => e
            raise Errors::FogError, :message => e.message
          end
        end

        def provision_vm(kubevirt, vm_name, cpus, memory_size, volumes, ssh_info)
          begin
            init = {}
            userData = ""

            unless ssh_info.username.nil?
              userData.concat("user: #{ssh_info.username}\n")
            end
            unless  ssh_info.password.nil?
              userData.concat("password: #{ssh_info.password}\n")
            end

            unless userData.empty?
              init = {:userData => "#cloud-config\n#{userData}chpasswd: { expire: False }"}
            end

            kubevirt.vms.create(vm_name: vm_name, cpus: cpus, memory_size: memory_size, volumes: volumes, cloudinit: init)
          rescue Fog::Errors::Error => e
            raise Errors::FogError, :message => e.message
          end
        end

        def create_service(kubevirt, vm_name, port_node)
          begin
            kubevirt.services.create(port: port_node, name: "#{vm_name}-ssh", target_port: 22, vmi_name: vm_name, service_type: "NodePort")
          rescue Fog::Errors::Error => e
            raise Errors::FogError, :message => e.message
          end
        end

        def terminate(env)
          destroy_env = env.dup
          destroy_env.delete(:interrupted)
          destroy_env[:config_validate] = false
          destroy_env[:force_confirm_destroy] = true
          env[:action_runner].run(Action.action_destroy, destroy_env)
        end
      end
    end
  end
end
