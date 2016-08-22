# Ubuntu 16.04 Desktop Environment

## Overview

This repository contains the source template for the Ubuntu 16.04 desktop image
used in the O'Relly Learning Chef for Linux and macOS video. The image is
published on [Atlas](https://atlas.hashicorp.com/learningchef/ubuntu1604-desktop).

## Building the Vagrant boxes with Packer

To build all the boxes, you will need [VirtualBox](https://www.virtualbox.org/wiki/Downloads),
[VMware Fusion](https://www.vmware.com/products/fusion)/[VMware Workstation](https://www.vmware.com/products/workstation) and
[Parallels](http://www.parallels.com/products/desktop/whats-new/) installed.

Parallels requires that the
[Parallels Virtualization SDK for Mac](http://www.parallels.com/downloads/desktop)
be installed as an additional preqrequisite.

VMware Fusion boxes require this patch when running version 8.1.0 to enable port forwarding:
https://blogs.vmware.com/teamfusion/2016/01/workaround-of-nat-port-forwarding-issue-in-fusion-8-1.html

We make use of JSON files containing user variables to build specific versions of Ubuntu.
You tell `packer` to use a specific user variable file via the `-var-file=` command line
option.  This will override the default options on the core `ubuntu.json` packer template,
which builds Ubuntu 16.04 Desktop by default.

For example, to build Ubuntu 16.04 Desktop, use the following:

    $ packer build -var-file=ubuntu1604-desktop.json ubuntu.json

If you want to make boxes for a specific desktop virtualization platform, use the `-only`
parameter.  For example, to build Ubuntu 16.04 Desktop for VirtualBox:

    $ packer build -only=virtualbox-iso -var-file=ubuntu1604-desktop.json ubuntu.json

## Building the Vagrant boxes with the box script

We've also provided a wrapper script `bin/box` for ease of use, so alternatively, you can use
the following to build Ubuntu 16.04 for all providers:

    $ bin/box build ubuntu1604-desktop

Or if you just want to build Ubuntu 16.04 for VirtualBox:

    $ bin/box build ubuntu1604-desktop virtualbox

## Building the Vagrant boxes with the Makefile

A GNU Make `Makefile` drives a complete basebox creation pipeline with the following stages:

* `build` - Create basebox `*.box` files
* `assure` - Verify that the basebox `*.box` files produced function correctly
* `deliver` - Upload `*.box` files to [Artifactory](https://www.jfrog.com/confluence/display/RTF/Vagrant+Repositories), [Atlas](https://atlas.hashicorp.com/) or an [S3 bucket](https://aws.amazon.com/s3/)

The pipeline is driven via the following targets, making it easy for you to include them
in your favourite CI tool:

    make build   # Build all available box types
    make assure  # Run tests against all the boxes
    make deliver # Upload box artifacts to a repository
    make clean   # Clean up build detritus
