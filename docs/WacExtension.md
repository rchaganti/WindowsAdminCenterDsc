WacExtension DSC Resource

The WacExtension DSC resource can be used to add or remove WAC extensions.

> **Note**: This resource requires WAC version 1812 or above.

![](https://i.imgur.com/te8sTuB.png)

| Property        | Description                                                  |
| --------------- | ------------------------------------------------------------ |
| ExtensionId     | Specifies the ID of the Windows Admin Center extension.      |
| GatewayEndpoint | Specifies the URL at which WAC is available. For example, https://wac.myhci.lab |
| Credential      | Specifies the credentials to authenticate to WAC.            |
| FeedPath        | Specifies the WAC extension feed path.                       |
| Ensure          | Specifies if WAC extension should be added or removed. The valid values are Present and Absent. Default is Present. |

## Example 1

```powershell
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
```

The above example installs a WAC extension.

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
```

The above example installs a WAC extension and uses custom credentials for WAC authentication.

## Example 3

```powershell
Configuration Sample_WacExtension_CustomFeed
{
    Import-DscResource -ModuleName WindowsAdminCenterDsc

    WacExtension Sample_WacExtension_CustomFeed
    {
        ExtensionId = 'msft.sme.containers'
        FeedPath = '\\myShare\Wac'
        GatewayEndpoint = 'https://wac.myhci.lab'
        Ensure = 'Present'
    }
}

Sample_WacExtension_CustomFeed
```

The above example installs a WAC extension from a specified WAC extension feed. If the feed does not exist in WAC, it gets added.

## Example 4

```powershell
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
```

The above example uninstalls a WAC extension.

