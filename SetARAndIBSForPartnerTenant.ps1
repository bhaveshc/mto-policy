param(
    [Parameter(Mandatory)]
    $partnerTenantIds,

    [Parameter(Mandatory, ParameterSetName="Get")]
    [Switch]$Peek,

    [Parameter(Mandatory, ParameterSetName="Set")]
    [Boolean]$value = $true
)

function GetOrSetPolicies($partnerTenantId, [bool]$peek, $value)
{
    Write-Host "Partner tenant $partnerTenantId" -ForegroundColor Magenta
    $xtap = Get-MgPolicyCrossTenantAccessPolicyPartner -CrossTenantAccessPolicyConfigurationPartnerTenantId $partnerTenantId -ErrorAction:Silently

    if(-not $xtap)
    {
        Write-Error "Failed to get partner policy object for tenant $partnerTenantId."
        return
    }

    if($peek)
    {
        Write-Host "AutomaticUserConsentSettings.InboundAllowed = $($xtap.AutomaticUserConsentSettings.InboundAllowed)"
        Write-Host "AutomaticUserConsentSettings.OutboundAllowed = $($xtap.AutomaticUserConsentSettings.OutboundAllowed)"
    }
    else
    {
        $xtapPayload = @{
            AutomaticUserConsentSettings = @{       
            }
        }

        $isUpdate = $false
        if(($value -and -not $xtap.AutomaticUserConsentSettings.InboundAllowed) -or (-not $value -and $xtap.AutomaticUserConsentSettings.InboundAllowed))
        {
            $xtapPayload.AutomaticUserConsentSettings["InboundAllowed"] = $value
            $isUpdate = $true
        }
        if(($value -and -not $xtap.AutomaticUserConsentSettings.OutboundAllowed) -or (-not $value -and $xtap.AutomaticUserConsentSettings.OutboundAllowed))
        {
            $xtapPayload.AutomaticUserConsentSettings["OutboundAllowed"] = $value
            $isUpdate = $true
        }

        if($isUpdate)
        {
            Update-MgPolicyCrossTenantAccessPolicyPartner -CrossTenantAccessPolicyConfigurationPartnerTenantId $partnerTenantId -BodyParameter $xtapPayload
            Write-Host "Successfully updated AR in partner policy for tenant $partnerTenantId to $value" -ForegroundColor Green
        }
        else
        {
            Write-Host "No updates needed for AR in partner policy for tenant $partnerTenantId" -ForegroundColor Yellow
        }
    }

    $idsPolicy = Get-MgPolicyCrossTenantAccessPolicyPartnerIdentitySynchronization -CrossTenantAccessPolicyConfigurationPartnerTenantId $partnerTenantId -ErrorAction:Silently
    if(-not $idsPolicy)
    {
        Write-Error "Failed to get Identity Sync policy object for tenant $partnerTenantId."
        return
    }

    if($peek)
    {
        Write-Host "UserSyncInbound.IsSyncAllowed = $($idsPolicy.UserSyncInbound.IsSyncAllowed)"
    }
    else
    {
        $idsPolicyPayload = @{
            UserSyncInbound = @{
                IsSyncAllowed = $false
            }
        }

        $isUpdate = $false
        if(($value -and -not $idsPolicy.UserSyncInbound.IsSyncAllowed) -or (-not $value -and $idsPolicy.UserSyncInbound.IsSyncAllowed))
        {
            $idsPolicyPayload.UserSyncInbound.IsSyncAllowed = $value
            $isUpdate = $true
        }

        if($isUpdate)
        {
            Update-MgPolicyCrossTenantAccessPolicyPartnerIdentitySynchronization -CrossTenantAccessPolicyConfigurationPartnerTenantId $partnerTenantId -BodyParameter $idsPolicyPayload
            Write-Host "Successfully updated IBS in partner policy for tenant $partnerTenantId to $value" -ForegroundColor Green
        }
        else
        {
            Write-Host "No updates needed for IBS in partner policy for tenant $partnerTenantId" -ForegroundColor Yellow
        }
    }
}

# Temporarily set installation policy to suppress prompts
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted

if(-not (Get-InstalledModule Microsoft.Graph -ErrorAction:SilentlyContinue))
{
    Install-Module Microsoft.Graph -Scope CurrentUser -Confirm:$false
}

Select-MgProfile -Name "beta"

try
{
    Connect-MgGraph -Scopes "Organization.Read.All,Policy.Read.All,Policy.ReadWrite.CrossTenantAccess"
    $org = Get-MgOrganization
    Write-Host "Current tenant $($org.Id) ($($org.VerifiedDomains.Name))" -ForegroundColor Blue
    $partnerTenantIds -split ',' | % { GetOrSetPolicies $_ $Peek $value }
}
catch
{
    Write-Error $_
}
finally
{
    Disconnect-MgGraph | Out-Null
    # Reset the policy for security reasons
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Untrusted
}
