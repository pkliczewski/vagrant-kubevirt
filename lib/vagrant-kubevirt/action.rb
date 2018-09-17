require "pathname"

require "vagrant/action/builder"

module VagrantPlugins
  module Kubevirt
    module Action
      # Include the built-in modules so we can use them as top-level things.
      include Vagrant::Action::Builtin

      # This action is called to bring the box up from nothing.
      def self.action_up
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectKubevirt
          b.use Call, IsCreated do |env1, b1|
            if env[:result]
              b2.use MessageAlreadyCreated
              next
            end

            b2.use CreateVM
            b2.use StartVM
            b2.use Call, WaitForState, :running, 120 do |env2, b3|
              if !env2[:result]
                # TODO message stop failed
              end
            end
          end
        end
      end

      # This action is called to halt the remote machine.
      def self.action_halt
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            if !env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use ConnectKubevirt
            b2.use StopVM
          end
        end
      end

      # This action is called to terminate the remote machine.
      def self.action_destroy
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            if !env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use ConnectKubevirt
            b2.use DestroyVM
            b2.use Call, WaitForState, :stopped, 120 do |env2, b3|
              if !env2[:result]
                # TODO message stop failed
              end
            end
          end
        end
      end

      # The autoload farm
      action_root = Pathname.new(File.expand_path("../action", __FILE__))
      autoload :ConnectKubevirt, action_root.join("connect_kubevirt")
      autoload :CreateVM, action_root.join("create_vm")
      autoload :DestroyVM, action_root.join("destroy_vm")
      autoload :IsCreated, action_root.join("is_created")
      autoload :MessageAlreadyCreated, action_root.join("message_already_created")
      autoload :MessageNotCreated, action_root.join("message_not_created")
      autoload :ReadState, action_root.join("read_state")
      autoload :ReadSSHInfo, action_root.join("read_ssh_info")
      autoload :StartVM, action_root.join("start_vm")
      autoload :StopVM, action_root.join("stop_vm")
      autoload :WaitForState, action_root.join("wait_for_state")
    end
  end
end