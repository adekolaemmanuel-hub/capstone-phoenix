# Cost Analysis — Capstone Phoenix

## Monthly Infrastructure Cost (AWS us-east-1)

| Resource | Type | Qty | Unit Price | Monthly Cost |
|----------|------|-----|------------|--------------|
| EC2 Control Plane | t3.medium | 1 | ~$0.0416/hr | ~$30.00 |
| EC2 Worker Nodes | t3.medium | 2 | ~$0.0416/hr | ~$60.00 |
| EBS Volumes (root) | gp2 8GB | 3 | ~$0.10/GB/mo | ~$2.40 |
| EBS Volume (Postgres PVC) | gp2 5GB | 1 | ~$0.10/GB/mo | ~$0.50 |
| S3 (Terraform state) | Standard | 1 | ~$0.023/GB/mo | ~$0.01 |
| DynamoDB (state lock) | On-demand | 1 | Pay per request | ~$0.01 |
| Data transfer | Outbound | - | ~$0.09/GB | ~$1.00 |

**Total estimated monthly cost: ~$94/month**

## How to Cut Cost in Half

Switch all three nodes from t3.medium ($0.0416/hr) to t3.small ($0.0208/hr).
This reduces compute cost from ~$90/month to ~$45/month — roughly a 50% reduction.
The tradeoff is less headroom for memory-intensive workloads like Argo CD.
A better long-term approach would be to use spot instances for the two worker nodes
(typically 60-70% cheaper than on-demand) while keeping the control plane on
on-demand to ensure cluster stability. This would bring the total to approximately
$35-40/month while maintaining the same architecture.
