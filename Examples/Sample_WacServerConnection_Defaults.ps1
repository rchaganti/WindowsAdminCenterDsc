$configurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowDomainUser = $true
            CertificateFile = "C:\certs\wachost.cer"
        }
    )
}

Configuration Sample_WacServerConnection_Defaults
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
        WacServerConnection Sample_WacServerConnection_Defaults
        {
            ServerName = 'cluster.myhci.lab'
            GatewayEndpoint = 'https://wac.myhci.lab'
            Credential = $Credential
            Ensure = 'Present'
        }
    }
}

Sample_WacServerConnection_Defaults -ConfigurationData $configurationData -Credential (Get-Credential)
