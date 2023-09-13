#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

echo 'L /usr/bin/go - - - - /usr/lib/golang/bin/go' > /usr/lib/tmpfiles.d/golang.conf
echo 'L /usr/bin/ld - - - - /usr/bin/ld.mold' > /usr/lib/tmpfiles.d/mold.conf
