# Prerequisits
#   Assign contributor role to automation account in resource group IAM
#   Publish & then add a schedule under runbook's Resources

Connect-AzAccount -Identity

Set-AzContext -Subscription 'Azure subscription 1'

$rgName = "creekside"
$vmName = "azure-tok"
$nicName = "nic-vyos-wan"
$pipName = "pip-azure-tok"
$vnetName = "azure-tok"
$vsubnetName = "dmz"
$ipconfigName = "ipconfig1"
$location = "Japan East"

##unattach public IP on nic
$nic = Get-AzNetworkInterface -Name $nicName -ResourceGroupName $rgName
$nic.IpConfigurations.PublicIpAddress.Id=""
$nic | Set-AzNetworkInterface

# remove existing public IP
Remove-AzPublicIpAddress -Name $pipName -ResourceGroupName  $rgName -force

# create a new public IP
$ip = @{  
    Name = $pipName 
    ResourceGroupName = $rgName  
    Location = $location  
    Sku = 'Standard'  
    AllocationMethod = 'Static'  
    IpAddressVersion = 'IPv4'  
} 

$newPublicIp = New-AzPublicIpAddress @ip 

$vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName  
$subnet = Get-AzVirtualNetworkSubnetConfig -Name $vsubnetName -VirtualNetwork $vnet  

$nic | Set-AzNetworkInterfaceIpConfig -Name $ipconfigName -PublicIPAddress $newPublicIp -Subnet $subnet  
$nic | Set-AzNetworkInterface

# restart VM after new Public IP attached
Restart-AzVM -ResourceGroupName $rgName -Name $vmName