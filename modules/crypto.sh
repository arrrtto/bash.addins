#!/bin/bash

# Crypto related module
MODULE_NAME="crypto"
MODULE_VERSION="1.2"
MODULE_DESCRIPTION="Cryptocurrency utilities"


function crypto_fearandgreedindex() {
# Gets the current crypto fear and greed index via API.
command -v curl >/dev/null 2>&1 || { echo "crypto_fearandgreedindex: curl is required" >&2; return 1; }
command -v jq >/dev/null 2>&1 || { echo "crypto_fearandgreedindex: jq is required" >&2; return 1; }
local response
response=$(curl -fLsS --retry 2 --connect-timeout 10 --max-time 20 \
  "https://api.alternative.me/fng/") || {
  echo "Could not retrieve the Fear & Greed Index." >&2
  return 1
}
jq -er '
  .data[0]
  | select(.value != null and .value_classification != null)
  | "Fear & Greed Index: \(.value) (\(.value_classification))"
' <<< "$response" || {
  echo "The Fear & Greed API returned an unexpected response." >&2
  return 1
}
}


