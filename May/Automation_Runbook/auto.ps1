# Azure Automation is a new service in Azure that allows you to automate your Azure management tasks and to orchestrate actions across external systems from right within Azure. 
# It is built on PowerShell Workflow
# Create automation account
# When you run this script, you can link to a schedule, you will be requested to add a input parameters.
# note before running this script, remove all the hash tags in the script and run it in Azure Automation account.
# This script is an example of how to create a runbook in Azure Automation that starts or stops an Azure Web App.

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

# Import the required Azure module
Import-Module Az.Accounts
Import-Module Az.Websites

# Authenticate with Azure
Connect-AzAccount -Identity

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
