#!/bin/bash

set -oue pipefail 

cat << EOF > /etc/yum.repos.d/google-chrome.repo
[google-chrome]
name=google-chrome
baseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl.google.com/linux/linux_signing_key.pub
EOF

# We need to download and install the Google signing keys separately, we can't trust
# rpm-ostree to do it cleanly from the yum repo directly.
# Possibly related to https://github.com/rpm-software-management/rpm/issues/2577

echo "Downloading Google Signing Key"
curl https://dl.google.com/linux/linux_signing_key.pub > /tmp/linux_signing_key.pub

rpm --import /tmp/linux_signing_key.pub
