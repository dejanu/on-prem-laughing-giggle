### Test infra

```bash
ansible control_plane -v -m ping -i inventory.j2
ansible worker_nodes -v -m ping -i inventory.j2
```

* Install pre-req: `ansible-galaxy collection install community.kubernetes`
* Configure and install dependencies: `ansible-playbook -i inventory.j2 k8s-setup.yml`
* Setup control-plane: `ansible-playbook -i inventory.j2 k8s-init-control-plane.yml`
* Setup worker node: `ansible-playbook -i invenotry.j2 join-worker-nodes.yml`