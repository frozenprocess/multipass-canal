
multipass launch --name control -m 2048M -c 2 --cloud-init release/control-init.yaml https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2

multipass launch --name node1 --cloud-init release/node-init.yaml https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2
