$configurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowDomainUser = $true
            CertificateFile = "C:\certs\wachost.cer"
        }
    )
}

Configuration Sample_WacExtension_Credential
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
        WacExtension Sample_WacExtension_Credential
        {
            ExtensionId = 'msft.sme.containers'
            GatewayEndpoint = 'https://wac.myhci.lab'
            Credential = $Credential
            Ensure = 'Present'
        }
    }
}

Sample_WacExtension_Credential -ConfigurationData $configurationData -Credential (Get-Credential)
