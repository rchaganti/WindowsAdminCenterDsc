Configuration Sample_WacExtension_CustomFeed
{
    Import-DscResource -ModuleName WindowsAdminCenterDsc

    WacExtension Sample_WacExtension_CustomFeed
    {
        ExtensionId = 'msft.sme.containers'
        FeedPath = '\\myShare\Wac'
        GatewayEndpoint = 'https://wac.myhci.lab'
        Ensure = 'Present'
    }
}

Sample_WacExtension_CustomFeed
