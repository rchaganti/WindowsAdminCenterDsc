Configuration Sample_WacSetup_SelfSignedCert
{
    Import-DscResource -ModuleName WindowsAdminCenterDsc

    WacSetup Sample_WacSetup_SelfSignedCert
    {
        InstallerPath = 'C:\Wac\WindowsAdminCenterPreview1812.msi'
        Ensure = 'Present'
    }
}

Sample_WacSetup_SelfSignedCert
