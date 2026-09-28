# JSON das operações

Base URL: `https://dimdim-cp5-api-<SUFFIX>.azurewebsites.net`

## Clientes

### POST /api/clientes  → 201 Created
Request:
```json
{
  "nome": "Steves Jobs",
  "email": "steves.jobs@dimdim.com"
}
```
Response:
```json
{
  "id": 1,
  "nome": "Steves Jobs",
  "email": "steves.jobs@dimdim.com",
  "dataCadastro": "2026-09-28T18:30:00Z",
  "transacoes": []
}
```

### GET /api/clientes  → 200 OK
```json
[
  {
    "id": 1,
    "nome": "Steves Jobs",
    "email": "steves.jobs@dimdim.com",
    "dataCadastro": "2026-09-28T18:30:00Z",
    "transacoes": [
      {
        "id": 1,
        "clienteId": 1,
        "tipo": "PIX",
        "valor": 150.00,
        "descricao": "Pagamento de fornecedor",
        "dataTransacao": "2026-09-28T18:35:00Z"
      }
    ]
  }
]
```

### GET /api/clientes/1  → 200 OK (ou 404)
Retorna um único objeto, no mesmo formato acima.

### PUT /api/clientes/1  → 204 No Content
```json
{
  "nome": "Steves Jobs Jr.",
  "email": "steves.jobs@dimdim.com"
}
```

### DELETE /api/clientes/1  → 204 No Content
Sem corpo. Remove o cliente e suas transações (cascade).

## Transações

### POST /api/transacoes  → 201 Created
Request:
```json
{
  "clienteId": 1,
  "tipo": "PIX",
  "valor": 150.00,
  "descricao": "Pagamento de fornecedor"
}
```
Response:
```json
{
  "id": 1,
  "clienteId": 1,
  "tipo": "PIX",
  "valor": 150.00,
  "descricao": "Pagamento de fornecedor",
  "dataTransacao": "2026-09-28T18:35:00Z"
}
```

### GET /api/transacoes?clienteId=1  → 200 OK
```json
[
  {
    "id": 1,
    "clienteId": 1,
    "tipo": "PIX",
    "valor": 150.00,
    "descricao": "Pagamento de fornecedor",
    "dataTransacao": "2026-09-28T18:35:00Z"
  }
]
```

### GET /api/transacoes/1  → 200 OK (ou 404)

### PUT /api/transacoes/1  → 204 No Content
```json
{
  "clienteId": 1,
  "tipo": "DEPOSITO",
  "valor": 200.00,
  "descricao": "Depósito corrigido"
}
```

### DELETE /api/transacoes/1  → 204 No Content

## Erros esperados
- `400 Bad Request`: validação (ex.: `tipo` fora de DEPOSITO/SAQUE/PIX, `valor` <= 0, cliente inexistente).
- `404 Not Found`: id não encontrado.
- `409 Conflict`: e-mail de cliente já cadastrado.
