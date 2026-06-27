# Runbook — Capstone Phoenix

## Prerequisites
- AWS CLI configured
- kubectl with kubeconfig at ~/capstone-phoenix/kubeconfig
- Terraform installed
- Ansible installed
- SSH key at ~/.ssh/capstone-phoenix-key.pem

## Provision from Zero

### 1. Update your IP (changes every session)
```bash
curl -s https://checkip.amazonaws.com
cd ~/capstone-phoenix/infra/terraform
# Update my_ip in terraform.tfvars
terraform apply
# Update UFW on control plane
ssh -i ~/.ssh/capstone-phoenix-key.pem ubuntu@<control-plane-ip> \
  "sudo ufw allow from <your-ip> to any port 6443 proto tcp"
```

### 2. Provision infrastructure
```bash
cd ~/capstone-phoenix/infra/terraform
terraform init
terraform apply
```

### 3. Install k3s cluster
```bash
cd ~/capstone-phoenix/infra/ansible
# Update IPs in inventory.ini and playbook.yml
ansible-playbook -i inventory.ini playbook.yml
```

### 4. Configure kubectl
```bash
ssh -i ~/.ssh/capstone-phoenix-key.pem ubuntu@<control-plane-ip> \
  "sudo cat /etc/rancher/k3s/k3s.yaml" > ~/capstone-phoenix/kubeconfig
sed -i 's/127.0.0.1/<control-plane-ip>/g' ~/capstone-phoenix/kubeconfig
export KUBECONFIG=~/capstone-phoenix/kubeconfig
kubectl get nodes
```

### 5. Install cert-manager and Argo CD
```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.0/cert-manager.yaml
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 6. Deploy application
```bash
kubectl apply -f manifests/namespace.yaml
kubectl apply -f manifests/clusterissuer.yaml
kubectl apply -f manifests/
```

## Scale

### Scale backend manually
```bash
kubectl scale deployment backend -n taskapp --replicas=3
```

### HPA handles auto-scaling automatically based on CPU

## Roll Back

### Roll back backend to previous version
```bash
kubectl rollout undo deployment/backend -n taskapp
kubectl rollout status deployment/backend -n taskapp
```

## Recover from a Dead Worker Node

### 1. Check which node is down
```bash
kubectl get nodes
```

### 2. Pods will reschedule automatically within 5 minutes
```bash
kubectl get pods -n taskapp -o wide
```

### 3. If node is permanently dead, terminate and reprovision
```bash
cd ~/capstone-phoenix/infra/terraform
terraform apply  # will recreate missing node
cd ~/capstone-phoenix/infra/ansible
ansible-playbook -i inventory.ini playbook.yml  # rejoin cluster
```

## Recover from a Dead Backend Pod

Kubernetes restarts it automatically. To check:
```bash
kubectl get pods -n taskapp
kubectl logs -n taskapp <pod-name>
```

## Recover from a Bad Migration

```bash
# Delete the failed job
kubectl delete job taskapp-migration-v2 -n taskapp
# Fix the migration, push to git
# Argo CD will sync and recreate the job
```
