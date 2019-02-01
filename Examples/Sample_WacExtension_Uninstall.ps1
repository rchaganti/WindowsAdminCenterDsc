Configuration Sample_WacExtension_Uninstall
{
    Import-DscResource -ModuleName WindowsAdminCenterDsc

    WacExtension Sample_WacExtension_Uninstall
    {
        ExtensionId = 'msft.sme.containers'
        GatewayEndpoint = 'https://wac.myhci.lab'
        Ensure = 'Absent'
    }
}

Sample_WacExtension_Uninstall
