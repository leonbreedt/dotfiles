# revision obtained by running:
#   curl --silent --show-error 'https://monitoring.nixos.org/prometheus/api/v1/query?query=channel_revision'
# and grabbing the stable darwin revision

import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/f30da2c2622736aecdccac893666ea23cad90f2d.tar.gz")
