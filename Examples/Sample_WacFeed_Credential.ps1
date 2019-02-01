$configurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowDomainUser = $true
            CertificateFile = "C:\certs\wachost.cer"
        }
    )
}

Configuration Sample_WacFeed_Credential
{
    param 
    (
        [Parameter(Mandatory = $true)]
        [pscredential]
        $Credential
    )
    Import-DscResource -ModuleName WindowsAdminCenterDsc

    Node $AllNodes.NodeName
    {
        WacFeed Sample_WacFeed_Credential
        {
            FeedPath = '\\myShare\WacFeed'
            GatewayEndpoint = 'https://wac.myhci.lab'
            Credential = $Credential
            Ensure = 'Present'
        }
    }
}

Sample_WacFeed_Credential -ConfigurationData $configurationData -Credential (Get-Credential)
