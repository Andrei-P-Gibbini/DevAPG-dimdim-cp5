#!/usr/bin/env bash
# Remove TODOS os recursos do CP5 (economiza crédito após a apresentação)
az group delete --name rg-dimdim-cp5 --yes --no-wait
