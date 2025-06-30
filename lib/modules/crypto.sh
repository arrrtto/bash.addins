#!/bin/bash

# Crypto module configuration
MODULE_NAME="crypto"
MODULE_VERSION="1.0"
MODULE_DESCRIPTION="Cryptocurrency utilities"

# Crypto functions
function crypto_fearandgreedindex() {
    curl -s "https://api.alternative.me/fng/" | jq -r '.data[0] | "Fear & Greed Index: \(.value) (\(.value_classification))"'
}

function qort_price() {
    local url="https://api.coingecko.com/api/v3/simple/price?ids=qort&vs_currencies=usd"
    curl -s "$url" | jq -r '.qort.usd'
}

# Module initialization
function init_${MODULE_NAME}_module() {
    # Check if required commands are available
    local required=("curl" "jq")
    for cmd in "${required[@]}"; do
        if ! command -v "$cmd" > /dev/null 2>&1; then
            echo "Warning: $cmd is required for crypto functions"
        fi
    done
}

# Module help
function ${MODULE_NAME}_help() {
    cat << EOF
${MODULE_NAME} module v${MODULE_VERSION}
${MODULE_DESCRIPTION}

Available functions:
  crypto_fearandgreedindex Get current crypto Fear & Greed Index
  qort_price               Get current QORT price in USD
EOF
}

# Initialize module
init_${MODULE_NAME}_module
