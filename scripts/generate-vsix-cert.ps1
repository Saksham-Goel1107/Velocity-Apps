
<#
.SYNOPSIS
    Generates a self-signed RSA code-signing certificate for the
    Velocity VS Code Extension.

.DESCRIPTION
    Creates a self-signed certificate, exports it to PFX format,
    and generates a Base64-encoded certificate and password file.

    GitHub Actions secrets:
        VSIX_CERTIFICATE_BASE64
        VSIX_CERTIFICATE_PASSWORD

.EXAMPLE
    .\scripts\generate-vsix-cert.ps1

.NOTES
    Requirements : Windows PowerShell 5.1+ or PowerShell 7+
    Output files :
        velocity-vsix-cert.pfx
        velocity-vsix-cert.b64.txt
        velocity-vsix-cert.password.txt
#>

#Requires -Version 5.1

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "`n==> Generating Velocity VS Code Extension code-signing certificate..." -ForegroundColor Cyan

# ------------------------------------------------------------
# 1. Generate a cryptographically secure random password
# ------------------------------------------------------------

$chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789#$@!'

$randomBytes = New-Object byte[] 40
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()

try {
    $rng.GetBytes($randomBytes)
}
finally {
    $rng.Dispose()
}

$passwordChars = New-Object char[] 40

for ($i = 0; $i -lt 40; $i++) {
    $passwordChars[$i] = $chars[[int]($randomBytes[$i] % $chars.Length)]
}

$password = -join $passwordChars

# ------------------------------------------------------------
# 2. Create self-signed RSA-2048 SHA-256 code-signing cert
# ------------------------------------------------------------

$certParams = @{
    Type              = 'CodeSigningCert'
    Subject           = 'CN=Velocity VS Code Extension, O=Velocity Cloud Inc, L=San Francisco, S=California, C=US'
    FriendlyName      = 'Velocity VS Code Extension Code Signing'
    CertStoreLocation = 'Cert:\CurrentUser\My'
    KeyExportPolicy   = 'Exportable'
    KeySpec           = 'Signature'
    KeyLength         = 2048
    KeyAlgorithm      = 'RSA'
    HashAlgorithm     = 'SHA256'
    NotAfter          = (Get-Date).AddYears(10)
}

$cert = New-SelfSignedCertificate @certParams

Write-Host "    Thumbprint : $($cert.Thumbprint)" -ForegroundColor Gray
Write-Host "    Subject    : $($cert.Subject)" -ForegroundColor Gray
Write-Host "    Expires    : $($cert.NotAfter)" -ForegroundColor Gray

# ------------------------------------------------------------
# 3. Define output paths
# ------------------------------------------------------------

$pfxPath = Join-Path $PSScriptRoot 'velocity-vsix-cert.pfx'
$b64Path = Join-Path $PSScriptRoot 'velocity-vsix-cert.b64.txt'
$passwordPath = Join-Path $PSScriptRoot 'velocity-vsix-cert.password.txt'

# ------------------------------------------------------------
# 4. Export certificate to PFX
# ------------------------------------------------------------

$securePassword = ConvertTo-SecureString `
    -String $password `
    -Force `
    -AsPlainText

Export-PfxCertificate `
    -Cert $cert `
    -FilePath $pfxPath `
    -Password $securePassword | Out-Null

# ------------------------------------------------------------
# 5. Base64-encode the PFX
# ------------------------------------------------------------

$b64 = [Convert]::ToBase64String(
    [IO.File]::ReadAllBytes($pfxPath)
)

# ------------------------------------------------------------
# 6. Save output files as UTF-8 without BOM
# ------------------------------------------------------------

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

[IO.File]::WriteAllText($b64Path, $b64, $utf8NoBom)
[IO.File]::WriteAllText($passwordPath, $password, $utf8NoBom)

# ------------------------------------------------------------
# 7. Print GitHub Actions secret instructions
# ------------------------------------------------------------

Write-Host "`n============================================================" -ForegroundColor Green
Write-Host "       GitHub Actions Secrets - ADD THESE NOW" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green

Write-Host "`n  Go to: https://github.com/Saksham-Goel1107/velocity-app/settings/secrets/actions" -ForegroundColor DarkCyan
Write-Host "  (or whichever repository hosts this workflow)`n"

Write-Host "  Secret name  : VSIX_CERTIFICATE_BASE64" -ForegroundColor Yellow
Write-Host "  Secret value : (contents of velocity-vsix-cert.b64.txt)" -ForegroundColor Cyan
Write-Host "                 $($b64.Substring(0, [Math]::Min(60, $b64.Length)))..." -ForegroundColor DarkGray

Write-Host "`n  Secret name  : VSIX_CERTIFICATE_PASSWORD" -ForegroundColor Yellow
Write-Host "  Secret value : $password" -ForegroundColor Cyan

Write-Host "`n============================================================" -ForegroundColor Red
Write-Host "       SECURITY - READ BEFORE PROCEEDING" -ForegroundColor Red
Write-Host "============================================================" -ForegroundColor Red

Write-Host "  1. Store BOTH secrets in GitHub now."
Write-Host "  2. DELETE velocity-vsix-cert.pfx after securely storing the secrets."
Write-Host "  3. Also DELETE velocity-vsix-cert.b64.txt and velocity-vsix-cert.password.txt."
Write-Host "  4. NEVER commit these files to Git."
Write-Host "  5. Keep a secure backup of the certificate if you need to reuse it.`n" -ForegroundColor Red

Write-Host "Done. Certificate files written to $PSScriptRoot" -ForegroundColor Green
