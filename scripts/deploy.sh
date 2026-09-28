#!/usr/bin/env bash
# =====================================================================
# DimDim CP5 - Criação dos recursos e deploy via Azure CLI
# Executar no Azure Cloud Shell (Bash) ou em um terminal com az + dotnet.
# Uso:
#   export SUFFIX=rm12345          # letras minúsculas/números (deixa nomes únicos)
#   export SQL_PASSWORD='SuaSenha@Forte123'
#   bash scripts/deploy.sh
# =====================================================================
set -euo pipefail
cd "$(dirname "$0")"

# ---------- Variáveis ----------
: "${SUFFIX:?Defina SUFFIX (ex.: export SUFFIX=rm12345)}"
: "${SQL_PASSWORD:?Defina SQL_PASSWORD (ex.: export SQL_PASSWORD='SuaSenha@Forte123')}"

LOCATION="${LOCATION:-brazilsouth}"      # se der erro de região: export LOCATION=eastus2
RG="rg-dimdim-cp5"
PLAN="plan-dimdim-cp5"
WEBAPP="dimdim-cp5-api-${SUFFIX}"
SQL_SERVER="sql-dimdim-cp5-${SUFFIX}"
SQL_DB="dimdimdb"
SQL_ADMIN="dimdimadmin"
LAW="log-dimdim-cp5"
APPI="appi-dimdim-cp5"

echo ">>> 1/8 Resource group"
az group create --name "$RG" --location "$LOCATION"

echo ">>> 2/8 SQL Server (PaaS)"
az sql server create \
  --resource-group "$RG" --name "$SQL_SERVER" --location "$LOCATION" \
  --admin-user "$SQL_ADMIN" --admin-password "$SQL_PASSWORD"

# Permite acesso de serviços do Azure (App Service) ao SQL
az sql server firewall-rule create \
  --resource-group "$RG" --server "$SQL_SERVER" \
  --name AllowAzureServices --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0

# Permite o IP de onde o script está rodando (para executar o DDL)
MY_IP="$(curl -s https://api.ipify.org)"
az sql server firewall-rule create \
  --resource-group "$RG" --server "$SQL_SERVER" \
  --name AllowMyIP --start-ip-address "$MY_IP" --end-ip-address "$MY_IP"

echo ">>> 3/8 Banco de dados (Basic)"
az sql db create \
  --resource-group "$RG" --server "$SQL_SERVER" --name "$SQL_DB" \
  --service-objective Basic --backup-storage-redundancy Local

echo ">>> 4/8 Executando DDL das tabelas"
if command -v sqlcmd >/dev/null 2>&1; then
  sqlcmd -S "${SQL_SERVER}.database.windows.net" -d "$SQL_DB" \
    -U "$SQL_ADMIN" -P "$SQL_PASSWORD" -i ../database/01_ddl.sql
else
  echo "!! sqlcmd não encontrado. Execute database/01_ddl.sql pelo Portal:"
  echo "   SQL databases > $SQL_DB > Query editor (preview)"
  read -r -p "Pressione ENTER depois de executar o DDL..."
fi

echo ">>> 5/8 Application Insights"
az extension add --name application-insights --only-show-errors || true
az monitor log-analytics workspace create \
  --resource-group "$RG" --workspace-name "$LAW" --location "$LOCATION"
LAW_ID="$(az monitor log-analytics workspace show \
  --resource-group "$RG" --workspace-name "$LAW" --query id -o tsv)"
az monitor app-insights component create \
  --app "$APPI" --resource-group "$RG" --location "$LOCATION" \
  --kind web --application-type web --workspace "$LAW_ID"
APPI_CS="$(az monitor app-insights component show \
  --app "$APPI" --resource-group "$RG" --query connectionString -o tsv)"

echo ">>> 6/8 App Service (Linux, .NET 8)"
az appservice plan create \
  --resource-group "$RG" --name "$PLAN" --location "$LOCATION" \
  --sku B1 --is-linux
az webapp create \
  --resource-group "$RG" --plan "$PLAN" --name "$WEBAPP" --runtime "DOTNETCORE:8.0"

echo ">>> 7/8 Configurações do app (connection string + Application Insights)"
CONN="Server=tcp:${SQL_SERVER}.database.windows.net,1433;Initial Catalog=${SQL_DB};User ID=${SQL_ADMIN};Password=${SQL_PASSWORD};Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
az webapp config connection-string set \
  --resource-group "$RG" --name "$WEBAPP" \
  --connection-string-type SQLAzure --settings DefaultConnection="$CONN"
az webapp config appsettings set \
  --resource-group "$RG" --name "$WEBAPP" \
  --settings APPLICATIONINSIGHTS_CONNECTION_STRING="$APPI_CS"

echo ">>> 8/8 Build e deploy"
rm -rf publish app.zip
dotnet publish ../src/DimDim.Api -c Release -o ./publish
(cd publish && zip -qr ../app.zip .)
az webapp deploy \
  --resource-group "$RG" --name "$WEBAPP" --src-path app.zip --type zip

echo
echo "=========================================================="
echo " Deploy concluído!"
echo " Swagger: https://${WEBAPP}.azurewebsites.net/swagger"
echo "=========================================================="
