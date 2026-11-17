$ErrorActionPreference = 'Continue'
Write-Host 'Checking YourGym.us DNS records...' -ForegroundColor Cyan
Write-Host "`nA records for yourgym.us (expected four GitHub Pages IPv4 addresses):" -ForegroundColor Yellow
Resolve-DnsName yourgym.us -Type A | Where-Object { $_.Type -eq 'A' } | Select-Object Name, Type, IPAddress | Format-Table -AutoSize
Write-Host "`nCNAME record for www.yourgym.us (expected YOUR-USERNAME.github.io):" -ForegroundColor Yellow
Resolve-DnsName www.yourgym.us -Type CNAME | Select-Object Name, Type, NameHost | Format-Table -AutoSize
Write-Host "`nHTTPS site response:" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest 'https://yourgym.us' -UseBasicParsing -TimeoutSec 20
    Write-Host "HTTPS is responding: HTTP $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "HTTPS is not ready yet: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host 'DNS and GitHub Pages TLS setup can take time. Re-run this script later.'
}
