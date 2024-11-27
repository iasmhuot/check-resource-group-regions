# Azure Resource Group Region Check Script

This PowerShell script helps identify Azure resources that reside in different regions than their corresponding resource groups. It provides detailed reporting with options for filtering and export.

## Prerequisites

* Azure PowerShell module installed and configured
    ```powershell
    Install-Module -Name Az -AllowClobber -Scope CurrentUser
    ```

## Parameters

| Parameter | Description | Default Value |
|-----------|-------------|---------------|
| `-OutputPath` | Path where the CSV report will be saved | `MismatchedResources.csv` |
| `-ExportToCsv` | Switch to enable CSV export | `$false` |
| `-SubscriptionId` | Azure Subscription ID to check | Current context |
| `-ResourceGroupFilter` | Resource group name filter (accepts wildcards) | `*` |
| `-Help` | Show detailed help and examples | N/A |

## Usage Examples

### Basic Usage
```powershell
.\check-resource-group-regions.ps1
```

### View Help and Examples
```powershell
.\check-resource-group-regions.ps1 -Help
```

### Specify Custom Output Path
```powershell
.\check-resource-group-regions.ps1 -OutputPath "C:\Reports\region-check.csv"
```

### Check Specific Subscription
```powershell
.\check-resource-group-regions.ps1 -SubscriptionId "00000000-0000-0000-0000-000000000000"
```

### Filter Specific Resource Groups
```powershell
.\check-resource-group-regions.ps1 -ResourceGroupFilter "prod-*"
```

### Export Results to CSV
```powershell
.\check-resource-group-regions.ps1 -ExportToCsv
```

## Output

The script provides:
- Total number of resource groups checked
- Total number of mismatched resources found
- Detailed table of mismatched resources including:
  - Resource Name
  - Resource Type
  - Resource Location
  - Resource Group Name
  - Resource Group Location

When using `-ExportToCsv`, results are exported to the specified path (default: `MismatchedResources.csv`).

## Error Handling

The script includes error handling for:
- Azure connection failures
- CSV export issues
- Invalid parameter values

## Progress Tracking

The script displays progress as it processes each resource group using `Write-Progress`.

## Notes

- The script uses `CmdletBinding()` for advanced function features
- All parameters include help messages accessible via `Get-Help`
- The script will use the current Azure context if no subscription ID is specified
- Resource group filtering supports wildcard patterns
- Color-coded output for better visibility (Cyan for information, Green for success, Red for errors)

## Additional Help

For detailed help, run:
```powershell
Get-Help .\check-resource-group-regions.ps1 -Detailed
```


2. **Run the Script:**
    * Open a PowerShell window and run the following command:

    ```powershell
    ./check-resource-group-regions.ps1
    ```

## Output

The script will display a table with details of any resources found in regions different from their resource group. If no mismatched resources are found, the script exits silently.

**Optional:**

* The script can be modified to export the results to a CSV file named "MismatchedResources.csv". For this, uncomment the `Export-Csv` line in the script.

## Script Details

* The script connects to your Azure subscription using `Connect-AzAccount`.
* It retrieves all resource groups using `Get-AzResourceGroup`.
* Loops through each resource group and collects its name and location.
* For each resource group, it fetches all resources within it using `Get-AzResource`.
* Compares the region of each resource with the resource group's region.
* If a mismatch is found, it creates a custom object with details of the resource and adds it to an array.
* Finally, it displays the mismatched resources in a table or exits silently if none are found.

## Contributing

This script is intended as a starting point. Feel free to modify it for your specific needs and contribute improvements through pull requests.