#  Stop any running Cosmos DB Emulator processes
Write-Host "Stopping any running Cosmos DB Emulator instances..."
Get-Process -Name "Microsoft.Azure.Cosmos.Emulator" -ErrorAction SilentlyContinue | Stop-Process -Force

#  Remove old data directories
Write-Host "Removing existing Cosmos DB Emulator data folders..."
$paths = @(
    "$env:LOCALAPPDATA\CosmosDBEmulator",
    "$env:USERPROFILE\.azure-cosmosdb-emulator",
    "C:\ProgramData\Microsoft\Azure Cosmos DB Emulator",
    "C:\CosmosMongoDB"
)

foreach ($path in $paths) {
    if (Test-Path $path) {
        try {
            Remove-Item $path -Recurse -Force -ErrorAction Stop
            Write-Host "Deleted: $path"
        } catch {
            Write-Warning "Failed to delete: $path - $_"
        }
    } else {
        Write-Host "Not found (skipping): $path"
    }
}

# Start Emulator in MongoDB API mode
$emulatorPath = "C:\Program Files\Azure Cosmos DB Emulator\CosmosDB.Emulator.exe"
$dataPath = "C:\CosmosMongoDB"

if (Test-Path $emulatorPath) {
    Write-Host "`nStarting Cosmos DB Emulator in MongoDB API mode..."
    Start-Process -FilePath $emulatorPath -ArgumentList "/EnableMongoDbEndpoint /DataPath=`"$dataPath`"" -Verb RunAs
} else {
    Write-Error "Emulator executable not found at $emulatorPath. Is it installed?"
}
