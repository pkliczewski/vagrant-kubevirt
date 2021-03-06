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
          	b1.use SetDomainName

            if env1[:result]
              b1.use Message,
                I18n.t("vagrant_kubevirt.already_status", :status => "created")
            else
              b1.use CreateVM
            end
          end

          b.use Provision
          b.use SyncedFolders

          b.use Call, IsStopped do |env2, b2|
            if env2[:result]
              b2.use StartVM
              b2.use Call, WaitForState, :running, 120 do |env3, b3|
                unless env3[:result]
                  b3.use Message,
                    I18n.t("vagrant_kubevirt.action_failed", :action => 'Up')
                end
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
            unless env[:result]
              b2.use Message,
                I18n.t("vagrant_kubevirt.not_created")
              next
            end

            b2.use ConnectKubevirt
            b2.use SetDomainName
            b2.use StopVM
            b2.use Call, WaitForState, :stopped, 120 do |env2, b3|
              unless env2[:result]
                b2.use Message,
                  I18n.t("vagrant_kubevirt.action_failed", :action => 'Halt')
              end
            end
          end
        end
      end

      # This action is called to terminate the remote machine.
      def self.action_destroy
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            unless env[:result]
              b2.use Message,
                I18n.t("vagrant_kubevirt.not_created")
              next
            end

            b2.use ConnectKubevirt
            b2.use DestroyVM
          end
        end
      end

      # This action is called to read the state of the machine. The
      # resulting state is expected to be put into the `:machine_state_id`
      # key.
      def self.action_read_state
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectKubevirt
          b.use ReadState
        end
      end

      # This action is called to read the SSH info of the machine. The
      # resulting state is expected to be put into the `:machine_ssh_info`
      # key.
      def self.action_read_ssh_info
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectKubevirt
          b.use ReadSSHInfo
        end
      end


      # This action is called to SSH into the machine.
      def self.action_ssh
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            unless env[:result]
              b2.use Message,
                I18n.t("vagrant_kubevirt.not_created")
              next
            end

            b2.use SSHExec
          end
        end
      end

      def self.action_ssh_run
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            unless env[:result]
              b2.use Message,
                I18n.t("vagrant_kubevirt.not_created")
              next
            end

            b2.use SSHRun
          end
        end
      end

      def self.action_provision
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            unless env[:result]
              b2.use Message,
                I18n.t("vagrant_kubevirt.not_created")
              next
            end

            b2.use Call, IsStopped do |env2, b3|
              if env2[:result]
                I18n.t("vagrant_kubevirt.not_running")
                next
              end

              b3.use Provision
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
      autoload :IsStopped, action_root.join("is_stopped")
      autoload :ReadState, action_root.join("read_state")
      autoload :ReadSSHInfo, action_root.join("read_ssh_info")
      autoload :SetDomainName, action_root.join("set_domain_name")
      autoload :StartVM, action_root.join("start_vm")
      autoload :StopVM, action_root.join("stop_vm")
      autoload :WaitForState, action_root.join("wait_for_state")
    end
  end
end