# WacFeed DSC Resource

The WacFeed DSC resource can be used to add or remove extension feeds.

> **Note**: This resource requires WAC version 1812 or above.

![](https://i.imgur.com/qn1D7FF.png)

| Property        | Description                                                  |
| --------------- | ------------------------------------------------------------ |
| FeedPath        | Specifies the path to Windows Admin Center extension feed.   |
| GatewayEndpoint | Specifies the URL at which WAC is available. For example, https://wac.myhci.lab |
| Credential      | Specifies the credentials to authenticate to WAC.            |
| Ensure          | Specifies if WAC feed should be added or removed. The valid values are Present and Absent. Default is Present. |

## Example 1

```powershell
Configuration Sample_WacFeed_Default
{
    Import-DscResource -ModuleName WindowsAdminCenterDsc

    WacFeed Sample_WacFeed_Default
    {
        FeedPath = '\\myShare\WacFeed'
        GatewayEndpoint = 'https://wac.myhci.lab'
        Ensure = 'Present'
    }
}

Sample_WacFeed_Default
```

The above example add a WAC extension feed.

## Example 2

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

Configuration Sample_WacFeed_Credential
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
        WacFeed Sample_WacFeed_Credential
        {
            FeedPath = '\\myShare\WacFeed'
            GatewayEndpoint = 'https://wac.myhci.lab'
            Credential = $Credential
            Ensure = 'Present'
        }
    }
}

Sample_WacFeed_Credential -ConfigurationData $configurationData -Credential (Get-Credential)
```

The above example adds a WAC extension and uses custom credentials for WAC authentication.

## Example 3

```powershell
Configuration Sample_WacFeed_Remove
{
    Import-DscResource -ModuleName WindowsAdminCenterDsc

    WacFeed Sample_WacFeed_Remove
    {
        FeedPath = '\\myShare\WacFeed'
        GatewayEndpoint = 'https://wac.myhci.lab'
        Ensure = 'Absent'
    }
}

Sample_WacFeed_Remove
```

The above example removes a WAC extension feed.

