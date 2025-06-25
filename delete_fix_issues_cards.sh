#!/bin/bash

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Configuration
BOARD_ID="1536840609606665222"
BASE_URL="http://localhost:3333/api"
TOKEN="${PLANKA_API_TOKEN}"

# Check if token is available
if [ -z "$TOKEN" ]; then
    echo "Error: PLANKA_API_TOKEN not found in .env file"
    exit 1
fi

echo "Fetching board data..."

# Get board data and extract cards with names starting with "Fix issues in"
BOARD_DATA=$(curl --silent --location "$BASE_URL/boards/$BOARD_ID" \
  --header "Authorization: Bearer $TOKEN")

if [ $? -ne 0 ]; then
  echo "Error: Failed to fetch board data"
  exit 1
fi

echo "Searching for cards with names starting with 'Fix issues in'..."

# Extract card IDs for cards with names starting with "Fix issues in"
CARD_IDS=$(echo "$BOARD_DATA" | jq -r '.included.cards[]? | select(.name | startswith("Fix issues in")) | .id')

if [ -z "$CARD_IDS" ]; then
  echo "No cards found with names starting with 'Fix issues in'"
  exit 0
fi

echo "Found cards to delete:"
echo "$BOARD_DATA" | jq -r '.included.cards[]? | select(.name | startswith("Fix issues in")) | "- \(.name) (ID: \(.id))"'

# Delete each card
for CARD_ID in $CARD_IDS; do
  echo "Deleting card ID: $CARD_ID"
  
  RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" \
    --location --request DELETE "$BASE_URL/cards/$CARD_ID" \
    --header "Authorization: Bearer $TOKEN")
  
  HTTP_STATUS=$(echo $RESPONSE | tr -d '\n' | sed -E 's/.*HTTPSTATUS:([0-9]{3})$/\1/')
  
  if [ "$HTTP_STATUS" -eq 200 ] || [ "$HTTP_STATUS" -eq 204 ]; then
    echo "✓ Successfully deleted card $CARD_ID"
  else
    echo "✗ Failed to delete card $CARD_ID (HTTP status: $HTTP_STATUS)"
  fi
done

echo "Done!"