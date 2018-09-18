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
          env[:domain_name].gsub!(/[^-a-z0-9_]/i, "")
          env[:domain_name] << "_#{Time.now.to_i}"

          # Check if the domain name is not already taken
          kubevirt = env[:kubevirt_compute]
          domain = kubevirt.vms.get(env[:domain_name])
          if domain != nil
            raise Vagrant::Errors::DomainNameExists,
              :domain_name => env[:domain_name]
          end

          @app.call(env)
        end
      end

    end
  end
end