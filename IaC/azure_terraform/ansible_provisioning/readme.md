### Test infra

```bash
ansible control_plane -v -m ping -i inventory.j2
ansible worker_nodes -v -m ping -i inventory.j2
```

* Install pre-req: `ansible-galaxy collection install community.kubernetes`
* Configure and install dependencies: `ansible-playbook -i inventory.j2 k8s-setup.yml`
* Setup control-plane: `ansible-playbook -i inventory.j2 k8s-init-control-plane.yml`
* Setup metrics and LB: `ansible-playbook -i inventory.j2 k8s-addons.yml`

* Ansible Python [matrix](https://docs.ansible.com/ansible/latest/reference_appendices/release_and_maintenance.html#ansible-core-support-matrix)

### Add a new node to the cluster:

* Modify terraform `variables.tf` accordingly 
* Run: `terraform plan` and `terraform apply`
* Run ansible playbooks ONLY for the new node, i.e. `ansible-playbook -i inventory.j2 k8s-setup.yml -l 20.126.142.51`

* To enroll new nodes to cluster, ssh on the control-plane node and run: 
```bash
# Bootstrap tokens are used for establishing bidirectional trust between a node joining the cluster and a control-plane node
kubeadm token list 
kubeadm token create --print-join-command 
```

Then on the desired node
```bash
# to create a new control plane node run on the new node kubeadm join with flag
sudo kubeadm join <master-node-ip>:6443 --token <your-token> --discovery-token-ca-cert-hash sha256:<hash> --control-plane

# to create worker node run on the new node kubeadm join
sudo kubeadm join <master-node-ip>:6443 --token <your-token>in teros --discovery-token-ca-cert-hash sha256:<hash>
```
