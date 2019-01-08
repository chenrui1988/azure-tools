Param
(
    [Parameter(ParameterSetName='Setting', Mandatory=$true)]
	[String]
	$UserName,

    [Parameter(ParameterSetName='Setting', Mandatory=$true)]
	[String]
	$Password,

    [Parameter(ParameterSetName='Setting')]
    [String]
    $Resource,

    [Parameter(ParameterSetName='Setting', Mandatory=$true)]
    [String]
    $TenantId
)

if(!$Resource) 
{
    $Resource = "https://graph.chinacloudapi.cn/";
}
$TokenEndpoint = {https://login.chinacloudapi.cn/{0}/oauth2/token} -f $TenantId


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
return $token