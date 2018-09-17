require "vagrant"
require "iniparse"

module VagrantPlugins
  module Kubevirt
    class Config < Vagrant.plugin("2", :config)

      attr_accessor :token
      attr_accessor :hostname
      attr_accessor :port
      attr_accessor :namespace

      def initialize
      	@token     = UNSET_VALUE
        @hostname  = UNSET_VALUE
        @port      = UNSET_VALUE
        @namespace = UNSET_VALUE
      end

      def merge(other)
        super.tap do |result|
          # TODO check whether it is needed
        end
      end

      def finalize!
      	@token = nil if @token == UNSET_VALUE
      	@hostname = 'localhost' if @hostname == UNSET_VALUE
      	@port = '8443' if @port == UNSET_VALUE
      	@namespace = 'default' if @namespace == UNSET_VALUE
      end

      def validate(machine)
      	# TODO
      end
    end
  end
end