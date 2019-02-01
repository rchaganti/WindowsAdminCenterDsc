# WacSetup DSC Resource

The WacSetup DSC resource is a composite resource that can be used to install or uninstall Windows Admin Center.

> **Note**: This resource can be used with any Windows Admin Center version. However, the rest of the resources in this module require WAC version 1812 or above.

![](https://i.imgur.com/86JukDS.png)

| Property              | Description                                                  |
| --------------------- | ------------------------------------------------------------ |
| InstallerPath         | Specifies the path to Windows Admin Center MSI file. This needs to be a local path. |
| Port                  | Specifies the port at which WAC will be configured. Default value is 443. |
| CertificateThumbprint | Specifies the certificate thumbprint for the WAC webserver instance. Default is to generate a self-signed certificate. |
| ProductId             | Specifies the product ID needed to install WAC. This is not mandatory. |
| Ensure                | Specifies if WAC should be installed or uninstalled. The valid values are Present and Absent. Default is Present. |

## Example 1

```powershell
Configuration Sample_WacSetup_SelfSignedCert
{
    Import-DscResource -ModuleName WindowsAdminCenterDsc
    WacSetup Sample_WacSetup_SelfSignedCert
    {
    	InstallerPath = 'C:\Wac\WindowsAdminCenterPreview1812.msi'
    	Ensure = 'Present''
    }
}

Sample_WacSetup_SelfSignedCert
```

The above example installs WAC with a self-signed certificate and listens at port 443.

## Example 2

```powershell
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
```

The above example installs WAC with a custom Server authentication certificate and listens at port 443.

## Example 3

```powershell
Configuration Sample_WacSetup_CustomPort
{

	Import-DscResource -ModuleName WindowsAdminCenterDsc
	WacSetup Sample_WacSetup_CustomPort
	{
		InstallerPath = 'C:\Wac\WindowsAdminCenterPreview1812.msi'
		CertificateThumbprint = '8E13E03E36EF4EAB6BD72589FC85FAA8D3E3EE41'
		Port = 4443
		Ensure = 'Present'
	}
}

Sample_WacSetup_CustomPort
```

The above example installs WAC with a custom Server authentication certificate and listens at custom port 4443.

## Example 4

```powershell
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
```

The above example uninstalls WAC.

