#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

# https://github.com/coreos/rpm-ostree/issues/233#issuecomment-1301194050
mkdir -p /var/opt
rpm-ostree install https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
mv /var/opt/google /usr/lib/google
echo 'L /opt/google - - - - ../../usr/lib/google' > /usr/lib/tmpfiles.d/google.conf
