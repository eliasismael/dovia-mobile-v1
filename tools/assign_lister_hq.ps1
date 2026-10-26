# Asigna un Lister HQ a la visita de Operative Listing de una propiedad, como
# lo hace un admin desde la web (PATCH /admin/visits/{visitId}/assign-lister-hq).
# Con eso el Lister HQ ve la propiedad, revisa los documentos y asigna al
# Operative Listing.
#
# Uso (dev por defecto):
#   powershell -ExecutionPolicy Bypass -File tools\assign_lister_hq.ps1 `
#     -VisitId 01a1786a-2c72-730a-9676-37226a2c02a2 `
#     -ListerHqEmail lister_hq_gato222@dovia.com `
#     -AdminEmail admin@dovia.com
#
# La contraseña del admin se pide por consola (no queda en el historial). Para
# no escribirla cada vez se puede dejar en $env:DOVIA_ADMIN_PASSWORD.
# -BaseUrl cambia de entorno (staging: .../staging).

param(
  [Parameter(Mandatory = $true)][string]$VisitId,
  [Parameter(Mandatory = $true)][string]$ListerHqEmail,
  [Parameter(Mandatory = $true)][string]$AdminEmail,
  [string]$BaseUrl = 'https://fqjwdfvbi2.execute-api.us-east-2.amazonaws.com/dev'
)

$ErrorActionPreference = 'Stop'
$BaseUrl = $BaseUrl.TrimEnd('/')

function Fail([string]$msg) {
  Write-Host "ERROR: $msg" -ForegroundColor Red
  exit 1
}

# Mensaje del backend cuando la llamada falla (Invoke-RestMethod lo esconde).
function Describe-Error($err) {
  $body = $null
  if ($err.ErrorDetails -and $err.ErrorDetails.Message) {
    $body = $err.ErrorDetails.Message
  }
  $status = ''
  if ($err.Exception.Response) { $status = [int]$err.Exception.Response.StatusCode }
  if ($body) { return "HTTP $status $body" }
  return "HTTP $status $($err.Exception.Message)"
}

# 1. Login del admin -------------------------------------------------------
$password = $env:DOVIA_ADMIN_PASSWORD
if (-not $password) {
  $secure = Read-Host "Contraseña de $AdminEmail" -AsSecureString
  $password = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure))
}

Write-Host "Entorno: $BaseUrl"
Write-Host "Iniciando sesión como $AdminEmail..."
try {
  $signIn = Invoke-RestMethod -Method Post -Uri "$BaseUrl/auth/sign-in" `
    -ContentType 'application/json; charset=utf-8' `
    -Body (@{ email = $AdminEmail; password = $password } | ConvertTo-Json)
} catch {
  Fail "No se pudo iniciar sesión: $(Describe-Error $_)"
}
# /auth/sign-in lo devuelve en data.idToken (otros endpoints, en data.tokens).
$token = $signIn.data.idToken
if (-not $token) { $token = $signIn.data.tokens.idToken }
if (-not $token) {
  Fail "El login no devolvió idToken: $($signIn | ConvertTo-Json -Depth 4 -Compress)"
}
$headers = @{ Authorization = "Bearer $token" }

# 2. Buscar el id del Lister HQ por email ----------------------------------
# GET /users?role=LISTER_HQ solo devuelve usuarios activos y verificados.
Write-Host "Buscando $ListerHqEmail entre los Lister HQ..."
$lister = $null
$page = 1
$limit = 100
while (-not $lister) {
  try {
    $res = Invoke-RestMethod -Method Get -Headers $headers `
      -Uri "$BaseUrl/users?role=LISTER_HQ&page=$page&limit=$limit"
  } catch {
    Fail "No se pudo listar los Lister HQ: $(Describe-Error $_)"
  }
  $users = @($res.data)
  if ($users.Count -eq 1 -and $users[0].items) { $users = @($users[0].items) }
  $lister = $users | Where-Object { $_.email -ieq $ListerHqEmail } | Select-Object -First 1
  if ($lister -or $users.Count -lt $limit) { break }
  $page++
}
if (-not $lister) {
  Fail ("$ListerHqEmail no aparece como Lister HQ activo y verificado. " +
    'Revisá que haya elegido el rol LISTER_HQ y que un admin lo haya aprobado.')
}
Write-Host "Lister HQ: $($lister.fullName.name) $($lister.fullName.lastname) ($($lister.id))"

# 3. Asignarlo a la visita -------------------------------------------------
Write-Host "Asignando a la visita $VisitId..."
try {
  $assign = Invoke-RestMethod -Method Patch -Headers $headers `
    -Uri "$BaseUrl/admin/visits/$VisitId/assign-lister-hq" `
    -ContentType 'application/json; charset=utf-8' `
    -Body (@{ listerHqId = $lister.id } | ConvertTo-Json)
} catch {
  Fail "No se pudo asignar: $(Describe-Error $_)"
}

Write-Host 'Listo: el Lister HQ quedó asignado a la visita.' -ForegroundColor Green
$assign | ConvertTo-Json -Depth 6
