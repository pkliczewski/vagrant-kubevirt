require "fog"
require 'fog/kubevirt'

require "log4r"

module VagrantPlugins
  module Kubevirt
    module Action
      class ConnectKubevirt

      	def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_kubevirt::action::connect_kubevirt")
        end


        def call(env)
          # Get config options for kubevirt provider.
          config = env[:machine].provider_config

          # Build the fog config
          fog_config = {
            :provider           => 'kubevirt',
            :kubevirt_hostname  => config.hostname,
            :kubevirt_port      => config.port,
            :kubevirt_token     => config.token,
            :kubevirt_namespace => config.namespace,
            :kubevirt_log       => @logger
          }

          @logger.info("Connecting to Kubevirt...")
          env[:kubevirt_compute] = Fog::Compute.new(fog_config)

          @app.call(env)
        end
      end
    end
  end
end