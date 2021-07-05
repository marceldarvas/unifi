# Run Suricata 5.0.3 with custom rules
## UBNT updated Suricata in 1.9.x firmwares make this unneeded
## Features

1. Run a newer suricata with custom rules
2. Persists through reboots and firmware updates.

## Requirements

1. You have successfully setup the on boot script described [here](https://github.com/boostchicken/udm-utilities/tree/master/on-boot-script)

## Customization

* Put customs rules files in /mnt/data/suricata-rules

## Steps

1. Copy [25-suricata.sh](on_boot.d/25-suricata.sh) to /mnt/data/on_boot.d and update its values to reflect your environment
2. Execute /mnt/data/on_boot.d/25-suricata.sh
