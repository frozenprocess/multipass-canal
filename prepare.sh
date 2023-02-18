#!/bin/bash

KUBERNETES_VERSION=1.23.9
CIDR=172.16.0.0
CONTAINERD=1.6.18
RUNC=1.1.4
CNI_PLUGIN=1.1.1

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward


curl -OL https://github.com/containerd/containerd/releases/download/v$CONTAINERD/containerd-$CONTAINERD-linux-amd64.tar.gz
tar Cxzvf /usr/local containerd-$CONTAINERD-linux-amd64.tar.gz

mkdir -p /usr/local/lib/systemd/system/
curl -L https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -o /usr/local/lib/systemd/system/containerd.service

systemctl daemon-reload
systemctl enable --now containerd

curl -OL https://github.com/opencontainers/runc/releases/download/v$RUNC/runc.amd64
install -m 755 runc.amd64 /usr/local/sbin/runc

curl -OL https://github.com/containernetworking/plugins/releases/download/v$CNI_PLUGIN/cni-plugins-linux-amd64-v$CNI_PLUGIN.tgz
mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v$CNI_PLUGIN.tgz

systemctl restart containerd

mkdir /etc/containerd
# Cgroup baby
containerd config default | sed 's/SystemdCgroup = false/SystemdCgroup = true/' > /etc/containerd/config.toml

systemctl restart containerd

mkdir -p /etc/apt/keyrings/
curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet=$KUBERNETES_VERSION-00 kubeadm=$KUBERNETES_VERSION-00 kubectl=$KUBERNETES_VERSION-00 jq

apt-mark hold kubelet kubeadm kubectl

mkdir /root/.kube/
