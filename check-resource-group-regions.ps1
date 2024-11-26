# Login to Azure
Connect-AzAccount

# Get all resource groups in the subscription
$resourceGroups = Get-AzResourceGroup

# Initialize an array to store mismatched resources
$mismatchedResources = @()

# Loop through each resource group
foreach ($rg in $resourceGroups) {
    $resourceGroupName = $rg.ResourceGroupName
    $resourceGroupRegion = $rg.Location

    # Get all resources in the resource group
    $resources = Get-AzResource -ResourceGroupName $resourceGroupName

    foreach ($resource in $resources) {
        $resourceRegion = $resource.Location

        # Compare the region of the resource group with the resource's region
        if ($resourceRegion -ne $resourceGroupRegion) {
            # Add to the list of mismatched resources
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

# Output mismatched resources
if ($mismatchedResources.Count -gt 0) {
    $mismatchedResources | Format-Table -AutoSize
} else {
    Write-Host "No resources found in different regions from their resource groups."
}

# Optional: Export results to a CSV file
$mismatchedResources | Export-Csv -Path "MismatchedResources.csv" -NoTypeInformation -Force
