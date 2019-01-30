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
        $ProductId = '{7019BE31-3389-46FB-A077-B813D53C1266}',
        
        [Parameter()]
        [String]
        [ValidateSet('Present','Absent')]
        $Ensure = 'Present'
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    if ($Ensure -eq 'Present')
    {
        #If a custom certificate thumbprint is provided, it must exist on the local system.
        if ($CertificateThumbprint -ne 'SelfSigned')
        {
            $cert = (Get-ChildItem -Path Cert:\LocalMachine\My).Where({$_.Thumbprint -eq $CertificateThumbprint})
            if ($cert)
            {
                if (-not ($cert.EnhancedKeyUsageList.FriendlyName -eq 'Server Authentiation'))
                {
                    throw "Certificate represented by $CertificateThumbprint is not a valid certificate for the deployment."
                }
                else
                {
                    $arguments = "/qn /l*v c:\windows\temp\wac.install.log SME_PORT=$Port SME_THUMBPRINT=$CertificateThumbprint"    
                }
            }
            else
            {
                throw "$CertificateThumbprint does not seem to be valid."
            }
        }
        else
        {
            $arguments = "/qn /l*v c:\windows\temp\wac.install.log SME_PORT=$Port SSL_CERTIFICATE_OPTION=generate"    
        }
    }
    else
    {
        #MSI uninstall arguments
        $arguments = ''
    }
  
    Node localhost
    {
        Package 'WacInstaller'
        {
            ProductId     = $ProductId
            InstallerPath = $InstallerPath
            Arguments     = $arguments
            Ensure        = $Ensure
        }
    }    
}
