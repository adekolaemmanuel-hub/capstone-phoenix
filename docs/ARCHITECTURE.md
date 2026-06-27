# Architecture — Capstone Phoenix

## Node Topology

3-node k3s cluster on AWS EC2 (us-east-1a):

| Node | Role | Instance | Private IP |
|------|------|----------|------------|
| ip-10-0-1-196 | control-plane | t3.medium | 10.0.1.196 |
| ip-10-0-1-147 | worker | t3.medium | 10.0.1.147 |
| ip-10-0-1-82 | worker | t3.medium | 10.0.1.82 |

## Request Flow
User Browser

│

▼

DNS: taskapp.adekoladevops.xyz (Namecheap → 32.195.65.166)

│

▼

AWS Security Group (port 80/443 open)

│

▼

Traefik Ingress Controller (k3s built-in)

│

├── taskapp.adekoladevops.xyz → frontend-service:80 → nginx pod

│       │

│       └── /api/* proxied → backend:5000

│

└── api.adekoladevops.xyz → backend:5000 → Flask pod

│

└── postgres-service:5432 → Postgres StatefulSet
TLS: cert-manager + Let's Encrypt (letsencrypt-prod ClusterIssuer)
## How Each Core Requirement Fixes Single-Server Assumptions

| Requirement | Single-server problem | Kubernetes fix |
|-------------|----------------------|----------------|
| Postgres StatefulSet + PVC | Data lost if container restarts | PVC persists data independently of pod lifecycle |
| 2 backend replicas + topologySpreadConstraints | One crash kills the API | Pods spread across nodes; one node down = still serving |
| 2 frontend replicas + topologySpreadConstraints | One crash kills the UI | Same as above |
| Migration Job (not entrypoint) | Race condition at 2+ replicas | Job runs once before replicas start |
| RollingUpdate maxUnavailable:0 | Downtime during deploys | Zero-downtime rolling updates |
| Liveness + readiness probes | Bad pods receive traffic | Only healthy pods get traffic |
| Argo CD GitOps | Manual kubectl apply = human error | Git is source of truth; cluster self-heals |
| HPA | Fixed capacity, can't scale | Auto-scales backend on CPU pressure |
| PodDisruptionBudget | Node drain kills all replicas | Guarantees minAvailable=1 during maintenance |
| TLS via cert-manager | HTTP only | Automatic Let's Encrypt cert rotation |

## GitOps Flow
Developer pushes commit to main

│

▼

GitHub (manifests/ directory updated)

│

▼

Argo CD detects drift (polls every 3 minutes)

│

▼

Argo CD syncs cluster to match git state

│

▼

Kubernetes applies changes (rolling update)
