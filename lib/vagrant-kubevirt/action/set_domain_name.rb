module VagrantPlugins
  module Kubevirt
    module Action

      # Setup name for domain.
      class SetDomainName
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:domain_name] = env[:root_path].basename.to_s.dup
          env[:domain_name].gsub!(/([_.])/, '-')

          # Check if the domain name is not already taken
          kubevirt = env[:kubevirt_compute]
          begin
            domain = kubevirt.vms.get(env[:domain_name])

            unless domain.nil?
              raise Errors::DomainNameExists, :domain_name => env[:domain_name]
            end
          rescue Fog::Kubevirt::Errors::ClientError => e
            msg = e.message

            unless msg.include? '404'
              raise Errors::FogError, :message => msg
            end
          end

          @app.call(env)
        end
      end

    end
  end
end