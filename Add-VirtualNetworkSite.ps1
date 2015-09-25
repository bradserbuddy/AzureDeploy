[Reflection.Assembly]::LoadWithPartialName("System.Xml.Linq")

function Add-VirtualNetworkSite($virtualNetworkName, $location, $addressSpaceAddressPrefix, $frontEndSubnetAddressPrefix, $backEndSubnetAddressPrefix)
{
    $ns = [System.Xml.Linq.XNamespace]::Get("http://schemas.microsoft.com/ServiceHosting/2011/07/NetworkConfiguration")


    $vNetConfig = Get-AzureVNetConfig 

    if ($vNetConfig -eq $null)
    {
$emptyDocument = @"
<NetworkConfiguration xmlns="$($ns)">
    <VirtualNetworkConfiguration>
    <VirtualNetworkSites>
    </VirtualNetworkSites>
    </VirtualNetworkConfiguration>
</NetworkConfiguration>
"@

        $vNetConfigXml = [System.Xml.Linq.XDocument]::Parse($emptyDocument)
    }
    else
    {
        $vNetConfigXml = [System.Xml.Linq.XDocument]::Parse($vNetConfig.XMLConfiguration)
    }


    $virtualNetworkSite = $vNetConfigXml.Root.Element($ns + "VirtualNetworkConfiguration").Element($ns + "VirtualNetworkSites").Elements($ns + "VirtualNetworkSite") | Where-Object {$_.Attribute("name").Value -eq $virtualNetworkName}

    if ($virtualNetworkSite -eq $null)
    {
# spaces inside 'empty' elements are necessary for parsing to succeed
$emptyVirtualNetworkSite = @"
<VirtualNetworkSite name="$virtualNetworkName" Location="" xmlns="$($ns)">
    <AddressSpace>
        <AddressPrefix> </AddressPrefix>
    </AddressSpace>
    <Subnets>
        <Subnet name="$($frontEndSubnetName)">
        <AddressPrefix> </AddressPrefix>
        </Subnet>
        <Subnet name="$($backEndSubnetName)">
        <AddressPrefix> </AddressPrefix>
        </Subnet>
    </Subnets>
</VirtualNetworkSite>
"@

        $virtualNetworkSiteTemplate = [System.Xml.Linq.XElement]::Parse($emptyVirtualNetworkSite)

        $vNetConfigXml.Root.Element($ns + "VirtualNetworkConfiguration").Element($ns + "VirtualNetworkSites").Add($virtualNetworkSiteTemplate)

        $virtualNetworkSite = $vNetConfigXml.Root.Element($ns + "VirtualNetworkConfiguration").Element($ns + "VirtualNetworkSites").Elements($ns + "VirtualNetworkSite") | Where-Object {$_.Attribute("name").Value -eq $virtualNetworkName}
    }

    $virtualNetworkSite.Attribute("name").Value = $virtualNetworkName
    $virtualNetworkSite.Attribute("Location").Value = $location

    $virtualNetworkSite.Element($ns + "AddressSpace").Element($ns + "AddressPrefix").Value = $addressSpaceAddressPrefix

	HandleSubnet $virtualNetworkSite $ns $frontEndSubnetName $frontEndSubnetAddressPrefix
	HandleSubnet $virtualNetworkSite $ns $backEndSubnetName $backEndSubnetAddressPrefix

    if ($virtualNetworkSite.LastAttribute.Name -eq "xmlns")
    {
        $virtualNetworkSite.LastAttribute.Remove() # TODO: Figure out the right way to add $virtualNetworkSiteTemplate such that removal of this namespace isn't needed
    }

    $tempFileName = [System.IO.Path]::GetTempFileName()

    $vNetConfigXml.ToString() >> $tempFileName

    Set-AzureVNetConfig -ConfigurationPath $tempFileName
}

function HandleSubnet($virtualNetworkSite, $ns, $subnetName, $subnetAddressPrefix)
{
    $subnet = $virtualNetworkSite.Element($ns + "Subnets").Elements($ns + "Subnet") | Where-Object {$_.Attribute("name").Value -eq $subnetName}

    if ($subnet -eq $null)
	{
$emptySubnet = @"
<Subnet name="$($subnetName)">
<AddressPrefix> </AddressPrefix>
</Subnet>
"@
		$subnetTemplate = [System.Xml.Linq.XElement]::Parse($emptySubnet)
        $result = $virtualNetworkSite.Element($ns + "Subnets").Add($subnetTemplate)
        if ($virtualNetworkSite.LastAttribute.Name -eq "xmlns")
        {
            $virtualNetworkSite.LastAttribute.Remove() # TODO: Figure out the right way to add $subnetTemplate such that removal of this namespace isn't needed
        }
	}

    $subnet = $virtualNetworkSite.Element($ns + "Subnets").Elements($ns + "Subnet") | Where-Object {$_.Attribute("name").Value -eq $subnetName}

	$subnet.Element($ns + "AddressPrefix").Value = $subnetAddressPrefix
}