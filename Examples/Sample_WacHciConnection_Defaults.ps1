$configurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowDomainUser = $true
            CertificateFile = "C:\certs\wachost.cer"
        }
    )
}

Configuration Sample_WacHciConnection_Defaults
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
        WacHciConnection Sample_WacHciConnection_Defaults
        {
            HciClusterName = 'hcicluster.myhci.lab'
            GatewayEndpoint = 'https://wac.myhci.lab'
            Credential = $Credential
            Ensure = 'Present'
        }
    }
}

Sample_WacHciConnection_Defaults -ConfigurationData $configurationData -Credential (Get-Credential)
