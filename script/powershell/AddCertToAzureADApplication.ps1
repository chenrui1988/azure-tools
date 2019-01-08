Param
(
    [Parameter(ParameterSetName='Setting', Mandatory=$true)]
    [String]
    $SubscriptionId,

    [Parameter(ParameterSetName='Setting', Mandatory=$true)]
    [String]
    $UserName,

    [Parameter(ParameterSetName='Setting', Mandatory=$true)]
    [String]
	$Password,

    [Parameter(ParameterSetName='Setting', Mandatory=$true)]
    [String]
    $AppObjectId,

    [Parameter(ParameterSetName='Setting', Mandatory=$true)]
    [String]
    $CertPath,

    [Parameter(ParameterSetName='Setting', Mandatory=$true)]
    [String]
    $TenantId
)

Write-Host 'TenantId = ' $TenantId
Write-Host 'SubscriptionId = ' $SubscriptionId
Write-Host 'AppObjectId = ' $AppObjectId



$TokenEndpoint = {https://login.chinacloudapi.cn/{0}/oauth2/token} -f $TenantId
$Resource = "https://graph.chinacloudapi.cn/";

$Body = @{
    "resource"= $Resource
    "client_id" = "1950a258-227b-4e31-a9cf-717495945fc2"
    "grant_type" = 'password'
    "username" = $Username
    "password" = $Password
}

$RequstParams = @{
    ContentType = 'application/x-www-form-urlencoded'
    Headers = @{'accept'='application/json'}
    Body = $Body
    Method = 'Post'
    URI = $TokenEndpoint
    ErrorVariable = $RestError
    
}

$token = Invoke-RestMethod -ContentType 'application/x-www-form-urlencoded' -Headers @{'accept'='application/json'} -Body $Body -Method 'Post' -URI $TokenEndpoint -ErrorVariable RestError -ErrorAction Stop
if ($RestError)
{
    $HttpStatusCode = $RestError.ErrorRecord.Exception.Response.StatusCode.value__
    $HttpStatusDescription = $RestError.ErrorRecord.Exception.Response.StatusDescription
    
    Throw "Http Status Code: $($HttpStatusCode) `nHttp Status Description: $($HttpStatusDescription)"
    return -1
}
$AccessToken = $token.access_token


# Import Cert and get Cert Content
$Cer = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
$Cer.Import($CertPath)
$Base64Value = [System.Convert]::ToBase64String($Cer.GetRawCertData())
$Base64Thumbprint = [System.Convert]::ToBase64String($Cer.GetCertHash())


# Request for upload cert to Azure AD Application
$Body = @{
    "keyCredentials"= @(@{
	"customKeyIdentifier"=$Base64Thumbprint;
	"keyId"=[System.Guid]::NewGuid().ToString()
	"type"="AsymmetricX509Cert";
	"usage"="Verify";
	"value"=$Base64Value;
 })
}

$Result = Invoke-RestMethod -Method PATCH `
                  -Uri ("https://graph.chinacloudapi.cn/"+ $TenantId+"/applications/" + $AppObjectId + "?api-version=1.6") `
                  -Body ($Body|ConvertTo-Json) `
                  -ContentType "application/json" `
                  -Headers @{ "Authorization" = "Bearer " + $AccessToken } `
                  -ErrorVariable RestError -ErrorAction Stop
if ($RestError)
{
    $HttpStatusCode = $RestError.ErrorRecord.Exception.Response.StatusCode.value__
    $HttpStatusDescription = $RestError.ErrorRecord.Exception.Response.StatusDescription
    
    Throw "Http Status Code: $($HttpStatusCode) `nHttp Status Description: $($HttpStatusDescription)"
}
else 
{
    Write-Host
    Write-Host 'Update Success!'
}