#Create Self Signed Certificate
$currentDate = Get-Date
$endDate = $currentDate.AddYears(1)
$notAfter = $endDate.AddYears(1)
$pwd = "P@ssW0rd1"
$thumb = (New-SelfSignedCertificate -CertStoreLocation cert:\localmachine\my -DnsName com.foo.bar -KeyExportPolicy Exportable -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" -NotAfter $notAfter).Thumbprint
$pwd = ConvertTo-SecureString -String $pwd -Force -AsPlainText

Export-PfxCertificate -cert "cert:\localmachine\my\$thumb" -FilePath e:\examplecert1.pfx  -Password $pwd
Export-Certificate -cert "cert:\localmachine\my\$thumb" -FilePath e:\publiccert.cer