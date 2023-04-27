# revision obtained by running:
#   curl --silent --show-error 'https://monitoring.nixos.org/prometheus/api/v1/query?query=channel_revision'
# and grabbing the unstable revision

import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/8e3b64db39f2aaa14b35ee5376bd6a2e707cadc2.tar.gz")
