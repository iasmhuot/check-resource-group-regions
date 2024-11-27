[CmdletBinding()]
param(
    [Parameter(
        Position = 0,
        HelpMessage = "Path where the CSV report will be saved"
    )]
    [ValidateNotNullOrEmpty()]
    [string]$OutputPath = "MismatchedResources.csv",

    [Parameter(
        HelpMessage = "Switch to enable/disable CSV export"
    )]
    [switch]$ExportToCsv = $false,

    [Parameter(
        HelpMessage = "Azure Subscription ID to check. If not specified, uses current context"
    )]
    [string]$SubscriptionId,

    [Parameter(
        HelpMessage = "Optional resource group name filter (accepts wildcards)"
    )]
    [string]$ResourceGroupFilter = "*",

    [Parameter(
        HelpMessage = "Show detailed help and examples"
    )]
    [switch]$Help
)

$scriptBanner = @"
Azure Resource Group Region Check Script
======================================
This script identifies resources that reside in different regions 
than their containing resource groups.

"@

$exampleBlock = @"
Parameters:
-----------
-OutputPath         : Path where the CSV report will be saved (default: MismatchedResources.csv)
-ExportToCsv        : Switch to enable CSV export (default: false)
-SubscriptionId     : Azure Subscription ID to check (optional)
-ResourceGroupFilter: Resource group name filter, accepts wildcards (default: *)
-Help           : Show this help message

Example Usage:
-------------
# Basic usage
.\check-resource-group-regions.ps1

# Specify custom output path
.\check-resource-group-regions.ps1 -OutputPath "C:\Reports\region-check.csv"

# Check specific subscription
.\check-resource-group-regions.ps1 -SubscriptionId "00000000-0000-0000-0000-000000000000"

# Filter specific resource groups
.\check-resource-group-regions.ps1 -ResourceGroupFilter "prod-*"

# Export results to CSV
.\check-resource-group-regions.ps1 -ExportToCsv

For detailed help, run:
Get-Help .\check-resource-group-regions.ps1 -Detailed
"@

if ($Help) {
    Write-Host $scriptBanner -ForegroundColor Cyan
    Write-Host $exampleBlock -ForegroundColor Yellow
    return
} else {
    Write-Host $scriptBanner -ForegroundColor Cyan
}

try {
    if ($SubscriptionId) {
        Connect-AzAccount -SubscriptionId $SubscriptionId
    } else {
        Connect-AzAccount
    }
} catch {
    Write-Error "Failed to connect to Azure: $_"
    exit 1
}

$resourceGroups = Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -like $ResourceGroupFilter }

$mismatchedResources = @()

foreach ($rg in $resourceGroups) {
    Write-Progress -Activity "Checking resources" -Status "Processing resource group $($rg.ResourceGroupName)"

    $resourceGroupName = $rg.ResourceGroupName
    $resourceGroupRegion = $rg.Location

    $resources = Get-AzResource -ResourceGroupName $resourceGroupName

    foreach ($resource in $resources) {
        $resourceRegion = $resource.Location

        if ($resourceRegion -ne $resourceGroupRegion) {
            $mismatchedResources += [PSCustomObject]@{
                ResourceName      = $resource.Name
                ResourceType      = $resource.ResourceType
                ResourceLocation  = $resourceRegion
                ResourceGroupName = $resourceGroupName
                ResourceGroupLocation = $resourceGroupRegion
            }
        }
    }
}

if ($mismatchedResources.Count -gt 0) {
    Write-Host "Total Resource Groups Checked: $($resourceGroups.Count)" -ForegroundColor Cyan
    Write-Host "Total Mismatched Resources Found: $($mismatchedResources.Count)" -ForegroundColor Cyan
    $mismatchedResources | Format-Table -AutoSize

    if ($ExportToCsv) {
        try {
            $mismatchedResources | Export-Csv -Path $OutputPath -NoTypeInformation -Force
            Write-Host "Results exported to: $OutputPath" -ForegroundColor Green
        } catch {
            Write-Error "Failed to export CSV: $_"
        }
    }
} else {
    Write-Host "No mismatched resources found." -ForegroundColor Green
}
