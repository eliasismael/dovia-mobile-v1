# Genera las APK de prueba de DOVIA, una por entorno, cada una con su URL de
# API y su flavor (se instalan juntas: com.mycompany.dovia / .stg; las dos
# con push).
#
# Uso (desde cualquier carpeta):
#   powershell -ExecutionPolicy Bypass -File tools\build_apks.ps1            # dev y staging
#   powershell -ExecutionPolicy Bypass -File tools\build_apks.ps1 staging    # sólo una
#
# Las APK quedan en dist\ como dovia-<entorno>-<version>.apk.
#
# Las keys de Intercom (chat de soporte) salen de config\dart_defines.json, que
# no se versiona: copiar config\dart_defines.example.json y completarlo. Sin
# ese archivo la APK abre el panel de soporte viejo.

param([string[]]$Envs = @('dev', 'staging'))

$ErrorActionPreference = 'Stop'

$urls = @{
  dev     = 'https://fqjwdfvbi2.execute-api.us-east-2.amazonaws.com/dev'
  staging = 'https://52aqw5tygf.execute-api.us-east-2.amazonaws.com/staging'
}

# La ruta del proyecto tiene una "í" y las herramientas de Android no la
# soportan: se compila desde una unidad sin acentos y con TEMP en C:\tmp.
$project = Split-Path -Parent $PSScriptRoot
$drive = 'X:'
if (-not (Test-Path "$drive\pubspec.yaml")) {
  subst $drive $project
}
New-Item -ItemType Directory -Force 'C:\tmp' | Out-Null
$env:TEMP = 'C:\tmp'
$env:TMP = 'C:\tmp'
$env:JAVA_TOOL_OPTIONS = '-Djdk.net.unixdomain.tmpdir=C:\tmp -Djava.io.tmpdir=C:\tmp'

# versionCode creciente en cada build (año, mes, día y hora): una APK nueva
# se instala encima de la anterior sin desinstalar.
$buildNumber = Get-Date -Format 'yyMMddHH'
$defines = if (Test-Path "$drive\config\dart_defines.json") { @('--dart-define-from-file=config/dart_defines.json') } else { @() }
$versionName = ((Select-String -Path "$drive\pubspec.yaml" -Pattern '^version:\s*([0-9.]+)').Matches[0].Groups[1].Value)

New-Item -ItemType Directory -Force "$drive\dist" | Out-Null
Push-Location $drive\
try {
  foreach ($envName in $Envs) {
    if (-not $urls.ContainsKey($envName)) { throw "Entorno desconocido: $envName (dev | staging)" }
    Write-Host "`n=== $envName ($($urls[$envName])) build $buildNumber ===" -ForegroundColor Cyan
    flutter build apk --release --flavor $envName `
      --dart-define=API_BASE_URL=$($urls[$envName]) @defines `
      --build-name=$versionName --build-number=$buildNumber
    if ($LASTEXITCODE -ne 0) { throw "Falló el build de $envName" }
    $out = "build\app\outputs\flutter-apk\app-$envName-release.apk"
    $dest = "dist\dovia-$envName-$versionName+$buildNumber.apk"
    Copy-Item $out $dest -Force
    Write-Host "OK -> $dest" -ForegroundColor Green
  }
} finally {
  Pop-Location
}
