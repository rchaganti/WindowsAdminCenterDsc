#region localizeddata
if (Test-Path "${PSScriptRoot}\${PSUICulture}")
{
    Import-LocalizedData -BindingVariable LocalizedData -filename WacExtension.psd1 `
                         -BaseDirectory "${PSScriptRoot}\${PSUICulture}"
} 
else
{
    #fallback to en-US
    Import-LocalizedData -BindingVariable LocalizedData -filename WacExtension.psd1 `
                         -BaseDirectory "${PSScriptRoot}\en-US"
}
#endregion

<#
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory)]
        [System.String]
        $ExtensionId,

        [Parameter(Mandatory)]
        [System.String]
        $GatewayEndpoint     
    )

    # try loading the WAC extension tools module
    Import-Module "$env:ProgramFiles\windows admin center\PowerShell\Modules\ExtensionTools" -ErrorAction SilentlyContinue
    if(!(Get-Module -Name ExtensionTools))
    {
        Throw ($localizedData.moduleMissing -f 'ExtensionTools')
    }

    Write-Verbose -Message ($localizedData.CheckExtensionExists -f $ExtensionId)
    $extension = Get-Extension -GatewayEndpoint $GatewayEndpoint
    
    if($extension.Id -contains $ExtensionId)
    {        
        Write-Verbose -Message ($localizedData.ExtensionFound -f $ExtensionId)
        if ($extention.Where({$_.Id -eq $ExtensionId}).Status -eq 'Installed')
        {
            Write-Verbose -Message ($localizedData.ExtensionInstalled -f $ExtensionId)
            $Ensure = 'Present'
        }
        else
        {
            Write-Verbose -Message ($localizedData.ExtensionAvailable -f $ExtensionId)
            $Ensure = 'Absent'            
        }
    }
    else
    {
        Write-Verbose -Message ($localizedData.ExtensionNotFound -f $ExtensionId)
        $Ensure = 'Absent'
    }
        
    $configuration = @{
        'GatewayEndpoint' = $GatewayEndpoint
        'ExtensionId'     = $ExtensionId
        'Ensure'          = $Ensure 
    }

    return $configuration
}

<#
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [System.String]
        $ExtensionId,

        [Parameter(Mandatory)]
        [System.String]
        $GatewayEndpoint,

        [Parameter()]
        [System.String]
        $FeedPath,
        
        [Parameter()]
        [System.String]
        $Version,        

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [String] $Ensure = 'Present'
    )

    # try loading the WAC extension tools module
    Import-Module "$env:ProgramFiles\windows admin center\PowerShell\Modules\ExtensionTools" -ErrorAction SilentlyContinue
    if(!(Get-Module -Name ExtensionTools))
    {
        Throw ($localizedData.moduleMissing -f 'ExtensionTools')
    }
    
    Write-Verbose -Message ($localizedData.CheckExtensionExists -f $ExtensionId)
    $extension = Get-Extension -GatewayEndpoint $GatewayEndpoint

    if($($extension.Id) -contains $ExtensionId)
    {
        if ($extention.Where({$_.Id -eq $ExtensionId}).Status -eq 'Available')
        {
            $extensionAvailable = $true
        }
    }
    else
    {
        Throw -Message ($localizedData.ExtensionNotFound -f $ExtensionId)
    }

    $param = @{
        GatewayEndpoint = $GatewayEndpoint
        ExtensionId = $ExtensionId
    }

    if ($Credential)
    {
        $param.Add('Credential', $Credential)
    }

    if ($Ensure -eq 'Present')
    {
        if ($extensionAvailable)
        {
            Write-Verbose -Message ($localizedData.InstallExtension -f $ExtensionId)
    
            if ($Version)
            {
                $param.Add('Version', $Version)
            }
        
            if ($FeedPath)
            {
                $param.Add('Feed', $FeedPath)
            }                
            $null = Install-Extension @param
        }
    }
    else
    {
        if (!$extensionAvailable)
        {
            Write-Verbose -Message ($localizedData.UninstallExtension -f $ExtentionId)            
            $null = Uninstall-Extension @param
        }
    }
}

<#
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory)]
        [System.String]
        $ExtensionId,

        [Parameter(Mandatory)]
        [System.String]
        $GatewayEndpoint,

        [Parameter()]
        [System.String]
        $FeedPath,
        
        [Parameter()]
        [System.String]
        $Version,        

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [String] $Ensure = 'Present'       
    )

    # try loading the WAC extension tools module
    Import-Module "$env:ProgramFiles\windows admin center\PowerShell\Modules\ExtensionTools" -ErrorAction SilentlyContinue
    if(!(Get-Module -Name ExtensionTools))
    {
        Throw ($localizedData.moduleMissing -f 'ExtensionTools')
    }
    
    Write-Verbose -Message ($localizedData.CheckExtensionExists -f $ExtensionId)
    $extension = Get-Extension -GatewayEndpoint $GatewayEndpoint

    if($($extension.Id) -contains $ExtensionId)
    {
        if ($extention.Where({$_.Id -eq $ExtensionId}).Status -eq 'Available')
        {
            $extensionAvailable = $true
        }
    }
    else
    {
        Throw -Message ($localizedData.ExtensionNotFound -f $ExtensionId)
    }

    if ($Ensure -eq 'Present')
    {
        if ($extensionAvailable)
        {
            # Check if version matches
            if ($version) 
            {
                $extensionVersion = $extention.Where({$_.Id -eq $ExtensionId}).version
                if ($Version -eq $extensionVersion)
                {
                    Write-Verbose -Message ($localizedData.ExtensionAlreadyInstalled -f $ExtensionId)
                    return $true
                }
                else
                {
                    Write-Verbose -Message ($localizedData.ExtensionVersionMisMatch -f $ExtensionId)
                    return $false
                }
            }
            
            Write-Verbose -Message ($localizedData.InstallExtension -f $ExtensionId)
            return $false
        }
        else
        {
            Write-Verbose -Message ($localizedData.ExtensionAlreadyInstalled -f $ExtensionId)    
            return $true
        }
    }
    else
    {
        if (!$extensionAvailable)
        {
            Write-Verbose -Message ($localizedData.UninstallExtension -f $ExtentionId)            
            return $false
        }
        else
        {
            Write-Verbose -Message ($localizedData.ExtensionNotInstalled -f $ExtensionId)
            return $true    
        }
    }
}

Export-ModuleMember -Function *-TargetResource
