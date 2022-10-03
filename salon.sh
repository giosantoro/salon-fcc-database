#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~ MY SALON ~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "Welcome to My Salon, how can I help you?"
  fi

  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services")
  
   echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done

  read SERVICE_ID_SELECTED

  re='^[0-9]+$'
  if ! [[ $SERVICE_ID_SELECTED =~ $re ]] ; then
   echo -e "\nI could not find that service. What would you like today?"
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
  fi

  if [[ $SERVICE_ID_SELECTED =~ $re ]] ; then
    CHOSEN_SERVICE=$($PSQL "SELECT service_id, name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if ! [[ -z $CHOSEN_SERVICE ]] ; then
      CLIENT_INFO $SERVICE_ID_SELECTED
    else 
    echo -e "\nI could not find that service. What would you like today?"
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
    fi
  fi
}

CLIENT_INFO()
{
  #get client number
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  echo -e "\nYou have chosen the service $SERVICE_NAME. What's your phone number?"
  read CUSTOMER_PHONE
  
  #get customer info if new client
  CUSTOMER=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER ]] ; then
    echo -e "\nWelcome to our salon. What's your name?"
    read CUSTOMER_NAME
    NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi

  echo -e "\nWhat time would you like to schedule the appointment?"
  read SERVICE_TIME

  if [[ -z $NEW_CUSTOMER ]] ; then
    NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER")
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    else
    NEW_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($NEW_CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU