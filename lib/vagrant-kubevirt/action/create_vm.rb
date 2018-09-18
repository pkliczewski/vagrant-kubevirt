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
          vm_name = env[:domain_name]
          namespace = config.namespace
          cpus = config.cpus
          memory_size = config.memory
          image = config.image
          pvc = config.pvc

          template = config.template

          # Output the settings we're going to use to the user
          env[:ui].info(I18n.t("vagrant_ovirt.creating_vm"))
          env[:ui].info(" -- Name:          #{vm_name}")
          env[:ui].info(" -- Namespace:     #{namespace}")
          env[:ui].info(" -- Cpus:          #{cpus}")
          env[:ui].info(" -- Memory:        #{memory_size}M")

          kubevirt = env[:kubevirt_compute]

          if template == nil
          	provision_vm(kubevirt, vm_name, cpus, memory_size, image, pvc)
          else
          	env[:ui].info(" -- Template:      #{template}")
          	provision_from_template(kubevirt, template, vm_name, cpus, memory_size)
          end

          vm = kubevirt.vms.get(vm_name)
          env[:machine].id = vm.uid

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

        def provision_vm(kubevirt, vm_name, cpus, memory_size, image, pvc)
        	# TODO missing implementation in fog-kubevirt
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
