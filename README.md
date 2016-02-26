# Packer templates for Ensembl VM

###

This repository contains [Packer](https://packer.io/) templates for creating Ubuntu Vagrant boxes pre-installed with the Ensembl API

## Boxes

This repository is derived from [Boxcutter](https://github.com/boxcutter/ubuntu), and customized for Ensembl. Only the Ubuntu Desktop 14.04.3 box is configured for Ensembl.

## Building the Vagrant box with Packer

To build the box, you will need [VirtualBox](https://www.virtualbox.org/wiki/Downloads), [Puppet](https://puppetlabs.com/puppet/puppet-open-source) and [Packer](https://www.packer.io/intro/getting-started/setup.html)

   You will also need the ensembl-vm-puppet repository checked out at the same level as this packer directory:
    $ git clone https://github.com/Ensembl/ensembl-vm-puppet.git
    $ git clone https://github.com/Ensembl/ensembl-packer-vm.git

Once the pre-reqs are installed, building the virtual machine should be as simple as:

    $ export ENSEMBL_RELEASE=83
    $ packer build ubuntu.json 2>&1 |tee build.log

Once the box built it can be added with:

    $ vagrant box add ensembl/ensembl ~/src/ubuntu/box/virtualbox/ensembl-83-ubuntu1404-desktop.box
    $ vagrant init ensembl/ensembl
    $ vagrant up

And you should have a functioning Ensembl VM.

## Removal of VM

To remove the box from your vagrant install simply issue:

    $ vagrant box remove ensembl/ensembl

## Install via Vagrant

To install the current prebuilt VM from Hashicorp's Atlas:

    $ vagrant init ensembl/ensembl
    $ vagrant up --provider virtualbox
