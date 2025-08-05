#!/bin/bash

# Crypto related module
MODULE_NAME="crypto"
MODULE_VERSION="1.06"
MODULE_DESCRIPTION="Cryptocurrency utilities"


function crypto_fearandgreedindex() {
# Gets the current crypto fear and greed index via API.
curl -s "https://api.alternative.me/fng/" | jq -r '.data[0] | "Fear & Greed Index: \(.value) (\(.value_classification))"'
}



