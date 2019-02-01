Configuration Sample_WacSetup_Uninstall
{
    Import-DscResource -ModuleName WindowsAdminCenterDsc

    WacSetup Sample_WacSetup_Uninstall
    {
        InstallerPath = 'C:\Wac\WindowsAdminCenterPreview1812.msi'
        Ensure = 'Absent'
    }
}

Sample_WacSetup_Uninstall
