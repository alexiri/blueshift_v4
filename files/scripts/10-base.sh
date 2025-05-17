#!/usr/bin/env bash

set -xeuo pipefail

# Example of how you start customizing the image

dnf install -y 'dnf-command(config-manager)'
dnf config-manager --set-enabled crb
