require "vagrant"
require "iniparse"

module VagrantPlugins
  module Kubevirt
    class Config < Vagrant.plugin("2", :config)

      attr_accessor :token
      attr_accessor :hostname
      attr_accessor :port
      attr_accessor :namespace

      # Domain specific settings used while creating new machine.
      attr_accessor :memory
      attr_accessor :cpus
      attr_accessor :template
      attr_accessor :image
      attr_accessor :pvc
      attr_accessor :port_node

      def initialize
      	@token     = UNSET_VALUE
        @hostname  = UNSET_VALUE
        @port      = UNSET_VALUE
        @namespace = UNSET_VALUE

        @memory    = UNSET_VALUE
        @cpus      = UNSET_VALUE
        @template  = UNSET_VALUE
        @image     = UNSET_VALUE
        @pvc       = UNSET_VALUE
        @port_node = UNSET_VALUE
      end

      def finalize!
      	@token = nil if @token == UNSET_VALUE
      	@hostname = 'localhost' if @hostname == UNSET_VALUE
      	@port = '8443' if @port == UNSET_VALUE
      	@namespace = 'default' if @namespace == UNSET_VALUE

        @memory = 512 if @memory == UNSET_VALUE
        @cpus = 1 if @cpus == UNSET_VALUE
        @template = nil if @template == UNSET_VALUE
        @image = nil if @image == UNSET_VALUE
        @pvc = nil if @pvc == UNSET_VALUE
        @port_node = 30000 if @port_node == UNSET_VALUE
      end

      def validate(machine)
        errors = _detected_errors

        config = machine.provider_config

        errors << I18n.t("vagrant_kubevirt.config.image_info_required") if config.template.nil?  and config.image.nil? and config.pvc.nil?

        { 'Kubevirt Provider' => errors }
      end
    end
  end
end