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
    end
  end
end