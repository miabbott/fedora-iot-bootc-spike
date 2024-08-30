FROM registry.fedoraproject.org/fedora:40 as builder
RUN dnf install -y rpm-build git dnf-plugins-core
WORKDIR /usr/src/rootfiles
RUN git clone https://src.fedoraproject.org/rpms/rootfiles.git .
RUN git fetch origin +refs/pull/*:refs/remotes/origin/pr/*
RUN git checkout origin/pr/5/head
RUN dnf builddep -y rootfiles.spec
RUN rpmbuild -bb rootfiles.spec \
    --define "_topdir `pwd`" \
    --define "_sourcedir `pwd`" \
    --define "_specdir `pwd`" \
    --define "_builddir `pwd`" \
    --define "_srcrpmdir `pwd`" \
    --define "_rpmdir `pwd`"


FROM quay.io/fedora/fedora-bootc:40
WORKDIR /tmp
COPY --from=builder /usr/src/rootfiles/noarch/rootfiles-*.rpm .
RUN dnf -y install rootfiles-*.rpm
RUN dnf -y install ModemManager \
                   NetworkManager-wifi \
                   NetworkManager-wwan \
                   clevis-dracut \
                   clevis-pin-tpm2 \
                   containernetworking-plugins \
                   dbus-parsec \
                   dnsmasq \
                   dracut-config-generic \
                   fdo-client \
                   fedora-iot-config \
                   fedora-release-iot \
                   firewalld \
                   greenboot \
                   greenboot-default-health-checks \
                   ignition \
                   iwd \
                   iwlwifi-mvm-firmware \
                   kernel-tools \
                   libell \
                   parsec \
                   screen \
                   setools-console \
                   slirp4netns \
                   tmux \
                   tpm2-pkcs11 \
                   traceroute \
                   usbguard \
                   wpa_supplicant \
                   zezere-ignition \
                   zram-generator-defaults
