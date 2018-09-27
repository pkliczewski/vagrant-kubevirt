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

      class DomainNameExists < VagrantKubevirtError
      	error_key(:vm_exists)
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
    end
  end
end