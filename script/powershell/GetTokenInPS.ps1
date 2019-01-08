Clear-AzureProfile -Force
$subscriptionId = "2ece347c-6d23-4d45-9cb8-d9cc1e6dd34f"
$azurepasswd = ConvertTo-SecureString "password" -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential ("username", $azurepasswd)

$account =Add-AzureRmAccount -Environment AzureChinaCloud -Credential $mycreds

$tenantId = (Get-AzureRmSubscription -SubscriptionId $subscriptionId).TenantId
$tokenCache = $account.Context.TokenCache
$cachedTokens = $tokenCache.ReadItems() `
        | where { $_.TenantId -eq $tenantId } `
        | Sort-Object -Property ExpiresOn -Descending
$accessToken = $cachedTokens[0].AccessToken