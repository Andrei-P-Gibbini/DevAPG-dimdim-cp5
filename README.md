# DimDim – CP5 (Web App + Banco em Nuvem)

API REST em **.NET 8 (ASP.NET Core)** com **Entity Framework Core**, persistindo em **Azure SQL Database (PaaS)**,
hospedada no **Azure App Service (Linux)** e monitorada com **Application Insights**.
Todos os recursos e o deploy são feitos via **Azure CLI**.

## Modelo de dados (master-detail)

```
Clientes (1) ────< (N) Transacoes
   Id (PK)              Id (PK)
   Nome                 ClienteId (FK -> Clientes.Id, ON DELETE CASCADE)
   Email (UNIQUE)       Tipo (DEPOSITO | SAQUE | PIX)
   DataCadastro         Valor
                        Descricao
                        DataTransacao
```

DDL completo: [`database/01_ddl.sql`](database/01_ddl.sql)

## Estrutura do repositório

```
database/01_ddl.sql        -> script do banco (tabelas, PK, FK, constraints)
scripts/deploy.sh          -> Azure CLI: cria recursos + deploy
scripts/cleanup.sh         -> remove todos os recursos
src/DimDim.Api/            -> código-fonte da aplicação
docs/operacoes-json.md     -> JSON das operações GET, POST, PUT e DELETE
```

## Como implantar (How-to)

### Pré-requisitos
- Conta Azure com assinatura ativa
- **Azure Cloud Shell (Bash)** – recomendado, já vem com `az`, `dotnet`, `zip` e `sqlcmd`
  (ou terminal local com Azure CLI, .NET 8 SDK, zip e sqlcmd)

### Passo a passo

1. Abra o Cloud Shell em <https://shell.azure.com> (Bash).
2. Clone o repositório:
   ```bash
   git clone <URL_DO_SEU_REPOSITORIO>
   cd <NOME_DO_REPOSITORIO>
   ```
3. Confirme a assinatura ativa:
   ```bash
   az account show --query name -o tsv
   ```
4. Defina as variáveis (SUFFIX deixa os nomes únicos; use letras minúsculas e números):
   ```bash
   export SUFFIX=rm12345
   export SQL_PASSWORD='DimDim@Cp5#2026'
   # opcional, caso a região padrão (brazilsouth) esteja bloqueada na sua assinatura:
   # export LOCATION=eastus2
   ```
5. Execute o script:
   ```bash
   bash scripts/deploy.sh
   ```
   O script executa, nesta ordem: resource group → SQL Server → regra de firewall → banco →
   **DDL das tabelas** → Log Analytics + **Application Insights** → App Service Plan → Web App →
   connection string e app settings → `dotnet publish` → zip deploy.
6. Ao final, abra a URL exibida: `https://dimdim-cp5-api-<SUFFIX>.azurewebsites.net/swagger`

> Se o `sqlcmd` não existir no seu ambiente, o script pausa e pede para executar
> `database/01_ddl.sql` no **Query editor** do banco (Portal Azure → SQL databases → dimdimdb → Query editor).

### Remover tudo ao final
```bash
bash scripts/cleanup.sh
```

## Endpoints

| Recurso | Método | Rota |
|---|---|---|
| Clientes | GET | `/api/clientes` e `/api/clientes/{id}` |
| Clientes | POST | `/api/clientes` |
| Clientes | PUT | `/api/clientes/{id}` |
| Clientes | DELETE | `/api/clientes/{id}` (apaga também as transações) |
| Transações | GET | `/api/transacoes`, `/api/transacoes?clienteId=1` e `/api/transacoes/{id}` |
| Transações | POST | `/api/transacoes` |
| Transações | PUT | `/api/transacoes/{id}` |
| Transações | DELETE | `/api/transacoes/{id}` |

Exemplos de JSON: [`docs/operacoes-json.md`](docs/operacoes-json.md)

## Roteiro da apresentação (evita perda de pontos)

1. Mostrar no Portal os recursos criados e o código do `deploy.sh` (Azure CLI).
2. Abrir o **Query editor** do banco e deixar uma aba pronta com:
   ```sql
   SELECT * FROM dbo.Clientes;
   SELECT * FROM dbo.Transacoes;
   ```
3. No Swagger, executar **e rodar os dois SELECTs após CADA operação**:
   POST cliente → POST transação → PUT transação → PUT cliente → DELETE transação → DELETE cliente
   (mostrar também os GETs).
4. Mostrar o **Application Insights**: *Live metrics*, *Transaction search* e *Performance/Failures*
   com as requisições que acabaram de ser feitas.

## Comandos úteis de diagnóstico
```bash
az webapp log tail --resource-group rg-dimdim-cp5 --name dimdim-cp5-api-<SUFFIX>
az webapp restart  --resource-group rg-dimdim-cp5 --name dimdim-cp5-api-<SUFFIX>
```
