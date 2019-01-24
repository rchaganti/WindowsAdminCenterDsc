# Windows Admin Center DSC

> **Note**: This works only with Windows Admin Center 1812 insider preview and above.

This module contains a set of resources to install Windows Admin Center (WAC) and configure WAC feeds and extensions. 

| DSC Resource Name | Description                                                  |
| ----------------- | ------------------------------------------------------------ |
| WacSetup          | Installs Windows Admin Center. This is a composite resource and enables options to change the port and certificate thumbprint to a local certificate instead of a self-signed certificate. |
| WacFeed           | This resource supports adding and removing WAC extension feeds. |
| WacExtension      | This resource supports installing and uninstalling WAC extensions. |

