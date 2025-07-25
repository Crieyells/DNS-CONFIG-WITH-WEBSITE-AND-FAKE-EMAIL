# Create self-signed certificate for www.bpi.ph.com
$cert = New-SelfSignedCertificate -DnsName "www.bpi.ph.com" -CertStoreLocation "Cert:\LocalMachine\My"

# Bind HTTPS to website with correct cert
$siteName = "bpi.ph.com"
$hostname = "www.bpi.ph.com"
$certThumbprint = $cert.Thumbprint

# Ensure SSL binding
New-WebBinding -Name $siteName -Protocol https -Port 443 -HostHeader $hostname

# Bind certificate to HTTPS binding
Push-Location IIS:\SslBindings
New-Item "0.0.0.0!443!$hostname" -Thumbprint $certThumbprint -SSLFlags 1
Pop-Location

# OPTIONAL: Import cert into Trusted Root if you want local trust automatically
$certPath = "Cert:\LocalMachine\My\$certThumbprint"
$rootStore = New-Object System.Security.Cryptography.X509Certificates.X509Store("Root","LocalMachine")
$rootStore.Open("ReadWrite")
$rootStore.Add((Get-Item $certPath))
$rootStore.Close()

# Restart IIS
iisreset
