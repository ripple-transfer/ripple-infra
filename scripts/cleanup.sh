#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

sudo k0s stop
sudo k0s reset