Configuration Sample_WacFeed_Default
{
    Import-DscResource -ModuleName WindowsAdminCenterDsc

    WacFeed Sample_WacFeed_Default
    {
        FeedPath = '\\myShare\WacFeed'
        GatewayEndpoint = 'https://wac.myhci.lab'
        Ensure = 'Present'
    }
}

Sample_WacFeed_Default
