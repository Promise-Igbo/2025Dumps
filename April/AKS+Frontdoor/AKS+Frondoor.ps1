# Prerequisites:
# - AKS cluster with a vnet
# - Frontdoor (Premuim)
# - Azure subnet to where the Private Link will be deployed.

# Set the variables
$RG='aksafdrg'
$loc='eastus'
$aks='akseastus'
$afd='afdeastus'


az group create -n $RG -l $loc

$Subscriptionid='ca0aa86a-bcd6-4bef-b72c-45302a5515f6'
$vnetname='vneteastus'
$subnetname='subneteastus'


az network vnet create `
    --name vneteastus `
    --resource-group $RG `
    --address-prefix 10.0.0.0/16 `
    --subnet-name subneteastus `
    --subnet-prefixes 10.0.0.0/24  

az aks create `
  --resource-group $RG `
  --name $aks `
  --network-plugin azure `
  --vnet-subnet-id /subscriptions/$Subscriptionid/resourceGroups/$RG/providers/Microsoft.Network/virtualNetworks/$vnetname/subnets/$subnetname `
  --service-cidr 10.1.0.0/16 `
  --dns-service-ip 10.1.0.10 `
  --generate-ssh-keys


az afd profile create --profile-name $afd --resource-group $RG --sku Premium_AzureFrontDoor
az afd endpoint create --resource-group $RG --endpoint-name testafd --profile-name $afd --enabled-state Enabled
az afd origin-group create -g $RG --origin-group-name ogaks --profile-name $afd --probe-request-type GET --probe-protocol Http --probe-interval-in-seconds 60 --probe-path / --sample-size 4 --successful-samples-required 3 --additional-latency-in-milliseconds 50

az aks get-credentials -n $aks -g $RG

# run the aksfrontdoor.yaml file.
kubectl apply -f aksfrontdoor.yaml

# Add an origin to the origin group, use the settingd below:
# Name - test, Origin type - custom, Host name and Origin host header must be a valid domain name,
# Enable private link, Resource : choose the private link, then write a request message to approve the private link.
# Select Add and Update.

# On the Private Link page, select the Private Link services > click on private link > under the settings > select private endpoint connections > Select the pending private endpoint and Approve.

az afd route create -g $RG --profile-name $afd --endpoint-name testafd --forwarding-protocol HTTP --route-name route --https-redirect Enabled --origin-group ogaks --supported-protocols Http Https --link-to-default-domain Enabled

#Note: The image mcr.microsoft.com/azuredocs/azure-vote-front:v1 is no longer avialable.
# I use this image which is publicly avialable on docker - mahmoudtimoumi/azure-vote-front:v1 