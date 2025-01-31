#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

# Function to display services
display_services() {
  echo -e "\nAvailable Services:"
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while IFS='|' read SERVICE_ID SERVICE_NAME; do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Main script execution
echo "Welcome to the Salon!"
display_services

# Prompt for service ID
SERVICE_NAME=""
while [[ -z "$SERVICE_NAME" ]]; do
  echo -e "\nEnter service ID: "
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED" | sed -E 's/^ *| *$//g')
  if [[ -z "$SERVICE_NAME" ]]; then
    echo "Invalid selection. Try again."
    display_services
  fi
done

# Prompt for phone number
echo -e "\nEnter your phone number: "
read CUSTOMER_PHONE
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'" | sed -E 's/^ *| *$//g')

# Prompt for customer name if not found
if [[ -z "$CUSTOMER_ID" ]]; then
  echo "You are a new customer! Enter your name: "
  read CUSTOMER_NAME
  $PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')"
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'" | sed -E 's/^ *| *$//g')
else
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID" | sed -E 's/^ *| *$//g')
fi

# Prompt for appointment time
echo -e "\nEnter appointment time: "
read SERVICE_TIME
$PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"

echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
