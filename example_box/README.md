# Vagrant Kubevirt Example Box

Vagrant providers each require a custom provider-specific box format.
This folder shows the example contents of a box for the `kubevirt` provider.
To turn this into a box:

```
$ tar cvzf kubevirt.box ./metadata.json ./Vagrantfile
```	