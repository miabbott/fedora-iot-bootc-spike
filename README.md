# Building Fedora IoT using bootc containers

This is an exploration of building Fedora IoT content using [`bootc`](https://gitlab.com/fedora/bootc/)
containers. The goal is to determine what changes are needed to properly
support the IoT/Edge use case.

## Fedora IoT content

A Fedora IoT system was updated to the latest ostree commit
available on the `fedora/stable/x86_64/iot` ref; this was `40.20240830.0`
or `b71d5a59dead3100803a1abd74d39a69fa4cb507a7c65595be4bc3227cd66393`.

The RPM content of the commit was captured in a text file ([fedora-iot-40-rpms.txt](fedora-iot-40-rpms.txt))
as a baseline. (Command used was `rpm -qa --qf "%{NAME}\n" | sort`)

The Fedora IoT image that will be built using `bootc` containers should include
all of the RPMs included in that text file.

## Fedora bootc base image content

As another baseline, the latest `fedora-bootc:40` base image (`quay.io/fedora/fedora-bootc@sha256:ec2d9ef4eff1ff0bde49ee1114c9065b8082a7779392088aa24067b5b22c6ea2`)
was retrieved and the RPM content was captured to a text file (fedora-bootc-40-rpms.txt](fedora-bootc-40-rpms.txt)).

## Building the IoT bootc container image

After inspecting the diff between the Fedora IoT RPMs and `fedora-bootc` RPMs, a
[Containerfile](Containerfile) was constructed to build the container image.

### `rootfiles` workaround

The vanilla Fedora IoT `ostree` commit included the `rootfiles` package, but the package does not use
the [systemd sysusers.d](https://www.freedesktop.org/software/systemd/man/latest/sysusers.d.html#)
method of allocating users, so it failed to install during the initial attempt at building the container image.

There is an existing [bug against the Fedora package](https://bugzilla.redhat.com/show_bug.cgi?id=2260104)
and a [PR that fixes the packaging](https://src.fedoraproject.org/rpms/rootfiles/pull-request/5).
A multi-stage build workaround was used to build a version of the `rootfiles` package
that would install successfully during the building of the bootable container image.

# Comparing the RPM content

The list of RPMs in the Fedora IoT bootable container was retrieved
([fedora-iot-bootc-rpms.txt](fedora-iot-bootc-rpms.txt)) and compared
with the list of RPMs in the vanilla Fedora IoT`ostree` commit.

The output of the diff'ed RPM content can be seen in [fedora-iot-bootc-diff.txt](fedora-iot-bootc-diff.txt).

## Notable differences

Since the `fedora-bootc` base image aims to be a general purpose starting point for bare metal, cloud,
and virtualized systems, it includes packages that may not be explicitly necessary for IoT/Edge use
cases.

Cloud specific packages such as `NetworkManager-cloud-setup`, `WALinuxAgent-udev`, and `cloud-utils-growpart`
are unlikely to be useful in an Edge deployment.

Additionally the inclusion of the `sssd` stack and related libraries may not be useful in an Edge
environment.

Also, bare metal utilities such as `irqbalance`, `mdadm`, `nvme-cli`, and `sg3_utils` are unlikely to be used
on Edge devices, where the maintenance practice may be to take the device offline completely and
reflash the system to reach a desired new state.

There's a number of extra firmware packages included as well, which may be overkill even for the cloud,
baremetal, and virtualized use cases. For example: `amd-gpu-firmware`, `amd-ucode-firmware`, `cirrus-audio-firmware`,
`intel-audio-firmware`,`intel-gpu-firmware`, `nvidia-gpu-firmware`.

Lastly, we have the inclusion of `nano` and the inclusion of `vim-minimal`. While choice is important
in the open source community, we should be able to have an opinionated default in the category of
text editor. (Fedora [defaults to `nano` as of Fedora 33!](https://fedoraproject.org/wiki/Changes/UseNanoByDefault))

## TODO

- deploy IoT bootc image to system, inspect any problems
- investigate how to smooth transition from ostree commit to bootc container