require "vagrant"

module VagrantPlugins
  module Kubevirt
    module Errors
      class VagrantKubevirtError < Vagrant::Errors::VagrantError
        error_namespace("vagrant_kubevirt.errors")
      end

      class FogError < VagrantKubevirtError
        error_key(:fog_error)
      end

      class NoVMError < VagrantKubevirtError
        error_key(:no_vm_error)
      end

      class StartVMError < VagrantKubevirtError
        error_key(:start_vm_error)
      end

      class StopVMError < VagrantKubevirtError
        error_key(:stop_vm_error)
      end

      class VMReadyTimeout < VagrantKubevirtError
        error_key(:vm_ready_timeout)
      end

      class NoNodeError < VagrantKubevirtError
        error_key(:no_node_error)
      end

      class NoServiceError < VagrantKubevirtError
        error_key(:no_service_error)
      end
    end
  end
end