#!/usr/bin/env bash

set -xeuo pipefail

# This is the base for a minimal GNOME system on AlmaLinux.

dnf config-manager --set-enabled crb

