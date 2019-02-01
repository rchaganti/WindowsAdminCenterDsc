Configuration Sample_WacSetup_CustomCert
{
    Import-DscResource -ModuleName WindowsAdminCenterDsc

    WacSetup Sample_WacSetup_CustomCert
    {
        InstallerPath = 'C:\Wac\WindowsAdminCenterPreview1812.msi'
        CertificateThumbprint = '8E13E03E36EF4EAB6BD72589FC85FAA8D3E3EE41'
        Ensure = 'Present'
    }
}

Sample_WacSetup_CustomCert
