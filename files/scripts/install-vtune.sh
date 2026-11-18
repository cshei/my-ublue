#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

tee > /etc/yum.repos.d/oneAPI.repo << EOF
[oneAPI]
name=Intel® oneAPI repository
baseurl=https://yum.repos.intel.com/oneapi
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://yum.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
EOF

# https://github.com/coreos/rpm-ostree/issues/233#issuecomment-1301194050
mkdir /var/opt
rpm-ostree install intel-oneapi-vtune
mv /var/opt/intel /usr/lib/intel
echo 'L /opt/intel - - - - ../../usr/lib/intel' > /usr/lib/tmpfiles.d/intel.conf
