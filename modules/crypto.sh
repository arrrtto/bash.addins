#!/bin/bash

# Crypto related module
MODULE_NAME="crypto"
MODULE_VERSION="1.04"
MODULE_DESCRIPTION="Cryptocurrency utilities"


function crypto_fearandgreedindex() {
# Gets the current crypto fear and greed index via API.
curl -s "https://api.alternative.me/fng/" | jq -r '.data[0] | "Fear & Greed Index: \(.value) (\(.value_classification))"'
}


function qort_price() {
# Gets the current market price of QORT cryptocurrency from TradeOgre using API.
curl -sX GET "https://tradeogre.com/api/v1/markets" | jq -r '.[]["QORT-USDT"].price // empty | tonumber'
}


