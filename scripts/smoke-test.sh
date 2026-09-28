#!/usr/bin/env bash
# Uso: bash scripts/smoke-test.sh http://localhost:5080
BASE="${1:-http://localhost:5080}"
ok=0; fail=0

check() { # nome esperado obtido
  if [ "$2" = "$3" ]; then echo "OK    $1 ($3)"; ok=$((ok+1))
  else echo "FALHA $1 (esperado $2, obtido $3)"; fail=$((fail+1)); fi
}
req() { # metodo rota [json]
  local args=(-s -o /tmp/resp.json -w "%{http_code}" -X "$1" "$BASE$2" -H "Content-Type: application/json")
  [ -n "${3:-}" ] && args+=(-d "$3")
  curl "${args[@]}"
}
first_id() { grep -o '"id":[0-9]*' /tmp/resp.json | head -1 | cut -d: -f2; }

EMAIL="teste$RANDOM@dimdim.com"

echo "== CLIENTES =="
check "POST cliente"                  201 "$(req POST /api/clientes "{\"nome\":\"Teste\",\"email\":\"$EMAIL\"}")"
CID=$(first_id)
check "POST cliente e-mail duplicado" 409 "$(req POST /api/clientes "{\"nome\":\"Outro\",\"email\":\"$EMAIL\"}")"
check "POST cliente e-mail invalido"  400 "$(req POST /api/clientes '{"nome":"X","email":"nao-e-email"}')"
check "GET clientes"                  200 "$(req GET /api/clientes)"
check "GET cliente por id"            200 "$(req GET /api/clientes/$CID)"
check "GET cliente inexistente"       404 "$(req GET /api/clientes/999999)"
check "PUT cliente"                   204 "$(req PUT /api/clientes/$CID "{\"nome\":\"Teste Editado\",\"email\":\"$EMAIL\"}")"

echo "== TRANSACOES =="
check "POST transacao"                201 "$(req POST /api/transacoes "{\"clienteId\":$CID,\"tipo\":\"PIX\",\"valor\":150.50,\"descricao\":\"teste\"}")"
TID=$(first_id)
check "POST transacao tipo invalido"  400 "$(req POST /api/transacoes "{\"clienteId\":$CID,\"tipo\":\"TED\",\"valor\":10}")"
check "POST transacao valor zero"     400 "$(req POST /api/transacoes "{\"clienteId\":$CID,\"tipo\":\"PIX\",\"valor\":0}")"
check "POST transacao cliente inexistente" 400 "$(req POST /api/transacoes '{"clienteId":999999,"tipo":"PIX","valor":10}')"
check "GET transacoes"                200 "$(req GET /api/transacoes)"
check "GET transacoes por cliente"    200 "$(req GET "/api/transacoes?clienteId=$CID")"
check "GET transacao por id"          200 "$(req GET /api/transacoes/$TID)"
check "PUT transacao"                 204 "$(req PUT /api/transacoes/$TID "{\"clienteId\":$CID,\"tipo\":\"DEPOSITO\",\"valor\":200,\"descricao\":\"editada\"}")"
check "DELETE transacao"              204 "$(req DELETE /api/transacoes/$TID)"
check "GET transacao apagada"         404 "$(req GET /api/transacoes/$TID)"

echo "== CASCADE =="
req POST /api/transacoes "{\"clienteId\":$CID,\"tipo\":\"SAQUE\",\"valor\":20}" >/dev/null
TID2=$(first_id)
check "DELETE cliente"                204 "$(req DELETE /api/clientes/$CID)"
check "Transacao removida em cascata" 404 "$(req GET /api/transacoes/$TID2)"
check "DELETE cliente ja apagado"     404 "$(req DELETE /api/clientes/$CID)"

echo
echo "Resultado: $ok OK, $fail FALHA(S)"
[ "$fail" -eq 0 ]
