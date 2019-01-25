require "log4r"
require "timeout"

module VagrantPlugins
  module Kubevirt
    module Action
      # This action will wait for a machine to reach a specific state or quit by timeout
      class WaitForState
        # env[:result] will be false in case of timeout.
        # @param [Symbol] state Target machine state.
        # @param [Number] timeout Timeout in seconds.
        def initialize(app, env, state, timeout)
          @app     = app
          @logger  = Log4r::Logger.new("vagrant_kubevirt::action::wait_for_state")
          @state   = state
          @timeout = timeout
        end


        def call(env)
          env[:result] = true
          vm_name = env[:domain_name]
          kubevirt = env[:kubevirt_compute]


          if @state.to_s == 'running'
            watch = kubevirt.watch_vminstances
            kind = 'VirtualMachineInstance'
            env[:ui].info(I18n.t("vagrant_kubevirt.wait_for_boot"))
          else
            watch = kubevirt.watch_vms
            kind = 'VirtualMachine'
            env[:ui].info(I18n.t("vagrant_kubevirt.wait_for_state", :state => @state))
          end

          vm = kubevirt.vms.get(vm_name)

          if vm.status == @state
            env[:ui].info(I18n.t("vagrant_kubevirt.already_status", :status => @state))
          else
            begin
              Timeout.timeout(@timeout) do
                watch.each do |notice|
                  break if notice.kind == kind && notice.name == vm_name && !notice.status.nil? && notice.status.downcase == @state.to_s
                end
              end
            rescue Timeout::Error
              raise Errors::VMReadyTimeout, timeout: @timeout
            end
          end
          watch.finish

          if @state.to_s == 'running'
            wait = env[:machine].config.vm.boot_timeout || 0
            10.times do
              machine.communicate.wait_for_ready(wait)
              break if machine.communicate.ready?
            end
          end

          @app.call(env)
        end
      end
    end
  end
end