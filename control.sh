#!/bin/bash
CIDR=172.16.0.0
LAB_CALICO_VERSION=3.24.2

#  --allocate-node-cidrs=true <- outdated
kubeadm init --pod-network-cidr=$CIDR/16

mkdir -p /root/.kube /home/ubuntu/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config 
cp /etc/kubernetes/admin.conf /home/ubuntu/.kube/config 

sleep 5

# generate a join token for Windows
kubeadm token create --print-join-command  > /root/join.sh

# Install CANAL
while [ $(KUBECONFIG=/etc/kubernetes/admin.conf kubectl get ds -n kube-system canal | wc -l) != 2 ];
do
KUBECONFIG=/etc/kubernetes/admin.conf kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v$LAB_CALICO_VERSION/manifests/canal.yaml
sleep 15
done
