#region localizeddata
if (Test-Path "${PSScriptRoot}\${PSUICulture}")
{
    Import-LocalizedData -BindingVariable LocalizedData -filename WacSetup.psd1 `
                         -BaseDirectory "${PSScriptRoot}\${PSUICulture}"
} 
else
{
    #fallback to en-US
    Import-LocalizedData -BindingVariable LocalizedData -filename WacSetup.psd1 `
                         -BaseDirectory "${PSScriptRoot}\en-US"
}
#endregion

Configuration WacSetup
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [String]
        $InstallerPath,

        [Parameter()]
        [Int]
        $Port = 443,
        
        [Parameter()]
        [String]
        $CertificateThumbprint = 'SelfSigned',

        [Parameter()]
        [String]
        $ProductId = '{738640D5-FED5-4232-91C3-176903ADFF94}',
        
        [Parameter()]
        [String]
        [ValidateSet('Present','Absent')]
        $Ensure = 'Present'
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message $localizedData.InstallWAC

        #If a custom certificate thumbprint is provided, it must exist on the local system.
        if ($CertificateThumbprint -ne 'SelfSigned')
        {
            Write-Verbose -Message ($localizedData.CheckThumbprint -f $CertificateThumbprint)
            $cert = (Get-ChildItem -Path Cert:\LocalMachine\My).Where({$_.Thumbprint -eq $CertificateThumbprint})
            if ($cert)
            {
                if (-not ($cert.EnhancedKeyUsageList.FriendlyName -eq 'Server Authentiation'))
                {
                    throw ($localizedData.InvalidCert -f {0})
                }
                else
                {
                    Write-Verbose -Message ($localizedData.UsingCert -f $CertificateThumbprint)
                    $arguments = "/qn /l*v c:\windows\temp\wac.install.log SME_PORT=$Port SME_THUMBPRINT=$CertificateThumbprint"
                }
            }
            else
            {
                throw ($localizedData.NoCertFound -f $CertificateThumbprint)
            }
        }
        else
        {
            Write-Verbose -Message $localizedData.UsingSelfSigned
            $arguments = "/qn /l*v c:\windows\temp\wac.install.log SME_PORT=$Port SSL_CERTIFICATE_OPTION=generate"    
        }
    }
    else
    {
        Write-Verbose -Message $localizedData.UninstallWAC
        $arguments = '/l*v c:\windows\temp\wac.uninstall.log'
    }
  
    Node localhost
    {
        Package 'WacInstaller'
        {
            Name          = 'Windows Admin Center'
            ProductId     = $ProductId
            Path          = $InstallerPath
            Arguments     = $arguments
            Ensure        = $Ensure
        }
    }    
}
