Configuration Sample_WacExtension_Defaults
{
    Import-DscResource -ModuleName WindowsAdminCenterDsc

    WacExtension Sample_WacExtension_Defaults
    {
        ExtensionId = 'msft.sme.containers'
        GatewayEndpoint = 'https://wac.myhci.lab'
        Ensure = 'Present'
    }
}

Sample_WacExtension_Defaults
