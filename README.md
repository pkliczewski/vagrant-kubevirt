# Vagrant KubeVirt Provider


This is a [Vagrant](http://www.vagrantup.com) 1.2+ plugin that adds an [KubeVirt](http://kubevirt.io)
provider to Vagrant, allowing Vagrant to control and provision virtual machines using Kubernetes add-on.

**NOTE:** This plugin requires Vagrant 1.2+,

## Features
* Vagrant `up`, `halt`, `status` and `destroy` commands.
* Create and boot virtual machines using templates, registry image or pvc.

## Future work
* Provision the virtual machines with any built-in Vagrant provisioner.
* Synced folder support
* Package running virtual machines into new vagrant-kubevirt friendly boxes
* SSH into the VMIs


## Usage

Install using standard Vagrant 1.2+ plugin installation methods. After
installing, `vagrant up` and specify the `kubevirt` provider. An example is
shown below.

```
$ vagrant plugin install vagrant-kubevirt
...
$ vagrant up --provider=kubevirt
...
```

## Quick Start

After installing the plugin (instructions above), the quickest way to get
started is to actually use a Kubevirt box and specify all the details
manually within a `config.vm.provider` block. So first, add the box using
any name you want:

```
$ vagrant box add kubevirt https://raw.githubusercontent.com/pkliczewski/vagrant-kubevirt/master/example_box/kubevirt.box
...
```

And then make a Vagrantfile that looks like the following, filling in
your information where necessary.

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = 'kubevirt'

  config.vm.provider :kubevirt do |kubevirt|
    # kubevirt.template = 'working'
    kubevirt.cpus = 2
    kubevirt.memory = 512
    kubevirt.image = 'registry:5000/kubevirt/fedora-cloud-registry-disk-demo:devel'
    # kubevirt.pvc = 'my_pvc'

    kubevirt.hostname = '<kubevirt-host>'
    kubevirt.port = '<kubevirt port>'
    kubevirt.token = '<token>'
  end
end
```

And then run `vagrant up --provider=kubevirt`.

## Box Format

Every provider in Vagrant must introduce a custom box format. This
provider introduces `kubevirt` boxes. You can view an example box in
the [example_box/ directory](https://github.com/pkliczewski/vagrant-kubevirt/tree/master/example_box).
That directory also contains instructions on how to build a box.

The box format is basically just the required `metadata.json` file
along with a `Vagrantfile` that does default settings for the
provider-specific configuration for this provider.

## Configuration

This provider exposes following provider-specific configuration options:

* `hostname` - Hostname where Kubevirt is deployed
* `port` - Port on which Kubevirt is listening
* `token` - Token used to authenticate any requests

### Domain Specific Options

* `cpus` - Number of virtual cpus. Defaults to 1 if not set.
* `memory` - Amount of memory in MBytes. Defaults to 512 if not set.
* `template` -  Name of template from which new VM will be created.
* `image` - Name of image which will be used to create new VM.
* `pvc` - Name of persistent volume claim which will be used to create new VM.