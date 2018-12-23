#!/bin/sh -e
name=`ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'`
sudo ros config set hostname ${name}
