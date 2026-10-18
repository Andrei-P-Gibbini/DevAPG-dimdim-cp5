# Roteiro e registro de testes do Swagger – DimDim CP5 (Grupo DevAPG)

Swagger: https://dimdim-cp5-api-devapg.azurewebsites.net/swagger

Como usar: execute cada passo no Swagger (**Try it out → Execute**), depois rode os dois SELECTs abaixo no **Query editor** do `dimdimdb` e tire um print da resposta do Swagger e outro do resultado do SQL. Marque `[x]` e anote o obtido.

SELECTs a rodar após **cada** execução:

```sql
SELECT * FROM dbo.Clientes;
SELECT * FROM dbo.Transacoes;
```

> Observação: o repositório não contém resultados reais. Os campos "Obtido" devem ser preenchidos com o que você de fato executou na nuvem.

---

## 1. POST /api/clientes

**Objetivo:** Cria o cliente (master)

**Request body:**
```json
{
  "nome": "Steves Jobs",
  "email": "steves.jobs@dimdim.com"
}
```

**Esperado:** `201 Created` — `id` gerado (ex.: 1), `dataCadastro` preenchida, `transacoes: []`

**Esperado no banco:** Clientes: 1 linha nova. Transacoes: vazia.

**Obtido (preencher):** Status `____` · Print Swagger `[ ]` · Print SQL `[ ]` · OK `[ ]`

---

## 2. POST /api/clientes (e-mail duplicado)

**Objetivo:** Valida UNIQUE do e-mail

**Request body:**
```json
{
  "nome": "Outro",
  "email": "steves.jobs@dimdim.com"
}
```

**Esperado:** `409 Conflict` — `{"erro":"E-mail já cadastrado."}`

**Esperado no banco:** Nenhuma alteração (continua 1 cliente).

**Obtido (preencher):** Status `____` · Print Swagger `[ ]` · Print SQL `[ ]` · OK `[ ]`

---

## 3. POST /api/clientes (e-mail inválido)

**Objetivo:** Valida formato do e-mail

**Request body:**
```json
{
  "nome": "X",
  "email": "nao-e-email"
}
```

**Esperado:** `400 Bad Request` — Erro de validação do campo `email`

**Esperado no banco:** Nenhuma alteração.

**Obtido (preencher):** Status `____` · Print Swagger `[ ]` · Print SQL `[ ]` · OK `[ ]`

---

## 4. GET /api/clientes

**Objetivo:** Lista clientes com suas transações

**Parâmetro:** —

**Esperado:** `200 OK` — Array com o cliente criado e `transacoes: []`

**Esperado no banco:** Sem alteração.

**Obtido (preencher):** Status `____` · Print Swagger `[ ]` · Print SQL `[ ]` · OK `[ ]`

---

## 5. GET /api/clientes/{id}

**Objetivo:** Busca por id (use o id criado)

**Parâmetro:** id = 1

**Esperado:** `200 OK` — Objeto do cliente 1

**Esperado no banco:** Sem alteração.

**Obtido (preencher):** Status `____` · Print Swagger `[ ]` · Print SQL `[ ]` · OK `[ ]`

---

## 6. GET /api/clientes/999999

**Objetivo:** Cliente inexistente

**Parâmetro:** id = 999999

**Esperado:** `404 Not Found` — Sem corpo

**Esperado no banco:** Sem alteração.

**Obtido (preencher):** Status `____` · Print Swagger `[ ]` · Print SQL `[ ]` · OK `[ ]`

---

## 7. POST /api/transacoes

**Objetivo:** Cria transação (detail, FK = cliente 1)

**Request body:**
```json
{
  "clienteId": 1,
  "tipo": "PIX",
  "valor": 150.00,
  "descricao": "Pagamento de fornecedor"
}
```

**Esperado:** `201 Created` — `id` gerado, `clienteId: 1`, `tipo: PIX`, `valor: 150.00`

**Esperado no banco:** Transacoes: 1 linha com ClienteId = 1.

**Obtido (preencher):** Status `____` · Print Swagger `[ ]` · Print SQL `[ ]` · OK `[ ]`

---

## 8. POST /api/transacoes (cliente inexistente)

**Objetivo:** Valida a FK

**Request body:**
```json
{
  "clienteId": 999999,
  "tipo": "PIX",
  "valor": 10.00
}
```

**Esperado:** `400 Bad Request` — `{"erro":"Cliente informado não existe."}`

**Esperado no banco:** Nenhuma alteração.

**Obtido (preencher):** Status `____` · Print Swagger `[ ]` · Print SQL `[ ]` · OK `[ ]`

---

## 9. POST /api/transacoes (tipo inválido)

**Objetivo:** Valida o CHECK do tipo

**Request body:**
```json
{
  "clienteId": 1,
  "tipo": "BOLETO",
  "valor": 10.00
}
```

**Esperado:** `400 Bad Request` — Erro de validação do campo `tipo`

**Esperado no banco:** Nenhuma alteração.

**Obtido (preencher):** Status `____` · Print Swagger `[ ]` · Print SQL `[ ]` · OK `[ ]`

---

## 10. POST /api/transacoes (valor inválido)

**Objetivo:** Valida CHECK Valor > 0

**Request body:**
```json
{
  "clienteId": 1,
  "tipo": "SAQUE",
  "valor": 0
}
```

**Esperado:** `400 Bad Request` — Erro de validação do campo `valor`

**Esperado no banco:** Nenhuma alteração.

**Obtido (preencher):** Status `____` · Print Swagger `[ ]` · Print SQL `[ ]` · OK `[ ]`

---

## 11. GET /api/transacoes

**Objetivo:** Lista transações

**Parâmetro:** —

**Esperado:** `200 OK` — Array com a transação criada

**Esperado no banco:** Sem alteração.

**Obtido (preencher):** Status `____` · Print Swagger `[ ]` · Print SQL `[ ]` · OK `[ ]`

---

## 12. GET /api/transacoes?clienteId=1

**Objetivo:** Filtra por cliente

**Parâmetro:** clienteId = 1

**Esperado:** `200 OK` — Somente transações do cliente 1

**Esperado no banco:** Sem alteração.

**Obtido (preencher):** Status `____` · Print Swagger `[ ]` · Print SQL `[ ]` · OK `[ ]`

---

## 13. GET /api/transacoes/{id}

**Objetivo:** Busca por id

**Parâmetro:** id = 1

**Esperado:** `200 OK` — Objeto da transação 1

**Esperado no banco:** Sem alteração.

**Obtido (preencher):** Status `____` · Print Swagger `[ ]` · Print SQL `[ ]` · OK `[ ]`

---

## 14. PUT /api/transacoes/{id}

**Objetivo:** Atualiza a transação

**Request body:**
```json
{
  "clienteId": 1,
  "tipo": "DEPOSITO",
  "valor": 200.00,
  "descricao": "Depósito corrigido"
}
```

**Esperado:** `204 No Content` — Sem corpo

**Esperado no banco:** Transacoes: Tipo = DEPOSITO, Valor = 200.00, Descricao = 'Depósito corrigido'.

**Obtido (preencher):** Status `____` · Print Swagger `[ ]` · Print SQL `[ ]` · OK `[ ]`

---

## 15. PUT /api/clientes/{id}

**Objetivo:** Atualiza o cliente

**Request body:**
```json
{
  "nome": "Steves Jobs Jr.",
  "email": "steves.jobs@dimdim.com"
}
```

**Esperado:** `204 No Content` — Sem corpo

**Esperado no banco:** Clientes: Nome = 'Steves Jobs Jr.'.

**Obtido (preencher):** Status `____` · Print Swagger `[ ]` · Print SQL `[ ]` · OK `[ ]`

---

## 16. DELETE /api/transacoes/{id}

**Objetivo:** Remove a transação

**Parâmetro:** id = 1

**Esperado:** `204 No Content` — Sem corpo

**Esperado no banco:** Transacoes: vazia. Clientes: mantém o cliente.

**Obtido (preencher):** Status `____` · Print Swagger `[ ]` · Print SQL `[ ]` · OK `[ ]`

---

## 17. DELETE /api/clientes/{id}

**Objetivo:** Remove o cliente (cascade nas transações)

**Parâmetro:** id = 1 (antes, crie uma nova transação para provar o cascade)

**Esperado:** `204 No Content` — Sem corpo

**Esperado no banco:** Clientes: vazia. Transacoes: vazia (ON DELETE CASCADE).

**Obtido (preencher):** Status `____` · Print Swagger `[ ]` · Print SQL `[ ]` · OK `[ ]`

---

## 18. DELETE /api/clientes/{id} (já removido)

**Objetivo:** Id inexistente

**Parâmetro:** id = 1

**Esperado:** `404 Not Found` — Sem corpo

**Esperado no banco:** Sem alteração.

**Obtido (preencher):** Status `____` · Print Swagger `[ ]` · Print SQL `[ ]` · OK `[ ]`

---

## Application Insights (mostrar ao final)
- [ ] Live metrics com as requisições
- [ ] Transaction search / Performance mostrando as chamadas acima
- [ ] Failures mostrando os 400/404/409 propositais
