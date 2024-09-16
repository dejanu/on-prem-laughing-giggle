# Steps to install Kubernetes for vanilla Ubuntu 18.04

* Networking Prerequisites:

Full network connectivity among all machines in the cluster (either a public or a private network)
Ensure both VMs have internal networking enabled and can communicate with each other (same network, and ensure firewall rules allow required ports).

Disable swap: `sudo swapoff -a`.