# Azure Automation is a new service in Azure that allows you to automate your Azure management tasks and to orchestrate actions across external systems from right within Azure. 
# It is built on PowerShell Workflow
# Create automation account

# Import the required Azure module
Import-Module Az.Accounts
Import-Module Az.Websites

# Authenticate with Azure
Connect-AzAccount -Identity

# Define parameters for the runbook
param (
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory=$true)]
    [string]$WebAppName,

    [Parameter(Mandatory=$true)]
    [ValidateSet("Start", "Stop")]
    [string]$Action
)

# Perform the action on the web app
if ($Action -eq "Start") {
    Write-Output "Starting Web App: $WebAppName in Resource Group: $ResourceGroupName"
    Start-AzWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName
    Write-Output "Web App started successfully."
} elseif ($Action -eq "Stop") {
    Write-Output "Stopping Web App: $WebAppName in Resource Group: $ResourceGroupName"
    Stop-AzWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName
    Write-Output "Web App stopped successfully."
} else {
    Write-Error "Invalid action specified. Use 'Start' or 'Stop'."
}
