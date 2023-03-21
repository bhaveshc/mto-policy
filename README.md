# Getting or setting AR & IBS settings in partner policies

## Instructions
1. Download file `SetARAndIBSForPartnerTenant.ps1` to a local folder
2. Open Terminal and navigate to above folder
3. Bypass ExecutionPolicy
```
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```
4. Run the script by providing target tenant IDs

Reading AR & IBS for multiple partner tenants
```
PS C:\work\scripts> .\SetARAndIBSForPartnerTenant.ps1 -partnerTenantId a3098d00-4d6e-43e4-a2b6-1e2437a6dad3,9cca133a-6d38-4b22-a743-e72c84810a20 -Peek
```

Set AR & IBS for for multiple partner tenants
```
PS C:\work\scripts> .\SetARAndIBSForPartnerTenant.ps1 -partnerTenantId a3098d00-4d6e-43e4-a2b6-1e2437a6dad3,9cca133a-6d38-4b22-a743-e72c84810a20 -value:$false
```
5. Login with Global Admin credentials for the tenant on which you want to get/set policies

6. Admin consent will be required for MS Graph PSh app once for a given tenant
![admin consent](https://user-images.githubusercontent.com/364996/226697299-d8b02583-14b1-430e-a0bd-a3e04cbe19ce.png)

### Sample Output
Set AR & IBS for a given partner tenant
```
PS C:\work\scripts> .\SetARAndIBSForPartnerTenant.ps1 -partnerTenantId a3098d00-4d6e-43e4-a2b6-1e2437a6dad3 -value:$false
Welcome To Microsoft Graph!
Current tenant ecfd0b4e-a605-4f6b-98fe-04903887ca38 (BCTst1.onmicrosoft.com)
Partner tenant a3098d00-4d6e-43e4-a2b6-1e2437a6dad3
Successfully updated AR in partner policy for tenant a3098d00-4d6e-43e4-a2b6-1e2437a6dad3 to False
Successfully updated IBS in partner policy for tenant a3098d00-4d6e-43e4-a2b6-1e2437a6dad3 to False
```

Reading AR & IBS for a given partner tenant
```
PS C:\Users\bchauhan.REDMOND\OneDrive - Microsoft\work\scripts> .\SetARAndIBSForPartnerTenant.ps1 -partnerTenantId a3098d00-4d6e-43e4-a2b6-1e2437a6dad3 -Peek
Welcome To Microsoft Graph!
Current tenant ecfd0b4e-a605-4f6b-98fe-04903887ca38 (BCTst1.onmicrosoft.com)
Partner tenant a3098d00-4d6e-43e4-a2b6-1e2437a6dad3
AutomaticUserConsentSettings.InboundAllowed = False
AutomaticUserConsentSettings.OutboundAllowed = False
UserSyncInbound.IsSyncAllowed = False
```
## Known Issues
1. This script requires that partner policy already exists for a target tenant. 
1. When updating policies, all three settings namely AR inbound, outbound and IBS will be set to the same value
