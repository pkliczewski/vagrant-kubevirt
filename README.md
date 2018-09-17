# Vagrant KubeVirt Provider


This is a [Vagrant](http://www.vagrantup.com) 1.2+ plugin that adds an [KubeVirt](http://kubevirt.io)
provider to Vagrant, allowing Vagrant to control and provision virtual machines using Kubernetes add-on.

**NOTE:** This plugin requires Vagrant 1.2+,

## Features
* In progress

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

...

## Box Format

Every provider in Vagrant must introduce a custom box format. This
provider introduces `kubevirt` boxes. You can view an example box in
the [example_box/ directory](https://github.com/pkliczewski/vagrant-kubevirt/tree/master/example_box).
That directory also contains instructions on how to build a box.

The box format is basically just the required `metadata.json` file
along with a `Vagrantfile` that does default settings for the
provider-specific configuration for this provider.

## Configuration

...
