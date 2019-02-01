# WacServerConnection DSC Resource

The WacHciConnection DSC resource can be used to add Windows Hyper-Converged Infrastructure for management in WAC. This extension does not support removing HCI connections yet.

> **Note**: This resource requires WAC version 1812 or above.

![](https://i.imgur.com/6XOwoWx.png)

| Property        | Description                                                  |
| --------------- | ------------------------------------------------------------ |
| HciClusterName  | Specifies the name of the HCI cluster that needs to be added to Windows Admin Center for management. |
| GatewayEndpoint | Specifies the URL at which WAC is available. For example, https://wac.myhci.lab |
| Credential      | Specifies the credentials to authenticate to WAC. This is mandatory. |
| Ensure          | Specifies if a HCI Clusterconnection in WAC should be added or removed. The valid values are Present and Absent. Default is Present. |

## Example 1

```powershell
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
```

The above example adds HCI Cluster to WAC for management. Providing Credentials is mandatory since DSC runs in SYSTEM context.

