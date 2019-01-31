#region localizeddata
if (Test-Path "${PSScriptRoot}\${PSUICulture}")
{
    Import-LocalizedData -BindingVariable LocalizedData -filename WacClusterConnection.psd1 `
                         -BaseDirectory "${PSScriptRoot}\${PSUICulture}"
} 
else
{
    #fallback to en-US
    Import-LocalizedData -BindingVariable LocalizedData -filename WacClusterConnection.psd1 `
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
        $ClusterName,

        [Parameter(Mandatory)]
        [System.String]
        $GatewayEndpoint
    )
    # default connection type for this resource
    $connectionType = 'msft.sme.connection-type.cluster'

    # try loading the WAC connection tools module
    Import-Module "$env:ProgramFiles\windows admin center\PowerShell\Modules\ConnectionTools" -ErrorAction SilentlyContinue
    if(!(Get-Module -Name ConnectionTools))
    {
        Throw ($localizedData.moduleMissing -f 'ConnectionTools')
    }

    Write-Verbose -Message ($localizedData.CheckConnectionExists -f $ClusterName)
    $connections = Export-Connection -GatewayEndpoint $GatewayEndpoint
    
    if(($connections.Name -contains $ClusterName) -and ($connections.Where({$_.name -eq $ClusterName}).type -eq $connectionType))
    {        
        Write-Verbose -Message ($localizedData.ConnectionFound -f $ClusterName)
        $Ensure = 'Present'
    }
    else
    {
        Write-Verbose -Message ($localizedData.ConnectionNotFound -f $ClusterName)
        $Ensure = 'Absent'
    }
        
    $configuration = @{
        'GatewayEndpoint' = $GatewayEndpoint
        'ClusterName'     = $ClusterName
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
        $ClusterName,

        [Parameter(Mandatory)]
        [System.String]
        $GatewayEndpoint,

        [Parameter()]
        [String[]]
        $Tags,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [String]
        $Ensure = 'Present'
    )

    # default connection type for this resource
    $connectionType = 'msft.sme.connection-type.cluster'

    # try loading the WAC connection tools module
    Import-Module "$env:ProgramFiles\windows admin center\PowerShell\Modules\ConnectionTools" -ErrorAction SilentlyContinue
    if(!(Get-Module -Name ConnectionTools))
    {
        Throw ($localizedData.moduleMissing -f 'ConnectionTools')
    }

    Write-Verbose -Message ($localizedData.CheckConnectionExists -f $ClusterName)
    $connections = Export-Connection -GatewayEndpoint $GatewayEndpoint
    
    $hostName = ([System.Net.Dns]::GetHostByName($env:computerName)).hostname
    $wacConnection = $connections | Where-Object {$_.name -eq $hostName}

    $connectionInfo = @()
    $connectionInfo += [PSCustomObject]$wacConnection

    if ($Ensure -eq 'Present')
    {
        if (-not (($connections.Name -contains $ClusterName) -and ($connections.Where({$_.name -eq $ClusterName}).type -eq $connectionType)))
        {
            $newConnection = [PSCustomObject]@{
                name = $ClusterName
                type = $connectionType
                tags = $Tags
            }

            $connectionInfo += $newConnection
            $connectioninfo | Export-Csv -Path "${env:temp}\conn.csv" -NoTypeInformation -Force

            Write-Verbose -Message "CSV file is at ${env:temp}\conn.csv"

            $cmdParams = @{
                GatewayEndpoint = $GatewayEndpoint
                FileName = "${env:temp}\conn.csv"
            }

            if ($Credential)
            {
                $cmdParams.Add('Credential', $Credential)
            }

            Write-Verbose -Message ($localizedData.AddConnection -f $ClusterName)
            $null = Import-Connection @cmdParams
        }
    }
    else
    {
        if ((($connections.Name -contains $ClusterName) -and ($connections.Where({$_.name -eq $ClusterName}).type -eq $connectionType)))
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
        [Parameter(Mandatory)]
        [System.String]
        $ClusterName,

        [Parameter(Mandatory)]
        [System.String]
        $GatewayEndpoint,

        [Parameter()]
        [String[]]
        $Tags,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [String]
        $Ensure = 'Present'
    )

    # default connection type for this resource
    $connectionType = 'msft.sme.connection-type.cluster'

    # try loading the WAC connection tools module
    Import-Module "$env:ProgramFiles\windows admin center\PowerShell\Modules\ConnectionTools" -ErrorAction SilentlyContinue

    if(!(Get-Module -Name ConnectionTools))
    {
        Throw ($localizedData.moduleMissing -f 'ConnectionTools')
    }

    Write-Verbose -Message ($localizedData.CheckConnectionExists -f $ClusterName)
    $connections = Export-Connection -GatewayEndpoint $GatewayEndpoint

    if ($Ensure -eq 'Present')
    {
        if ($connections.Name -notcontains $ClusterName)
        {
            Write-Verbose -Message ($localizedData.ImportConnection -f $ClusterName)
            return $false
        }
        else
        {
            Write-Verbose -Message ($localizedData.ConnectionExists -f $ClusterName)    
            return $true
        }
    }
    else
    {
        if ((($connections.Name -contains $ClusterName) -and ($connections.Where({$_.name -eq $ClusterName}).type -eq $connectionType)))
        {            
            Write-Warning -Message $localizedData.RemoveNotImplemented
            return $true
        }
    }
}

Export-ModuleMember -Function *-TargetResource
