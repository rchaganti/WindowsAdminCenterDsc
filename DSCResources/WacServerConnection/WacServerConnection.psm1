#region localizeddata
if (Test-Path "${PSScriptRoot}\${PSUICulture}")
{
    Import-LocalizedData -BindingVariable LocalizedData -filename WacServerConnection.psd1 `
                         -BaseDirectory "${PSScriptRoot}\${PSUICulture}"
} 
else
{
    #fallback to en-US
    Import-LocalizedData -BindingVariable LocalizedData -filename WacServerConnection.psd1 `
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
        [Parameter(Mandatory = $true)]
        [System.String]
        $ServerName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $GatewayEndpoint,

        [Parameter(Mandatory = $true)]
        [pscredential]
        $Credential        
    )
    # default connection type for this resource
    $connectionType = 'msft.sme.connection-type.server'

    # try loading the WAC connection tools module
    Import-Module "$env:ProgramFiles\windows admin center\PowerShell\Modules\ConnectionTools" -ErrorAction SilentlyContinue
    if(!(Get-Module -Name ConnectionTools))
    {
        Throw ($localizedData.moduleMissing -f 'ConnectionTools')
    }

    Write-Verbose -Message ($localizedData.CheckConnectionExists -f $ServerName)
    $connections = Export-Connection -GatewayEndpoint $GatewayEndpoint -Credential $Credential
    
    if(($connections.Name -contains $ServerName) -and ($connections.Where({$_.name -eq $ServerName}).type -eq $connectionType))
    {        
        Write-Verbose -Message ($localizedData.ConnectionFound -f $ServerName)
        $Ensure = 'Present'
    }
    else
    {
        Write-Verbose -Message ($localizedData.ConnectionNotFound -f $ServerName)
        $Ensure = 'Absent'
    }
        
    $configuration = @{
        'GatewayEndpoint' = $GatewayEndpoint
        'ServerName'     = $ServerName
        'Credential'      = $Credential.GetNetworkCredential().UserName
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
        [Parameter(Mandatory = $true)]
        [System.String]
        $ServerName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $GatewayEndpoint,

        [Parameter()]
        [String[]]
        $Tags,

        [Parameter(Mandatory = $true)]
        [pscredential]
        $Credential,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [String]
        $Ensure = 'Present'
    )

    # default connection type for this resource
    $connectionType = 'msft.sme.connection-type.server'

    # try loading the WAC connection tools module
    Import-Module "$env:ProgramFiles\windows admin center\PowerShell\Modules\ConnectionTools" -ErrorAction SilentlyContinue
    if(!(Get-Module -Name ConnectionTools))
    {
        Throw ($localizedData.moduleMissing -f 'ConnectionTools')
    }

    Write-Verbose -Message ($localizedData.CheckConnectionExists -f $ServerName)
    $connections = Export-Connection -GatewayEndpoint $GatewayEndpoint -Credential $Credential
    
    $hostName = ([System.Net.Dns]::GetHostByName($env:computerName)).hostname
    $wacConnection = $connections | Where-Object {$_.name -eq $hostName}

    $connectionInfo = @()
    $connectionInfo += [PSCustomObject]$wacConnection

    if ($Ensure -eq 'Present')
    {
        if (-not (($connections.Name -contains $ServerName) -and ($connections.Where({$_.name -eq $ServerName}).type -eq $connectionType)))
        {
            $newConnection = [PSCustomObject]@{
                name = $ServerName
                type = $connectionType
                tags = $Tags
            }

            $connectionInfo += $newConnection
            $connectioninfo | Export-Csv -Path "${env:temp}\conn.csv" -NoTypeInformation -Force

            Write-Verbose -Message "CSV file is at ${env:temp}\conn.csv"

            $cmdParams = @{
                GatewayEndpoint = $GatewayEndpoint
                FileName = "${env:temp}\conn.csv"
                Credential = $Credential
            }

            Write-Verbose -Message ($localizedData.AddConnection -f $ServerName)
            $null = Import-Connection @cmdParams
        }
    }
    else
    {
        if ((($connections.Name -contains $ServerName) -and ($connections.Where({$_.name -eq $ServerName}).type -eq $connectionType)))
        {            
            Write-Warning -Message $localizedData.RemoveNotImplemented
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
        [Parameter(Mandatory = $true)]
        [System.String]
        $ServerName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $GatewayEndpoint,

        [Parameter()]
        [String[]]
        $Tags,

        [Parameter(Mandatory = $true)]
        [pscredential]
        $Credential,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [String]
        $Ensure = 'Present'
    )

    # default connection type for this resource
    $connectionType = 'msft.sme.connection-type.server'

    # try loading the WAC connection tools module
    Import-Module "$env:ProgramFiles\windows admin center\PowerShell\Modules\ConnectionTools" -ErrorAction SilentlyContinue

    if(!(Get-Module -Name ConnectionTools))
    {
        Throw ($localizedData.moduleMissing -f 'ConnectionTools')
    }

    Write-Verbose -Message ($localizedData.CheckConnectionExists -f $ServerName)
    $connections = Export-Connection -GatewayEndpoint $GatewayEndpoint -Credential $Credential

    if ($Ensure -eq 'Present')
    {
        if ($connections.Name -notcontains $ServerName)
        {
            Write-Verbose -Message ($localizedData.ImportConnection -f $ServerName)
            return $false
        }
        else
        {
            Write-Verbose -Message ($localizedData.ConnectionExists -f $ServerName)    
            return $true
        }
    }
    else
    {
        if ((($connections.Name -contains $ServerName) -and ($connections.Where({$_.name -eq $ServerName}).type -eq $connectionType)))
        {            
            Write-Warning -Message $localizedData.RemoveNotImplemented
            return $true
        }
    }
}

Export-ModuleMember -Function *-TargetResource
