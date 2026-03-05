#!/bin/bash

# Its unnecessary but just practice with cond)
if [[ "$SUDO_USER" != "dan-it" || "$EUID" -ne 0 ]]; then
        echo "You arent dan or dont have sudo priv";
        exit 1;
fi

sudo hostnamectl set-hostname ubuntu22

echo "$(hostname)"
exit 0;
