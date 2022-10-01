#$Sub = Get-AzContext
$subscription = get-azsubscription
$Month = (Get-Date).AddMonths(-1)
$Month = $Month.tostring("yyyy-MM")
$StartDay="$Month-01"
$EndDay="$Month-30"
$daysoff = 90

$subscription = Get-AzSubscription | ?{$_.Name -notlike "*Corp*"}

foreach ($sub in $subscription) {
$Obj = @()
select-azsubscription -subscriptionid $sub.id
az account set -s $sub.id


$PublicIp = az network public-ip list | convertfrom-json 
$PublicIp = $PublicIp | ?{($_.ipConfiguration -like "") -and ($_.natGateway -like "")}


foreach ($ip in $PublicIp) {

$Consumption = Get-AzConsumptionUsageDetail -StartDate $StartDay -EndDate $EndDay -InstanceName $ip.name
#$Costs = $Consumption.PretaxCost
$CostTotal = ($Consumption | Measure-Object -Property PretaxCost -Sum).sum
#foreach ($Cost in $Costs) { $CostTotal += $Cost}

$obj += New-Object psobject -Property @{
                            Type = "PublicIP"
                            Subscription  = $Sub.Name
                            Name          = $IP.Name
                            ResourceGroup = $Ip.ResourceGroup
                            Region        = $Ip.Location
                            Custo         = $CostTotal }
}

$nics = az network nic list | convertfrom-json
$nics = $nics | ?{$_.virtualMachine -like ""}

foreach ($nic in $nics) {

$Consumption = Get-AzConsumptionUsageDetail -StartDate $StartDay -EndDate $EndDay -InstanceName $nic.name
$CostTotal = ($Consumption | Measure-Object -Property PretaxCost -Sum).sum


$obj += New-Object psobject -Property @{
                            Type = "Nic"
                            Subscription  = $Sub.Name
                            Name          = $Nic.Name
                            ResourceGroup = $Nic.ResourceGroup
                            Region        = $Nic.Location
                            Custo         = $CostTotal }
}

$nsgs = az network nsg list | ConvertFrom-Json
$nsgs = $nsg | ?{($_.networkInterfaces -like "") -and ($_.subnets -like "")}

foreach ($nsg in $nsgs) {

$Consumption = Get-AzConsumptionUsageDetail -StartDate $StartDay -EndDate $EndDay -InstanceName $nsg.name
$CostTotal = ($Consumption | Measure-Object -Property PretaxCost -Sum).sum


$obj += New-Object psobject -Property @{
                            Type = "NSG"
                            Subscription  = $Sub.Name
                            Name          = $Nsg.Name
                            ResourceGroup = $Nsg.ResourceGroup
                            Region        = $Nsg.Location
                            Custo         = $CostTotal }
}

$disks = az disk list | ConvertFrom-Json
$disks = $disks | ?{$_.Managedby -like ""}

foreach ($disk in $disks) {

$Consumption = Get-AzConsumptionUsageDetail -StartDate $StartDay -EndDate $EndDay -InstanceName $disk.name
$CostTotal = ($Consumption | Measure-Object -Property PretaxCost -Sum).sum


$obj += New-Object psobject -Property @{
                            Type = "Disk"
                            Subscription  = $Sub.Name
                            Name          = $Disk.Name
                            ResourceGroup = $Disk.ResourceGroup
                            Region        = $Disk.Location
                            Custo         = $CostTotal }
}

foreach ($storageAccount in Get-AzStorageAccount) {
#$networkRule = $false
$storageAccountName = $storageAccount.StorageAccountName
$resourceGroupName = $storageAccount.ResourceGroupName

$stmonitor = az monitor metrics list --resource $storageAccount.id --metric "Ingress" --interval 1d --start-time (Get-date).AddDays(-$daysoff) --end-time (Get-Date) --aggregation Total
$stmonitor = $stmonitor | ConvertFrom-Json
$sum = $stmonitor.value.timeseries.data.total
$sum = ($sum |Measure-Object -sum ).sum

if ($sum -lt 100) {

$Consumption = Get-AzConsumptionUsageDetail -StartDate $StartDay -EndDate $EndDay -InstanceName $storageAccountName
$CostTotal = ($Consumption | Measure-Object -Property PretaxCost -Sum).sum


$obj += New-Object psobject -Property @{
                            Type = "StorageAccount"
                            Subscription  = $Sub.Name
                            Name          = $storageAccountName
                            ResourceGroup = $resourceGroupName
                            Region        = $storageAccount.PrimaryLocation
                            Custo         = $CostTotal }

}
}

$loadbalancer = Get-AzLoadBalancer | ?{$_.sku.Name -ne "Basic"}


foreach ($lb in $loadbalancer) {

$lbmonitor = az monitor metrics list --resource $lb.id --metric "PacketCount" --interval 1d --start-time (Get-date).AddDays(-$daysoff) --end-time (Get-Date) --aggregation Total
$lbmonitor = $lbmonitor | ConvertFrom-Json
$sum = $lbmonitor.value.timeseries.data.total
$sum = ($sum |Measure-Object -sum ).sum
$sum = $sum/1MB

if ($sum -lt 100) {


$Consumption = Get-AzConsumptionUsageDetail -StartDate $StartDay -EndDate $EndDay -InstanceName $lb.name
$CostTotal = ($Consumption | Measure-Object -Property PretaxCost -Sum).sum


$obj += New-Object psobject -Property @{
                            Type = "LoadBalance"
                            Subscription  = $Sub.Name
                            Name          = $lb.Name
                            ResourceGroup = $lb.ResourceGroupName
                            Region        = $lb.Location
                            Custo         = $CostTotal }
}
}

$allvmss = az vmss list | ConvertFrom-Json 

foreach ($vmss in $allvmss) {

$vmssinstance = az vmss list-instances -n $vmss.name -g $vmss.Resourcegroup

$vmsslb = az vmss show -n $vmss.name -g $vmss.Resourcegroup --query 'virtualMachineProfile.networkProfile.networkInterfaceConfigurations[*].ipConfigurations[*].loadBalancerBackendAddressPools[*].id | []'

if (($vmssinstance -eq $null) -and ($vmsslb -eq '[]')) {

$Consumption = Get-AzConsumptionUsageDetail -StartDate $StartDay -EndDate $EndDay -InstanceName $vmss.name
$CostTotal = ($Consumption | Measure-Object -Property PretaxCost -Sum).sum



$obj += New-Object psobject -Property @{
                            Type = "Vmss"
                            Subscription  = $Sub.Name
                            Name          = $Vmss.Name
                            ResourceGroup = $Vmss.ResourceGroupName
                            Region        = $Vmss.Location
                            Custo         = $CostTotal }

}
}


$vms = Get-AzVM

foreach ($vm in $vms) {

$vmmonitor = az vm monitor metrics tail -n $vm.name -g $vm.resourcegroupname --metric "Network Out Total" --interval 1d --start-time (Get-date).AddDays(-$daysoff) --end-time (Get-Date) --aggregation Total
$vmmonitor = $vmmonitor | ConvertFrom-Json
$sum = $vmmonitor.value.timeseries.data.total
$sum = ($sum |Measure-Object -sum ).sum
$sum = $sum/1GB

if ($sum -lt 3) {

$Consumption = Get-AzConsumptionUsageDetail -StartDate $StartDay -EndDate $EndDay -InstanceName $vm.name
$CostTotal = ($Consumption | Measure-Object -Property PretaxCost -Sum).sum


$obj += New-Object psobject -Property @{
                            Type = "VirtualMachine"
                            Subscription  = $Sub.Name
                            Name          = $Vm.Name
                            ResourceGroup = $Vm.ResourceGroupName
                            Region        = $Vm.Location
                            Custo         = $CostTotal }}
}

$containerregistry = Get-AzContainerRegistry

foreach ($cr in $containerregistry) {

#buglist = Verificar errorMessage
$crmonitor = az monitor metrics list --resource $cr.id --metric "TotalPushCount" --interval 1d --start-time (Get-date).AddDays(-$daysoff) --end-time (Get-Date) --aggregation Total
$crmonitor = $crmonitor | ConvertFrom-Json
$sum = $crmonitor.value.timeseries.data.total
$sum = ($sum |Measure-Object -sum ).sum
$sum = $sum/1GB

if ($sum -lt 1) {

$Consumption = Get-AzConsumptionUsageDetail -StartDate $StartDay -EndDate $EndDay -InstanceName $cr.name
$CostTotal = ($Consumption | Measure-Object -Property PretaxCost -Sum).sum


$obj += New-Object psobject -Property @{
                            Type = "ContainerRegistry"
                            Subscription  = $Sub.Name
                            Name          = $cr.Name
                            ResourceGroup = $cr.ResourceGroupName
                            Region        = $cr.Location
                            Custo         = $CostTotal }}
}

$akslist = az aks list | ConvertFrom-Json

foreach ($aks in $akslist) {

$aksmonitor = az monitor metrics list --resource $aks.id --metric "node_cpu_usage_percentage" --interval 12h --start-time (Get-date).AddDays(-$daysoff) --end-time (Get-Date) --aggregation Average
$aksmonitor = $aksmonitor | ConvertFrom-Json
$sum = $aksmonitor.value.timeseries.data.average
$sum = ($sum |Measure-Object -sum ).sum

if ($sum -lt 1) {

$Consumption = Get-AzConsumptionUsageDetail -StartDate $StartDay -EndDate $EndDay -InstanceName $aks.name
$CostTotal = ($Consumption | Measure-Object -Property PretaxCost -Sum).sum


$obj += New-Object psobject -Property @{
                            Type = "AKS"
                            Subscription  = $Sub.Name
                            Name          = $aks.Name
                            ResourceGroup = $aksmonitor.value.resourcegroup
                            Region        = $aks.Location
                            Custo         = $CostTotal }

}
}

$appgws = Get-AzApplicationGateway

foreach ($appgw in $appgws) {

$appgwmonitor = az monitor metrics list --resource $appgw.id --metric "TotalRequests" --interval 12h --start-time (Get-date).AddDays(-$daysoff) --end-time (Get-Date) --aggregation Total
$appgwmonitor = $appgwmonitor | ConvertFrom-Json
$sum = $appgwmonitor.value.timeseries.data.total
$sum = ($sum |Measure-Object -sum ).sum

if ($sum -lt 1) {

$Consumption = Get-AzConsumptionUsageDetail -StartDate $StartDay -EndDate $EndDay -InstanceName $appgw.name
$CostTotal = ($Consumption | Measure-Object -Property PretaxCost -Sum).sum


$obj += New-Object psobject -Property @{
                            Type = "Aplication Gateway"
                            Subscription  = $Sub.Name
                            Name          = $appgw.Name
                            ResourceGroup = $appgwmonitor.value.resourcegroup
                            Region        = $appgw.Location
                            Custo         = $CostTotal }

}
}

$tmprofiles = az network traffic-manager profile list | ConvertFrom-Json

foreach ($tm in $tmprofiles) {

$tmmonitor = az monitor metrics list --resource $tm.id --metric "ProbeAgentCurrentEndpointStateByProfileResourceId" --start-time (Get-date).AddDays(-$daysoff) --end-time (Get-Date) --aggregation Average
$tmmonitor = $tmmonitor | ConvertFrom-Json
$sum = $tmmonitor.value.timeseries.data.average
$sum = ($sum |Measure-Object -sum ).sum

if ($sum -lt 1) {

$Consumption = Get-AzConsumptionUsageDetail -StartDate $StartDay -EndDate $EndDay -InstanceName $tm.name
$CostTotal = ($Consumption | Measure-Object -Property PretaxCost -Sum).sum


$obj += New-Object psobject -Property @{
                            Type = "Traffic Manager"
                            Subscription  = $Sub.Name
                            Name          = $tm.Name
                            ResourceGroup = $tm.value.resourcegroup
                            Region        = $tm.Location
                            Custo         = $CostTotal }

}
}

$froontdoors = az network  front-door list | ConvertFrom-Json

foreach ($fd in $froontdoors) {

$fdmonitor = az monitor metrics list --resource $fd.id --metric "BackEndRequestCount" --interval 1d --start-time (Get-date).AddDays(-$daysoff) --end-time (Get-Date) --aggregation Total
$fdmonitor = $fdmonitor | ConvertFrom-Json
$sum = $fdmonitor.value.timeseries.data.total
$sum = ($sum |Measure-Object -sum ).sum

if ($sum -lt 1) {

$Consumption = Get-AzConsumptionUsageDetail -StartDate $StartDay -EndDate $EndDay -InstanceName $fd.name
$CostTotal = ($Consumption | Measure-Object -Property PretaxCost -Sum).sum


$obj += New-Object psobject -Property @{
                            Type = "Front Door"
                            Subscription  = $Sub.Name
                            Name          = $fd.Name
                            ResourceGroup = $fd.value.resourcegroup
                            Region        = $fd.Location
                            Custo         = $CostTotal }

}
}

$Subname = $sub | select -ExpandProperty name

$obj | select Type,Name,ResourceGroup,Region,Subscription,Custo | Export-Csv "C:\Temp\resources_$sub.name.csv"
}
