# Uso: powershell -ExecutionPolicy Bypass -File scripts\smoke-test.ps1 -Base http://localhost:5080
param([string]$Base = "http://localhost:5080")

$script:ok = 0
$script:fail = 0

function Req($Method, $Route, $Body = $null) {
    $params = @{ Uri = "$Base$Route"; Method = $Method; UseBasicParsing = $true; ContentType = "application/json" }
    if ($Body) { $params.Body = [System.Text.Encoding]::UTF8.GetBytes($Body) }
    $status = 0; $content = ""
    try {
        $r = Invoke-WebRequest @params
        $status = [int]$r.StatusCode
        $content = $r.Content
    } catch {
        if ($_.Exception.Response) { $status = [int]$_.Exception.Response.StatusCode } else { throw }
    }
    $json = $null
    if ($content) { try { $json = $content | ConvertFrom-Json } catch { } }
    return [pscustomobject]@{ Status = $status; Json = $json }
}

function Check($Name, $Expected, $Actual) {
    if ($Expected -eq $Actual) { Write-Host "OK    $Name ($Actual)" -ForegroundColor Green; $script:ok++ }
    else { Write-Host "FALHA $Name (esperado $Expected, obtido $Actual)" -ForegroundColor Red; $script:fail++ }
}

$email = "teste$(Get-Random)@dimdim.com"

Write-Host "== CLIENTES =="
$r = Req POST "/api/clientes" "{`"nome`":`"Teste`",`"email`":`"$email`"}"
Check "POST cliente" 201 $r.Status
$cid = $r.Json.id
Check "POST cliente e-mail duplicado" 409 (Req POST "/api/clientes" "{`"nome`":`"Outro`",`"email`":`"$email`"}").Status
Check "POST cliente e-mail invalido"  400 (Req POST "/api/clientes" '{"nome":"X","email":"nao-e-email"}').Status
Check "GET clientes"                  200 (Req GET "/api/clientes").Status
Check "GET cliente por id"            200 (Req GET "/api/clientes/$cid").Status
Check "GET cliente inexistente"       404 (Req GET "/api/clientes/999999").Status
Check "PUT cliente"                   204 (Req PUT "/api/clientes/$cid" "{`"nome`":`"Teste Editado`",`"email`":`"$email`"}").Status

Write-Host "== TRANSACOES =="
$r = Req POST "/api/transacoes" "{`"clienteId`":$cid,`"tipo`":`"PIX`",`"valor`":150.50,`"descricao`":`"teste`"}"
Check "POST transacao" 201 $r.Status
$tid = $r.Json.id
Check "POST transacao tipo invalido"        400 (Req POST "/api/transacoes" "{`"clienteId`":$cid,`"tipo`":`"TED`",`"valor`":10}").Status
Check "POST transacao valor zero"           400 (Req POST "/api/transacoes" "{`"clienteId`":$cid,`"tipo`":`"PIX`",`"valor`":0}").Status
Check "POST transacao cliente inexistente"  400 (Req POST "/api/transacoes" '{"clienteId":999999,"tipo":"PIX","valor":10}').Status
Check "GET transacoes"                      200 (Req GET "/api/transacoes").Status
Check "GET transacoes por cliente"          200 (Req GET "/api/transacoes?clienteId=$cid").Status
Check "GET transacao por id"                200 (Req GET "/api/transacoes/$tid").Status
Check "PUT transacao"                       204 (Req PUT "/api/transacoes/$tid" "{`"clienteId`":$cid,`"tipo`":`"DEPOSITO`",`"valor`":200,`"descricao`":`"editada`"}").Status
Check "DELETE transacao"                    204 (Req DELETE "/api/transacoes/$tid").Status
Check "GET transacao apagada"               404 (Req GET "/api/transacoes/$tid").Status

Write-Host "== CASCADE =="
$r = Req POST "/api/transacoes" "{`"clienteId`":$cid,`"tipo`":`"SAQUE`",`"valor`":20}"
$tid2 = $r.Json.id
Check "DELETE cliente"                      204 (Req DELETE "/api/clientes/$cid").Status
Check "Transacao removida em cascata"       404 (Req GET "/api/transacoes/$tid2").Status
Check "DELETE cliente ja apagado"           404 (Req DELETE "/api/clientes/$cid").Status

Write-Host ""
Write-Host "Resultado: $($script:ok) OK, $($script:fail) FALHA(S)"
if ($script:fail -gt 0) { exit 1 }
