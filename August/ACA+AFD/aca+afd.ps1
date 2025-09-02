# Create a container app
# update latest version of the Azure Container Apps extension
az extension add --name containerapp --upgrade --allow-preview true

# Set environment variables
RESOURCE_GROUP="prom-container-apps"
LOCATION="centralus"
ENVIRONMENT_NAME="prom-environment"
CONTAINERAPP_NAME="prom-container-app"
AFD_PROFILE="prom-afd-profile"
AFD_ENDPOINT="prom-afd-endpoint"
AFD_ORIGIN_GROUP="prom-afd-origin-group"
AFD_ORIGIN="prom-afd-origin"
AFD_ROUTE="prom-afd-route"

# Create an Azure resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create an environment
az containerapp env create --name $ENVIRONMENT_NAME --resource-group $RESOURCE_GROUP --location $LOCATION

# Retrieve the environment ID. You use this ID to configure the environment.
ENVIRONMENT_ID=$(az containerapp env show \
    --resource-group $RESOURCE_GROUP --name $ENVIRONMENT_NAME --query "id" --output tsv)

# Disable public network access for the environment.
az containerapp env update --id $ENVIRONMENT_ID --public-network-access Disabled

# Deploy a container app
az containerapp up --name $CONTAINERAPP_NAME --resource-group $RESOURCE_GROUP \
    --location $LOCATION --environment $ENVIRONMENT_NAME --image hello-world:latest \
    --target-port 80 --ingress external --query properties.configuration.ingress.fqdn

# Retrieve your container app endpoint.
ACA_ENDPOINT=$(az containerapp show \
    --name $CONTAINERAPP_NAME --resource-group $RESOURCE_GROUP \
    --query properties.configuration.ingress.fqdn --output tsv)

# Browse to the container app endpoint, you receive ERR_CONNECTION_CLOSED because the container app environment has public access disabled.
# Use AFD endpoint to access your container app.

# Create an Azure Front Door profile
# Register resource provider
az provider register --namespace Microsoft.Cdn

az afd profile create --profile-name $AFD_PROFILE --resource-group $RESOURCE_GROUP \
    --sku Premium_AzureFrontDooraz afd profile create --profile-name $AFD_PROFILE \
    --resource-group $RESOURCE_GROUP --sku Premium_AzureFrontDoor

# Create an Azure Front Door endpoint
az afd endpoint create --resource-group $RESOURCE_GROUP \
    --endpoint-name $AFD_ENDPOINT --profile-name $AFD_PROFILE --enabled-state Enabled

# Create an Azure Front Door origin group
az afd origin-group create --resource-group $RESOURCE_GROUP \
    --origin-group-name $AFD_ORIGIN_GROUP --profile-name $AFD_PROFILE \
    --probe-request-type GET --probe-protocol Http --probe-interval-in-seconds 60 \
    --probe-path / --sample-size 4 --successful-samples-required 3 --additional-latency-in-milliseconds 50

# Create an Azure Front Door origin
az afd origin create --resource-group $RESOURCE_GROUP \
    --origin-group-name $AFD_ORIGIN_GROUP --origin-name $AFD_ORIGIN \
    --profile-name $AFD_PROFILE --host-name $ACA_ENDPOINT --origin-host-header $ACA_ENDPOINT \
    --priority 1 --weight 500 --enable-private-link true --private-link-location $LOCATION \
    --private-link-request-message "AFD Private Link Request" --private-link-resource $ENVIRONMENT_ID \
    --private-link-sub-resource-type managedEnvironments

# List private endpoint connections
az network private-endpoint-connection list --name $ENVIRONMENT_NAME \
    --resource-group $RESOURCE_GROUP --type Microsoft.App/managedEnvironments

# Record the private endpoint connection resource ID from the response.
# It should look like this
# /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RESOURCE_GROUP>/providers/Microsoft.App/managedEnvironments/my-environment/privateEndpointConnections/<PRIVATE_ENDPOINT_CONNECTION_ID>

# Approve the private endpoint connection
# az network private-endpoint-connection approve --id <PRIVATE_ENDPOINT_CONNECTION_RESOURCE_ID>

# Add a route
# map the endpoint you created earlier to the origin group.
# Private endpoints on Azure Container Apps only support inbound HTTP traffic. TCP traffic isn't supported.
az afd route create --resource-group $RESOURCE_GROUP --profile-name $AFD_PROFILE \
    --endpoint-name $AFD_ENDPOINT --forwarding-protocol MatchRequest --route-name $AFD_ROUTE \
    --https-redirect Enabled --origin-group $AFD_ORIGIN_GROUP \
    --supported-protocols Http Https --link-to-default-domain Enabled

# Access your container app from Azure Front Door
az afd endpoint show --resource-group $RESOURCE_GROUP --profile-name $AFD_PROFILE \
    --endpoint-name $AFD_ENDPOINT --query hostName --output tsv

# Clean up resources
az group delete -n $RESOURCE_GROUP --no-wait --yes


# Other public images that can be used
# nginxdemos/hello
