# actualizar.ps1
# Corré este script cada vez que edites template-editable.html
# En VS Code: abrí la terminal con Ctrl+` y escribí:
#   powershell -ExecutionPolicy Bypass -File actualizar.ps1

$templatePath = "$PSScriptRoot\template-editable.html"
$bundlePath   = "$PSScriptRoot\index.html"

if (-not (Test-Path $templatePath)) {
    Write-Host "ERROR: No se encontro template-editable.html" -ForegroundColor Red
    exit 1
}

$templateHtml = Get-Content $templatePath -Raw -Encoding UTF8

# JavaScriptSerializer produce JSON correcto para strings grandes
# (ConvertTo-Json en PS 5.1 produce {"value":"..."} en vez de "..." — bug conocido)
Add-Type -AssemblyName System.Web.Extensions
$ser = New-Object System.Web.Script.Serialization.JavaScriptSerializer
$ser.MaxJsonLength = [int]::MaxValue
$jsonEncoded = $ser.Serialize($templateHtml)

$bundleContent = Get-Content $bundlePath -Raw -Encoding UTF8
$marker        = '<script type="__bundler/template">'
$endMarker     = '</script>'
$start         = $bundleContent.IndexOf($marker) + $marker.Length
$end           = $bundleContent.IndexOf($endMarker, $start)

$newContent = $bundleContent.Substring(0, $start) + "`n" + $jsonEncoded + "`n" + $bundleContent.Substring($end)
[System.IO.File]::WriteAllText($bundlePath, $newContent, [System.Text.Encoding]::UTF8)

Write-Host "Listo! index.html actualizado. Recarga el navegador." -ForegroundColor Green
