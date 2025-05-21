# Azure Kubernetes Service — Next level persistent storage with Azure Disk CSI driver

az feature register --name SsdZrsManagedDisks --namespace Microsoft.Compute
az feature register --name EnableAzureDiskFileCSIDriver --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.Compute
az provider register -n Microsoft.ContainerService

$RG = "aks-csi-rg"
$AKS = "aks-csi"
$loc = "eastus"

az group create -g $RG -l $loc
az aks create -n $AKS `
  -g $RG `
  -l $loc `
  -c 3 `
  -s Standard_B2ms `
  --aks-custom-headers EnableAzureDiskFileCSIDriver=true

az aks get-credentials -n $AKS -g $RG

kubectl apply -f StorageClass.yaml
kubectl apply -f PersistentVolumeClaim.yaml

kubectl apply -f VolumeSnapshot.yaml
kubectl describe volumesnapshot azuredisk-volume-snapshot

#To attach volume snapshot to another workload

kubectl apply -f pvc-azuredisk-snapshot-restored.yaml
kubectl get pvc
kubectl get pv

# The PVC needs to be unmounted for resizing
# The PV will be resized directly, the PVC after mounting it

# You can resize the above-cloned PVC via kubectl by executing the following command
kubectl patch pvc pvc-azuredisk-snapshot-restored --type merge --patch '{"spec": {"resources": {"requests": {"storage": "512Gi"}}}}'

# we mount our PVC to multiple workloads via ReadWriteMany. With the new ZRS Azure Disks
kubectl apply -f Deployment.yaml

kubectl get pods,volumeattachments -o wide