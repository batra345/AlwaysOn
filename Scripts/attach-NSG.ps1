<#
.SYNOPSIS
  This script can attach NSG to VM.

.DESCRIPTION
  This script can attach NSG to VM. 

.NOTES
  Version:        1.0
  Author:         Abhishek Roy
  Creation Date:  26.02.2020
#>

[CmdletBinding()]
param
(
    [Parameter(Mandatory=$true)]
    [System.String]$ParametersFile
    
)

$objParametersFile = Get-Content -Path $ParametersFile | ConvertFrom-Json
[System.String] $ResourceGroupName = $objParametersFile.parameters.RGname[0].value
[System.String] $NICname = $objParametersFile.parameters.NICname[0].value
[System.String] $NSGname = $objParametersFile.parameters.NSGname[0].value

$nic = Get-AzNetworkInterface -ResourceGroupName $ResourceGroupName -Name $NICname
$nsg = Get-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Name $NSGname
$nic.NetworkSecurityGroup = $nsg
$nic | Set-AzNetworkInterface
