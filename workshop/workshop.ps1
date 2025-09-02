# Show secure code push & GHAS alerts
# Clone repo and simulate a commit with a secret
git clone https://github.com/your-org/smart-credit-engine.git
cd smart-credit-engine
echo "API_KEY=sk_test_fakekey123456" >> app/config.py
git add .
git commit -m "simulate secret leakage"
git push
# GitHub Security tab → Secret scanning alert

# Deploy containerized app securely to AKS
# Sample GitHub Action in .github/workflows/deploy.yml
jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build Docker image
        run: docker build -t smartcreditengine:v1 .
      - name: Push to ACR
        run: |
          az acr login --name <registry-name>
          docker tag smartcreditengine:v1 <registry-name>.azurecr.io/smartcreditengine:v1
          docker push <registry-name>.azurecr.io/smartcreditengine:v1
      - name: Deploy to AKS
        run: |
          kubectl apply -f k8s/deployment.yaml
# Confirm deployment + health
# Access AKS cluster
az aks get-credentials --resource-group <rg> --name <aks-name>
kubectl get pods
kubectl logs <pod-name>


# Securely expose internal microservice
# Use Azure Portal: APIM > APIs > Add API
# Set backend URL to AKS service
# Apply policy: rate limit
<rate-limit calls="10" renewal-period="60" />

# Show credit score API powered by Azure AI
# Simulate model inference
import requests
response = requests.post("https://<ai-url>/score", json={
    "income": 50000, "credit_history": "good", "age": 30
})
print(response.json())

# Test Full Flow in Postman
# Endpoint: https://<api-management-endpoint>/credit/score
# Headers: Authorization: Bearer <JWT>
# Body:
{
  "customer_id": "123456789",
  "loan_amount": 250000
}
# Output: {"decision": "approved", "confidence": 0.91}