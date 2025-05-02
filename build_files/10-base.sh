#!/usr/bin/env bash

set -xeuo pipefail

# This is the base for a minimal GNOME system on AlmaLinux.

dnf install -y 'dnf-command(config-manager)'
dnf config-manager --set-enabled crb
