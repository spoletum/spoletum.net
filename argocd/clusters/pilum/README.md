# Bootstrap Instructions

### hcloud csi driver

```bash	
kubectl -n kube-system create secret generic hcloud --from-literal=token=[hcloud-token]
```