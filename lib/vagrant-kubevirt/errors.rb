require "vagrant"

module VagrantPlugins
  module Kubevirt
    module Errors
      class VagrantKubevirtError < Vagrant::Errors::VagrantError
        error_namespace("vagrant_kubevirt.errors")
      end
    end
  end
end