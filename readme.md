# Linux Unattended Installation

This project provides all you need to create an unattended installation of a minimal setup of Linux, whereas *minimal* translates to the most lightweight setup - including an OpenSSH service and Python - which you can derive from the standard installer of a Linux distribution. The idea is, you will do all further deployment of your configurations and services with the help of Ansible or similar tools once you completed the minimal setup.

## Ubuntu 18.04 LTS

Use the `build-iso.sh` script to create an ISO file based on the netsetup image of Ubuntu.

### Features

* Fully automated installation procedure.
* Authentication based on encrypted password.
* USB bootable hybrid ISO image.
* UEFI and BIOS mode supported.

### Prerequisites

Run `sudo apt-get install p7zip-full cpio gzip genisoimage whois pwgen wget fakeroot isolinux xorriso` to install software tools required by the `build-iso.sh` script.

### Usage

#### Build ISO images

You can run the `build-iso.sh` script as regular user. No root permissions required.

