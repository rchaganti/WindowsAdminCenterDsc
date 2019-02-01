Configuration Sample_WacFeed_Remove
{
    Import-DscResource -ModuleName WindowsAdminCenterDsc

    WacFeed Sample_WacFeed_Remove
    {
        FeedPath = '\\myShare\WacFeed'
        GatewayEndpoint = 'https://wac.myhci.lab'
        Ensure = 'Absent'
    }
}

Sample_WacFeed_Remove
