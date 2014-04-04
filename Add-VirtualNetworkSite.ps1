[Reflection.Assembly]::LoadWithPartialName("System.Xml.Linq")

function Add-VirtualNetworkSite($virtualNetworkName, $affinityGroupName, $addressPrefix, $frontSubnetAddressPrefix, $backSubnetAddressPrefix)
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
<VirtualNetworkSite name="$virtualNetworkName" AffinityGroup="" xmlns="$($ns)">
    <AddressSpace>
        <AddressPrefix> </AddressPrefix>
    </AddressSpace>
    <Subnets>
        <Subnet name="Front">
        <AddressPrefix> </AddressPrefix>
        </Subnet>
        <Subnet name="Back">
        <AddressPrefix> </AddressPrefix>
        </Subnet>
    </Subnets>
</VirtualNetworkSite>
"@

        $virtualNetworkSiteTemplate = [System.Xml.Linq.XElement]::Parse($emptyVirtualNetworkSite)

        $vNetConfigXml.Root.Element($ns + "VirtualNetworkConfiguration").Element($ns + "VirtualNetworkSites").Add($virtualNetworkSiteTemplate);

        $virtualNetworkSite = $vNetConfigXml.Root.Element($ns + "VirtualNetworkConfiguration").Element($ns + "VirtualNetworkSites").Elements($ns + "VirtualNetworkSite") | Where-Object {$_.Attribute("name").Value -eq $virtualNetworkName}
    }


    $virtualNetworkSite.Attribute("name").Value = $virtualNetworkName
    $virtualNetworkSite.Attribute("AffinityGroup").Value = $affinityGroupName

    $virtualNetworkSite.Element($ns + "AddressSpace").Element($ns + "AddressPrefix").Value = $addressPrefix

    $frontSubnet = $virtualNetworkSite.Element($ns + "Subnets").Elements($ns + "Subnet") | Where-Object {$_.Attribute("name").Value -eq "Front"}
    $frontSubnet.Element($ns + "AddressPrefix").Value = $frontSubnetAddressPrefix

    $backSubnet = $virtualNetworkSite.Element($ns + "Subnets").Elements($ns + "Subnet") | Where-Object {$_.Attribute("name").Value -eq "Back"}
    $backSubnet.Element($ns + "AddressPrefix").Value = $backSubnetAddressPrefix

    $virtualNetworkSite.LastAttribute.Remove() # TODO: Figure out the right way to add $virtualNetworkSiteTemplate such that removal of this namespace isn't needed

    $tempFileName = [System.IO.Path]::GetTempFileName()

    $vNetConfigXml.ToString() >> $tempFileName

    Set-AzureVNetConfig -ConfigurationPath $tempFileName
}