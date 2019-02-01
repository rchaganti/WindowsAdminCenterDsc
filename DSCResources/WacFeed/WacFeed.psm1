#region localizeddata
if (Test-Path "${PSScriptRoot}\${PSUICulture}")
{
    Import-LocalizedData -BindingVariable LocalizedData -filename WacFeed.psd1 `
                         -BaseDirectory "${PSScriptRoot}\${PSUICulture}"
} 
else
{
    #fallback to en-US
    Import-LocalizedData -BindingVariable LocalizedData -filename WacFeed.psd1 `
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
        $FeedPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $GatewayEndpoint     
    )

    # try loading the WAC extension tools module
    Import-Module "$env:ProgramFiles\windows admin center\PowerShell\Modules\ExtensionTools" -ErrorAction SilentlyContinue
    if(!(Get-Module -Name ExtensionTools))
    {
        Throw ($localizedData.moduleMissing -f 'ExtensionTools')
    }

    Write-Verbose -Message ($localizedData.CheckFeedExists -f $FeedPath)
    $feed = Get-Feed -GatewayEndpoint $GatewayEndpoint
    
    if($feed -contains $FeedPath)
    {
        Write-Verbose -Message ($localizedData.FeedFound -f $FeedPath)
        $Ensure = 'Present'
    }
    else
    {
        Write-Verbose -Message ($localizedData.FeedNotFound -f $FeedPath)
        $Ensure = 'Absent'
    }
        
    $configuration = @{
        'GatewayEndpoint' = $GatewayEndpoint
        'FeedPath'        = $FeedPath
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
        $FeedPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $GatewayEndpoint,

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
    
    # Prepare parameters
    $param = @{
        GatewayEndpoint = $GatewayEndpoint
        Feed            = $FeedPath
    }

    if ($Credential)
    {
        $param.Add('Credential', $Credential)
    }

    # Perform set based on value of Ensure
    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message ($localizedData.AddFeed -f $FeedPath)
        $null = Add-Feed @param
    }
    else
    {
        Write-Verbose -Message ($localizedData.RemoveFeed -f $FeedPath)
        $null = Remove-Feed @param
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
        $FeedPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $GatewayEndpoint,

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

    Write-Verbose -Message $localizedData.CheckFeedExists
    $feed = Get-Feed -GatewayEndpoint $GatewayEndpoint

    if ($Ensure -eq 'Present')
    {
        if ($feed -contains $FeedPath)
        {
            Write-Verbose -Message ($localizedData.FeedAlreadyPresent -f $FeedPath)
            return $true
        }
        else
        {
            Write-Verbose -Message ($localizedData.FeedShouldBePresent -f $FeedPath)
            return $false
        }
    }
    else
    {
        if ($feed -contains $FeedPath)
        {
            Write-Verbose -Message ($localizedData.FeedShouldNotBePresent -f $FeedPath)
            return $false
        }
        else
        {
            Write-Verbose -Message ($localizedData.FeedNotPresent -f $FeedPath)
            return $true         
        }        
    }
}

Export-ModuleMember -Function *-TargetResource
